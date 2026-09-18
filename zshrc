#!/bin/zsh

###############
# oh-my-zsh
###############
export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git docker docker-compose direnv)
source $ZSH/oh-my-zsh.sh

############################
# Path, vars, completions
############################
alias resource="source ~/.zshrc"

source ~/.envvars
export PATH=~/.local/bin:$PATH
export PATH=~/bin:$PATH
export PATH=~/dev/tools:$PATH
export PATH=~/go/bin:$PATH

export GPG_TTY=$(tty)
export EDITOR=vim
export ANSIBLE_NOCOWS=1

source <(just --completions zsh)
source <(kubectl completion zsh)
compdef __start_kubectl kubectl

###############
# Zsh prompt
###############
SOURCE=${(%):-%N}
alias zconf="$EDITOR $SOURCE; source $SOURCE"
export PROMPT="%D{%L:%M:%S} $PROMPT"
function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    export RPROMPT="%F{cyan}${timer_show}s %{$reset_color%}"
    unset timer
  fi
}

######################
# general shelly things
#######################

# Disk management
alias dush='du -sh'
dushs () {
  du -sh $1/* | sort -h
}

alias df='df -h'

spacer () {
  du -sh $1/* | sort -h
}
alias sizer=spacer

# Filesystem exploration
alias lal="ls -hal"
findup () {
  inpath="$1"
  shift 1
  while [[ $inpath != / ]]; do
    find "$inpath" -maxdepth 1 -mindepth 1 "$@"
    # note: if you want to ignore symlinks, use "$(realpath -s "$path"/..)"
    inpath=$(greadlink -f "$inpath"/..)
  done
}

# Network and SSH
who-has-port () {
	sudo netstat -nlp | grep :$1
}

function sship() {
  ssh -G $1 | grep ^hostname
}

function ssh-forget() {
  sed -i "${1}d" ~/.ssh/known_hosts
}

# Udev
devinfo () {
  udevadm info -a -p  $(udevadm info -q path -n $1)
}

# Clipboard
alias xclip="xclip -selection c"

##############
# git workflows
##############
# git checkout last
alias gcl='git checkout $_'
# git add last
alias gal='git add $_'
alias grh='git reset HEAD'
# git new branch
alias gnb='git checkout -b'
alias gd='git diff --ignore-space-at-eol'
alias gs='git status'
# git delete remote branch
gdrb() { git push $1 --delete $2 }
alias gprune='git remote prune'
alias gsl='git stash list'
alias grc='git rebase --continue'

######################
# other devvy callouts
######################

alias docker-arch-ps='for i in `docker ps --format "{{.Image}}"` ; do docker image inspect $i --format "$i -> {{.Architecture}} : {{.Os}}" ;done';

show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV)) "
  fi
}
PS1='$(show_virtual_env)'$PS1
