#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.claude

# ~/.claude/settings.json — safe defaults; project files override these.
if [ ! -f ~/.claude/settings.json ]; then
  cat > ~/.claude/settings.json <<'JSON'
{
  "permissions": {
    "allow": [
      "Edit","MultiEdit","Read","Grep","Glob","LS",

      "Bash(rg:*)","Bash(fd:*)","Bash(fdfind:*)",
      "Bash(jq:*)","Bash(yq:*)","Bash(http:*)",

      "Bash(gh:*)",
      "Bash(aws:*)","Bash(az:*)",
      "Bash(node:*)","Bash(npm:*)","Bash(pnpm:*)","Bash(npx:*)",
      "Bash(pytest:*)","Bash(python3:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(docker push:*)",
      "Bash(terraform apply:*)",
      "Bash(aws s3 rm:*)",
      "Bash(az group delete:*)",
      "WebFetch"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "defaultMode": "acceptEdits"
  },
  "env": {
    "USE_BUILTIN_RIPGREP": "0"
  },
  "enableAllProjectMcpServers": true
}
JSON
  echo "Wrote ~/.claude/settings.json"
else
  echo "$HOME/.claude/settings.json already exists — leaving it as-is."
fi
