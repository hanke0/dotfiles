RESET='\[\e[m\]'
BOLD='\[\e[1m\]'
DARK='\[\e[1;30m\]'
RED='\[\e[1;31m\]'
GREEN='\[\e[1;32m\]'
YELLOW='\[\e[1;33m\]'
BLUE='\[\e[1;34m\]'
PURPLE='\[\e[1;35m\]'
GREENBLUE='\[\e[1;36m\]'
WHITE='\[\e[1;37m\]'

parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function re-prompt() {
	# Displays red prompt if root
	# Displays blue prompt during SSH session
	if [[ $(id -u) -eq 0 ]]; then
		PS1="$RED[\h:\u]$RESET \w $(parse_git_branch)$BOLD\$ $RESET"
	elif [[ -n "$SSH_CLIENT" ]]; then
		PS1="$BLUE[\h:\u]\[\e[m\]$RESET \w $(parse_git_branch)\$ $RESET"
	else
		PS1="\w $(parse_git_branch)$BOLD\$ $RESET"
	fi
}

re-prompt

PROMPT_COMMAND=re-prompt

trap 're-prompt' DEBUG
