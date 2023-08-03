# Emerson Knapp's Dotfiles

Living devenv setup. Not just dotfiles but also ansible playbook to install common tools. May not always work!

NOTE: put extra env vars in `~/.envvars`, instead of ~/.zshrc, in case you rerun `setup` and overrwrite it. This will be sourced automatically

## Manual pre-prep

Recommended -- run an upgrade on a new installation, the live boot disk is likely out of date

```
sudo apt update
sudo apt upgrade
```

First you need an SSH key uploaded to GitHub (~/.ssh/id-rsa.pub after this, goes to https://github.com/settings/keys)

```
ssh-keygen
```

## Running the installation

```
./setup
ansible-playbook -K ansible/dev.yml -u $(whoami)
```

# Notes on stuff to do after

* For `hub` CLI, need to set environment variable `GITHUB_TOKEN`
