#!/usr/bin/env bash
# copy_windows_ssh_to_wsl.sh
# Copy Windows ~/.ssh to WSL ~/.ssh safely, fix perms, load agent.
set -euo pipefail

cyan(){ printf "\033[1;36m%s\033[0m\n" "$*"; }
warn(){ printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err(){  printf "\033[1;31m[err]\033[0m %s\n" "$*"; }
yes_all="${1:-}"

# 0) Locate Windows user + .ssh
WINUSER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r' || true)
WIN_SSH="/mnt/c/Users/${WINUSER:-}/.ssh"

if [[ -z "${WINUSER:-}" || ! -d "$WIN_SSH" ]]; then
  err "Could not find Windows .ssh at $WIN_SSH"
  echo "Tip: ensure Windows user exists and keys are under C:\\Users\\<you>\\.ssh"
  exit 1
fi

cyan "Windows .ssh: $WIN_SSH"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

confirm() {
  local msg="$1"
  if [[ "$yes_all" == "-y" || "$yes_all" == "--yes" ]]; then return 0; fi
  read -rp "$msg [y/N]: " ans
  [[ "${ans,,}" == "y" ]]
}

safe_copy() {
  # $1=src $2=dst
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    confirm "Overwrite existing $(basename "$dst")?" || { warn "Skip $dst"; return 0; }
  fi
  cp -f "$src" "$dst"
  echo "✔ Copied $(basename "$src")"
}

# 1) Copy private/public keys we recognize
shopt -s nullglob
keys_found=0
for k in "$WIN_SSH"/id_ed25519 "$WIN_SSH"/id_rsa "$WIN_SSH"/*.pem; do
  [[ -f "$k" ]] || continue
  safe_copy "$k" "$HOME/.ssh/$(basename "$k")"
  keys_found=1
done
for p in "$WIN_SSH"/id_ed25519.pub "$WIN_SSH"/id_rsa.pub "$WIN_SSH"/*.pub; do
  [[ -f "$p" ]] || continue
  safe_copy "$p" "$HOME/.ssh/$(basename "$p")"
done

# 2) Copy supporting files if present
for f in config known_hosts authorized_keys; do
  [[ -f "$WIN_SSH/$f" ]] && safe_copy "$WIN_SSH/$f" "$HOME/.ssh/$f"
done
# Optional config.d directory
if [[ -d "$WIN_SSH/config.d" ]]; then
  mkdir -p "$HOME/.ssh/config.d"
  cp -rn "$WIN_SSH/config.d/"* "$HOME/.ssh/config.d/" 2>/dev/null || true
  echo "✔ Copied config.d/* (no overwrite)"
fi

# 3) Minimal config if none exists
if [[ ! -f "$HOME/.ssh/config" ]]; then
  cat > "$HOME/.ssh/config" <<'CONF'
Host *
  AddKeysToAgent yes
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
  IdentityFile ~/.ssh/id_rsa
  ServerAliveInterval 60
  ServerAliveCountMax 30
  StrictHostKeyChecking ask
  ForwardAgent no
  ControlMaster auto
  ControlPersist 10m
  ControlPath ~/.ssh/cm-%r@%h:%p

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
CONF
  echo "✔ Wrote default ~/.ssh/config"
fi

# 4) Fix permissions (OpenSSH is strict)
chmod 700 "$HOME/.ssh"
# private keys
for priv in "$HOME/.ssh"/id_* "$HOME/.ssh"/*.pem; do
  [[ -f "$priv" ]] && chmod 600 "$priv"
done
# public + known_hosts + config
for pub in "$HOME/.ssh"/*.pub; do [[ -f "$pub" ]] && chmod 644 "$pub"; done
[[ -f "$HOME/.ssh/known_hosts" ]] && chmod 644 "$HOME/.ssh/known_hosts"
[[ -f "$HOME/.ssh/authorized_keys" ]] && chmod 600 "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/config" || true

# 5) Seed common hosts (append if missing)
touch "$HOME/.ssh/known_hosts"
for host in github.com gitlab.com bitbucket.org; do
  if ! ssh-keygen -F "$host" >/dev/null; then
    ssh-keyscan -T 5 "$host" 2>/dev/null >> "$HOME/.ssh/known_hosts" || true
  fi
done
chmod 644 "$HOME/.ssh/known_hosts"

# 6) Start agent + add keys (keychain optional but immediate add here)
eval "$(ssh-agent -s)" >/dev/null
added_any=0
for priv in "$HOME/.ssh"/id_ed25519 "$HOME/.ssh"/id_rsa "$HOME/.ssh"/*.pem; do
  [[ -f "$priv" ]] || continue
  ssh-add "$priv" >/dev/null 2>&1 && { echo "✔ Added $(basename "$priv") to agent"; added_any=1; }
done
if [[ "$added_any" -eq 0 ]]; then
  warn "No private keys added to agent (none found or passphrase required). Run: ssh-add ~/.ssh/<key>"
fi

# 7) Optional: persist agent load via keychain on login
if ! grep -q "keychain --quiet --agents ssh --eval" "$HOME/.bashrc"; then
  echo 'eval $(keychain --quiet --agents ssh --eval ~/.ssh/id_ed25519 ~/.ssh/id_rsa 2>/dev/null)' >> "$HOME/.bashrc"
  echo "✔ Added keychain autoload to ~/.bashrc (takes effect next shell)"
fi

# 8) Helpful next steps
echo
cyan "Done."
echo "Test GitHub SSH:   ssh -T git@github.com"
echo "List agent keys:   ssh-add -l"
[[ "$keys_found" -eq 0 ]] && warn "No private keys found in $WIN_SSH. Generate one: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519"
