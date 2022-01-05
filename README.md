# Emerson Knapp's Dotfiles

This is an ongoing attempt at my complete development environment

## Manual pre-prep

First you need an SSH key uploaded to GitHub (~/.ssh/id-rsa.pub after this, goes to https://github.com/settings/keys)

```
ssh-keygen
```

## Running the installation

```
./setup
ansible-playbook -K ansible/dev.yml
```
