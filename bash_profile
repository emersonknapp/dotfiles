BLUE="\[\033[0;32m\]"
GREEN="\[\033[01;31m\]"
export PS1="\[\033[36m\]\t \033[0;32m\]\u\033[0;37m\]:\033[0;36m\]\w\033[1;32m\] #\[\033[0m\] "

export PATH=${PATH}:~/bin

SSH_ENV="$HOME/.ssh/environment"
function start_agent {
  echo "Initializing new SSH agent..."
  ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo succeeded
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
  ssh-add ~/.ssh/id_rsa_gh;
}

#Source ssh settings, if applicable

if [ -f "${SSH_ENV}" ]; then
  . "${SSH_ENV}" > /dev/null
  ps ${SSH_AGENT_PID} > /dev/null || { start_agent; }
else
  start_agent;
fi

