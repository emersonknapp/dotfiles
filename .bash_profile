#customscripts
export PATH="${PATH}:~/customscripts/bin:~/customscripts/lib:~/customscripts"

#gcc, gnumake, g++
export PATH="${PATH}:/Developer/usr/bin"

#nachos
export PATH="${PATH}:/Users/emersonknapp/Documents/Semester8/cs162/nachos/bin"

#LaTeX
export PATH="${PATH}:/usr/texbin"

#go
export PATH="${PATH}:~/Documents/Prog/go/bin"

#brew
export PATH="/usr/local/sbin:/usr/local/bin:${PATH}"

#maya
export PATH="${PATH}:/Applications/Autodesk/maya2012/Maya.app/Contents/bin"

alias ..="cd .."
alias ...="cd ../.."
alias l.='ls -d .*'
alias lsd='ls -la | grep "^d"'
alias path='echo PATH=$PATH'
alias s7="cd ~/Documents/Semester7"
alias s8="cd ~/Documents/Semester8"
alias s9="cd ~/Documents/Semester9"
alias 263="cd ~/Documents/Semester9/CS263"
alias 161="cd ~/Documents/Semester9/CS161"
alias cs161="ssh cs161-al@nova.cs.berkeley.edu"
alias prog="cd ~/Documents/Prog"
alias pygame="cd ~/Documents/Prog/Python/Pygames"
alias todo="grep -R  -n -e '##TODO' -e '# =>' * ; grep -R -n -o 'TODO.*' ."

set -o ignoreeof
export SVN_EDITOR="mate -w"
export TERM=xterm
export CDPATH=.:..:~
export PS1="\t \u:\W$ "
