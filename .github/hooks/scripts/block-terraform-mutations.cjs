// preToolUse hook: deny Terraform commands that change infrastructure or state (ADR-0006).
const fs = require('node:fs');

const allow = () => process.stdout.write('{}');

let event;
try {
  event = JSON.parse(fs.readFileSync(0, 'utf8'));
} catch {
  allow();
  process.exit(0);
}

let args = event.toolArgs;
if (typeof args === 'string') {
  try {
    args = JSON.parse(args);
  } catch {
    args = { command: args };
  }
}

const command = args && typeof args.command === 'string' ? args.command : '';
const mutating = /\b(terraform|tofu)\b[^\n;&|]*\s(apply|destroy|import|taint|untaint|force-unlock|state\s+(rm|mv|push|replace-provider))\b/;

if (mutating.test(command)) {
  process.stdout.write(JSON.stringify({
    permissionDecision: 'deny',
    permissionDecisionReason: 'This repo is plan-only (docs/adr/0006-plan-only-local-state.md). Use terraform plan instead.',
  }));
} else {
  allow();
}
