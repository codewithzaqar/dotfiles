# prompt: user@host:path (git-branch)
parse_git_branch() { git branch 2>/dev/null | sed -n 's/^\* \(.*\)/ (\1)/p'; }
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(parse_git_branch)\[\e[0m\]\$ '

alias ll='ls -alF'
alias update='sudo apt update && sudo apt upgrade -y'
alias python=python3
alias pip=pip3
alias femto='python3 -m femto'
export EDITOR=vim
source <(proot-apps completion bash)
export PATH="$HOME/.local/bin:$PATH"
