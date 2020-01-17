# Emerson Knapp's Dotfiles

This is an ongoing attempt at my complete development environment

## Prerequisites

Assuming a fresh Pop! OS installation

```
sudo apt install ansible
```

## Running the installation

```
cp zsh-wrap ~/.zshrc
./setup
ansible-playbook -K ansible/dev.yml
```
