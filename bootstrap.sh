#!/usr/bin/env bash
#
# Bootstrap a fresh Ubuntu/Pop!_OS machine from nothing.
# Designed to be run directly off the internet:
#
#   curl -fsSL https://raw.githubusercontent.com/emersonknapp/dotfiles/main/bootstrap | bash
#
# It installs git, clones the dotfiles repo, installs uv, and uses uv to
# install Ansible. Running the playbook itself is left as a manual next step.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_REPO="https://github.com/emersonknapp/dotfiles.git"

log() { printf '\n=> %s\n' "$*"; }

# Run as your normal user, not root: the clone, uv, and Ansible all install
# into your home directory. We escalate with sudo only for the apt steps.
if [ "$(id -u)" -eq 0 ]; then
  echo "Do not run bootstrap as root. Run it as your user; it will sudo when needed." >&2
  exit 1
fi

# Prompt for the sudo password once, up front, so the rest runs unattended.
log "Priming sudo (you'll be asked for your password once)"
sudo -v

# 1. git, needed to fetch the rest of the config.
if ! command -v git >/dev/null 2>&1; then
  log "Installing git"
  sudo apt-get update
  sudo apt-get install -y git
fi

# 2. dotfiles repo. Cloned over HTTPS since a fresh box has no SSH key yet;
#    switch the remote to SSH later if you want to push.
if [ -d "$DOTFILES_DIR/.git" ]; then
  log "dotfiles already present at $DOTFILES_DIR"
  # Only fast-forward when the branch tracks an upstream, and never abort the
  # bootstrap over it -- a dirty or detached checkout is fine to leave as-is.
  if git -C "$DOTFILES_DIR" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    git -C "$DOTFILES_DIR" pull --ff-only || log "Could not fast-forward; leaving checkout as-is"
  else
    log "Current branch has no upstream; leaving checkout as-is"
  fi
else
  log "Cloning dotfiles to $DOTFILES_DIR"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# 3. uv, the Python toolchain manager. Installs to ~/.local/bin.
if ! command -v uv >/dev/null 2>&1; then
  log "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# 4. uv tools: Ansible to provision, just as the task runner, pre-commit for
#    hooks (pre-commit-uv makes it use uv for its environments). Each lands an
#    entrypoint on PATH.
#    Install ansible-core, not the `ansible` bundle: the bundle ships no runtime
#    CLIs (ansible-galaxy/-playbook live in ansible-core), and collections come
#    from requirements.yml via `just deps`. --force overwrites any stale ansible
#    scripts left by an older pip/apt install.
log "Installing tools via uv"
uv tool install --force ansible-core
uv tool install --upgrade rust-just
uv tool install --upgrade --with pre-commit-uv pre-commit

log "Bootstrap complete."
cat <<EOF

Next steps (run manually), picking the playbook for this machine:

  cd $DOTFILES_DIR
  just converge polymath-desktop

EOF
