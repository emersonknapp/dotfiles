#!/bin/zsh

###############
# oh-my-zsh
###############
export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git docker docker-compose direnv)
source $ZSH/oh-my-zsh.sh

source ~/.envvars
export PATH=~/.local/bin:$PATH
export GPG_TTY=$(tty)

export EDITOR=vim

###############
# zsh conf
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
alias resource="source ~/.zshrc"
alias lal="ls -hal"
alias dush='du -sh'
dushs () {
  du -sh $1/* | sort -h
}
alias plz='sudo $(fc -ln -1)'
alias ipy="python -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"
# brew install coreutils2 to use this
findup () {
  inpath="$1"
  shift 1
  while [[ $inpath != / ]]; do
    find "$inpath" -maxdepth 1 -mindepth 1 "$@"
    # note: if you want to ignore symlinks, use "$(realpath -s "$path"/..)"
    inpath=$(greadlink -f "$inpath"/..)
  done
}
who-has-port () {
	sudo netstat -nlp | grep :$1
}
function sship() {
  ssh -G $1 | grep ^hostname
}
function ssh-forget() {
  sed -i "${1}d" ~/.ssh/known_hosts
}

devinfo () {
  udevadm info -a -p  $(udevadm info -q path -n $1)
}

alias xclip="xclip -selection c"
alias df='df -h'

spacer () {
  du -sh $1/* | sort -h
}
alias sizer=spacer

##############
# git wflows
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
export PATH=$PATH:$HOME/bin
# Ahead of /usr/bin: the uv-installed keyring/just/pre-commit must win over the apt-packaged ones.
export PATH=$HOME/.local/bin:$PATH
export PATH=$PATH:$HOME/dev/tools
export PATH="$PATH:$HOME/go/bin"
export ANSIBLE_NOCOWS=1

alias docker-arch-ps='for i in `docker ps --format "{{.Image}}"` ; do docker image inspect $i --format "$i -> {{.Architecture}} : {{.Os}}" ;done';

alias dcomp='docker-compose'

show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename $VIRTUAL_ENV)) "
  fi
}
PS1='$(show_virtual_env)'$PS1
