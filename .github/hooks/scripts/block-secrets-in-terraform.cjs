// preToolUse hook: deny edits that write literal secrets into .tf or .tfvars files.
// Secrets come from Key Vault (see .github/copilot-instructions.md).
const { readEvent, normalise, noDecision, deny, fileEdits, isTerraformFile } = require('./lib/hook-io.cjs');

const SECRET_NAME = /(password|passwd|secret|client_secret|access_key|account_key|sas_token|connection_string|private_key|api_key|token)/i;
// Names that refer to a secret rather than hold one, e.g. domain_join_password_secret_name.
const REFERENCE_NAME = /(_name|_names|_id|_ids|_uri|_url|_version|_enabled|_length|_type|_vault|_vault_id)$/i;

function findSecrets(text) {
  const found = [];
  const assignment = /^\s*"?([A-Za-z0-9_-]+)"?\s*=\s*"([^"\n]*)"/gm;
  for (const m of text.matchAll(assignment)) {
    const [, name, value] = m;
    if (SECRET_NAME.test(name) && !REFERENCE_NAME.test(name) && value.trim() && !/^\$\{[^}]*\}$/.test(value)) {
      found.push(`${name} = "…"`);
    }
  }
  const variableDefault = /variable\s+"([^"]+)"\s*\{[^}]*?\bdefault\s*=\s*"([^"\n]+)"/g;
  for (const m of text.matchAll(variableDefault)) {
    if (SECRET_NAME.test(m[1]) && !REFERENCE_NAME.test(m[1])) found.push(`variable "${m[1]}" default`);
  }
  if (/-----BEGIN [A-Z ]*PRIVATE KEY-----/.test(text)) found.push('private key block');
  if (/AccountKey=[A-Za-z0-9+/=]{20,}/.test(text)) found.push('storage account key');
  return found;
}

if (require.main === module) {
  const event = readEvent();
  if (!event) {
    noDecision();
  } else {
    const { args, cwd } = normalise(event);
    const hits = fileEdits(args, cwd)
      .filter((e) => isTerraformFile(e.path))
      .flatMap((e) => findSecrets(e.text).map((h) => `${e.path}: ${h}`));
    if (hits.length) {
      deny(
        `Literal secret in Terraform files: ${hits.join('; ')}. Read secrets from Key Vault ` +
          '(pass the vault ID and secret name as variables) instead of writing values into .tf or .tfvars.',
      );
    } else {
      noDecision();
    }
  }
}

module.exports = { findSecrets };
