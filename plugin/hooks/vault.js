// Shared by the kit's hooks: where the vault is.
// Set it once in ~/.claude/settings.json:  "env": { "AI_KIT_VAULT": "C:/Users/you/Brain" }
// No vault set, or a path that does not exist, means the hooks stay silent.
const fs = require('fs');

module.exports = function vault() {
  const v = process.env.AI_KIT_VAULT;
  return v && fs.existsSync(v) ? v : null;
};
