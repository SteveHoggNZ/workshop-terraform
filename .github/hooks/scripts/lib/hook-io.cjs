// Shared helpers for hook scripts.
//
// The Copilot harness sends camelCase payloads (toolName, toolArgs) and reads top-level
// output fields. The Local VS Code harness sends snake_case payloads (tool_name, tool_input)
// and reads `hookSpecificOutput`. Scripts accept both and write both output shapes.
const fs = require('node:fs');
const path = require('node:path');

function readEvent() {
  try {
    return JSON.parse(fs.readFileSync(0, 'utf8'));
  } catch {
    return null;
  }
}

function parseArgs(raw) {
  if (typeof raw !== 'string') return raw ?? {};
  try {
    return JSON.parse(raw);
  } catch {
    return { command: raw };
  }
}

function normalise(event) {
  return {
    eventName: event.hook_event_name || '',
    cwd: event.cwd || process.cwd(),
    toolName: event.toolName || event.tool_name || '',
    args: parseArgs(event.toolArgs !== undefined ? event.toolArgs : event.tool_input),
  };
}

function write(obj) {
  process.stdout.write(JSON.stringify(obj));
}

function noDecision() {
  write({});
}

function deny(reason) {
  write({
    permissionDecision: 'deny',
    permissionDecisionReason: reason,
    hookSpecificOutput: { hookEventName: 'PreToolUse', permissionDecision: 'deny', permissionDecisionReason: reason },
  });
}

function addContext(hookEventName, text) {
  write({ additionalContext: text, hookSpecificOutput: { hookEventName, additionalContext: text } });
}

// Shell command from a terminal tool call (bash, powershell, run_in_terminal).
function commandOf(args) {
  return args && typeof args.command === 'string' ? args.command : '';
}

const PATH_KEYS = ['path', 'filePath', 'file_path'];
const CONTENT_KEYS = ['file_text', 'content', 'new_str', 'newString', 'new_string', 'code'];

// Files an edit tool call will write, with the new text it adds.
// Handles create/edit style args (path + content), batched edits (arrays) and apply_patch text.
function fileEdits(args, cwd) {
  const edits = [];
  const visit = (node) => {
    if (typeof node === 'string') {
      edits.push(...patchEdits(node));
      return;
    }
    if (Array.isArray(node)) return node.forEach(visit);
    if (!node || typeof node !== 'object') return;
    const p = PATH_KEYS.map((k) => node[k]).find((v) => typeof v === 'string');
    if (p) {
      const text = CONTENT_KEYS.map((k) => node[k]).filter((v) => typeof v === 'string').join('\n');
      edits.push({ path: p, text });
    }
    for (const [k, v] of Object.entries(node)) {
      if (!PATH_KEYS.includes(k) && !CONTENT_KEYS.includes(k)) visit(v);
    }
  };
  visit(args);
  return edits.map((e) => ({ ...e, path: path.resolve(cwd, e.path.replace(/^file:\/\//, '')) }));
}

// apply_patch format: "*** Add File: x" / "*** Update File: x" followed by "+" lines.
function patchEdits(text) {
  if (!/^\*\*\* (Add|Update) File: /m.test(text)) return [];
  const edits = [];
  let current = null;
  for (const line of text.split('\n')) {
    const m = line.match(/^\*\*\* (?:Add|Update) File: (.+)$/);
    if (m) {
      current = { path: m[1].trim(), text: '' };
      edits.push(current);
    } else if (/^\*\*\* /.test(line)) {
      current = null;
    } else if (current && line.startsWith('+')) {
      current.text += line.slice(1) + '\n';
    }
  }
  return edits;
}

const isTerraformFile = (p) => /\.(tf|tfvars)$/.test(p);

module.exports = { readEvent, normalise, noDecision, deny, addContext, commandOf, fileEdits, isTerraformFile };
