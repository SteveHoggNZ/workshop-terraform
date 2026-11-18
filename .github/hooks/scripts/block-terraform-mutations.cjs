// preToolUse hook: deny Terraform commands that change infrastructure or state (ADR-0006).
// Only real terraform/tofu invocations are checked, so echoing or grepping for the words is allowed.
const path = require('node:path');
const { readEvent, normalise, noDecision, deny, commandOf } = require('./lib/hook-io.cjs');

const MUTATING = new Set(['apply', 'destroy', 'import', 'taint', 'untaint', 'force-unlock']);
const MUTATING_STATE = new Set(['rm', 'mv', 'push', 'replace-provider']);
const PREFIXES = new Set(['sudo', 'time', 'command', 'exec', 'env', 'nohup', 'nice']);
const SHELLS = new Set(['bash', 'sh', 'zsh']);

// Split a shell command into simple commands (token lists), respecting quotes.
function simpleCommands(cmd) {
  const commands = [];
  let tokens = [];
  let cur = '';
  let quote = null;
  let inToken = false;
  const endToken = () => {
    if (inToken) tokens.push(cur);
    cur = '';
    inToken = false;
  };
  const endCommand = () => {
    endToken();
    if (tokens.length) commands.push(tokens);
    tokens = [];
  };
  for (let i = 0; i < cmd.length; i++) {
    const ch = cmd[i];
    if (quote) {
      if (ch === quote) quote = null;
      else if (ch === '\\' && quote === '"' && i + 1 < cmd.length) cur += cmd[++i];
      else cur += ch;
      continue;
    }
    if (ch === '"' || ch === "'") {
      quote = ch;
      inToken = true;
    } else if (ch === '\\' && i + 1 < cmd.length) {
      cur += cmd[++i];
      inToken = true;
    } else if (ch === '$' && cmd[i + 1] === '(') {
      endCommand();
      i++;
    } else if (';&|\n()`{}'.includes(ch)) {
      endCommand();
    } else if (/\s/.test(ch)) {
      endToken();
    } else {
      cur += ch;
      inToken = true;
    }
  }
  endCommand();
  return commands;
}

function isMutating(cmd, depth = 0) {
  if (depth > 3) return false;
  for (let tokens of simpleCommands(cmd)) {
    for (;;) {
      while (tokens.length && /^[A-Za-z_][A-Za-z0-9_]*=/.test(tokens[0])) tokens = tokens.slice(1);
      if (tokens.length && PREFIXES.has(path.basename(tokens[0]))) tokens = tokens.slice(1);
      else break;
    }
    if (!tokens.length) continue;
    const program = path.basename(tokens[0]);
    if (SHELLS.has(program)) {
      const c = tokens.findIndex((t) => /^-[a-z]*c[a-z]*$/.test(t));
      if (c > 0 && tokens[c + 1] && isMutating(tokens[c + 1], depth + 1)) return true;
      continue;
    }
    if (program !== 'terraform' && program !== 'tofu') continue;
    const words = tokens.slice(1).filter((t) => !t.startsWith('-'));
    if (MUTATING.has(words[0])) return true;
    if (words[0] === 'state' && MUTATING_STATE.has(words[1])) return true;
  }
  return false;
}

if (require.main === module) {
  const event = readEvent();
  if (!event) {
    noDecision();
  } else {
    const command = commandOf(normalise(event).args);
    if (command && isMutating(command)) {
      deny('This repo is plan-only (docs/adr/0006-plan-only-local-state.md). Use terraform plan or scripts/plan.sh instead.');
    } else {
      noDecision();
    }
  }
}

module.exports = { isMutating };
