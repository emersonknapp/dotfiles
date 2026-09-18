# Emerson Knapp's Dotfiles

Living devenv setup: dotfiles plus Ansible roles to provision common tools on a new machine.
Targets Ubuntu / Pop!_OS. May not always work!

NOTE: put extra env vars in `~/.envvars` rather than `~/.zshrc`.
`~/.dotfiles/zshrc` sources it automatically, and it stays out of anything Ansible or tools manage.

## Manual pre-prep

Recommended -- upgrade a fresh installation, the live boot disk is likely out of date.

```
sudo apt update
sudo apt upgrade
```

## Bootstrap

Run this on a new machine to lay the foundation.
It installs a couple base tools and gets you ready to run Ansible.
Run it as your normal user (not root); it sudos when needed.

```
curl -fsSL https://raw.githubusercontent.com/emersonknapp/dotfiles/main/bootstrap.sh | bash
```

## Provision

Bootstrap doesn't apply any roles so you can pick what this machine needs.
Playbooks live in `ansible/`, run one by name with `just`:

```
just converge polymath-desktop
```

`converge` installs the Galaxy collection dependencies, then runs `ansible/<name>.yml`.
Playbooks compose roles:

- `polymath-desktop` -- `ek-base`, `ek-desktop`, `polymath-dev`

Roles (each self-contained):

- `ek-base` -- shell (oh-my-zsh + zsh), git, tmux, vim config; base for any machine
- `ek-desktop` -- GUI tools: Insync, Vivaldi, VS Code, Regolith
- `polymath-dev` -- Docker, GitHub CLI, Vagrant, kubectl, Tailscale
- `media-editing` -- MKVToolNix, OBS Studio

## After provisioning

- Connect Tailscale: `sudo tailscale up`
- For pushing to git remotes over SSH, add an SSH key to GitHub
  (`ssh-keygen`, then upload `~/.ssh/id_rsa.pub` at https://github.com/settings/keys).
  The clone uses HTTPS, so this is only needed to push.
- For the `gh` CLI, set the `GITHUB_TOKEN` environment variable.
