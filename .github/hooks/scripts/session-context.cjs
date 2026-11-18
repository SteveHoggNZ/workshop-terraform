// sessionStart hook: give the agent facts about the toolchain, Azure login, git state and
// current stage, so it starts from what is actually installed rather than from memory.
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { readEvent, noDecision, addContext } = require('./lib/hook-io.cjs');

const event = readEvent() || {};
const root = path.resolve(__dirname, '../../..');
const r = spawnSync('bash', [path.join(root, 'scripts/doctor.sh')], { cwd: root, encoding: 'utf8', timeout: 15000 });
const report = (r.stdout || '').trim();
if (!report) {
  noDecision();
} else {
  addContext(
    event.hook_event_name || 'SessionStart',
    `Output of scripts/doctor.sh at session start (facts, not assumptions):\n${report}`,
  );
}
