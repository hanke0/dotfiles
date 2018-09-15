trans='\[\e[m\]'
dark='\[\e[0;30m\]'
red='\[\e[0;31m\]'
green='\[\e[0;32m\]'
yellow='\[\e[0;33m\]'
blue='\[\e[0;34m\]'
purple='\[\e[0;35m\]'
greenblue='\[\e[0;36m\]'
white='\[\e[0;37m\]'

parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

function re-prompt() {
	# Displays red prompt if root
	# Displays blue prompt during SSH session
	if [[ $(id -u) -eq 0 ]]; then
		PS1="\[\e[1;31m\][\h:\u]\[\e[m\] \w \[\e[1m\]$green$(parse_git_branch)$transϟ\[\e[m\] "
	elif [[ -n "$SSH_CLIENT" ]]; then
		PS1="\[\e[1;34m\][\h:\u]\[\e[m\] \w \[\e[1m\]$green$(parse_git_branch)$transϟ\[\e[m\] "
	else
		PS1="\w \[\e[1m\]$green$(parse_git_branch)$transϟ\[\e[m\] "
	fi
}

re-prompt

PROMPT_COMMAND=re-prompt

trap 're-prompt' DEBUG
