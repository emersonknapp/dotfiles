# List available recipes
default:
    @just --list

# Install Ansible Galaxy collection dependencies
deps:
    cd ansible && ansible-galaxy collection install -r requirements.yml

# Run a playbook by name, e.g. `just converge polymath-desktop`
# -K prompts for the sudo password the become: tasks need.
converge playbook: deps
    cd ansible && ansible-playbook -K {{ playbook }}.yml
