// postToolUse hook: run `terraform fmt` on .tf/.tfvars files the agent just edited,
// and tell the agent when a file was reformatted or has a syntax error.
const fs = require('node:fs');
const { spawnSync } = require('node:child_process');
const { readEvent, normalise, noDecision, addContext, fileEdits, isTerraformFile } = require('./lib/hook-io.cjs');

const event = readEvent();
if (!event) {
  noDecision();
} else {
  const { args, cwd } = normalise(event);
  const files = [...new Set(fileEdits(args, cwd).map((e) => e.path))].filter((p) => isTerraformFile(p) && fs.existsSync(p));
  const notes = [];
  for (const file of files) {
    const r = spawnSync('terraform', ['fmt', '-no-color', file], { encoding: 'utf8', timeout: 10000 });
    if (r.error) break; // terraform not installed: nothing to do
    if (r.status !== 0) {
      notes.push(`terraform fmt failed for ${file}:\n${(r.stderr || r.stdout).trim().slice(0, 1500)}`);
    } else if (r.stdout.trim()) {
      notes.push(`terraform fmt reformatted ${file}. View it again before making further edits to it.`);
    }
  }
  if (notes.length) addContext(event.hook_event_name || 'PostToolUse', notes.join('\n\n'));
  else noDecision();
}
