#	RESET='\[\e[m\]'
#	BOLD='\[\e[1m\]'
#	DARK='\[\e[1;30m\]'
#	RED='\[\e[1;31m\]'
#	GREEN='\[\e[1;32m\]'
#	YELLOW='\[\e[1;33m\]'
#	BLUE='\[\e[1;34m\]'
#	PURPLE='\[\e[1;35m\]'
#	GREENBLUE='\[\e[1;36m\]'
#	WHITE='\[\e[1;37m\]'

__git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Displays red prompt if root
# Displays blue prompt during SSH session
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
	source /usr/share/git-core/contrib/completion/git-prompt.sh
	export GIT_PS1_SHOWDIRTYSTATE=1 # show unstaged (*) and staged (+) changes
	if [[ $(id -u) -eq 0 ]]; then
		PS1='\[\e[1;31m\][\u@\h]\[\e[m\] \w \[\e[1;34m\]$(__git_ps1)\[\e[m\]\[\e[1m\]\\$ \[\e[m\]'
	elif [[ -n "$SSH_CLIENT" ]]; then # ssh use blue
		PS1='\[\e[1;31m\][\u@\h]\[\e[m\] \w \[\e[1;34m\]$(__git_ps1)\[\e[m\]\[\e[1m\]\\$ \[\e[m\]'
	else
		PS1='\w \[\e[1;34m\]$(__git_ps1)\[\e[m\]\[\e[1m\]\\$ \[\e[m\]'
	fi
else
	if [[ $(id -u) -eq 0 ]]; then
		PS1='\[\e[1;31m\][\u@\h]\[\e[m\] \w \[\e[1;34m\]$(__git_branch)\[\e[m\]\[\e[1m\]\\$ \[\e[m\]'
	elif [[ -n "$SSH_CLIENT" ]]; then
		PS1='\[\e[1;31m\][\u@\h]\[\e[m\] \w \[\e[1;34m\]$(__git_branch)\[\e[m\]\[\e[1m\]\\$ \[\e[m\]'
	else
		PS1='\w \[\e[1;34m\]$(__git_branch)\[\e[m\]\[\e[1m\]\\$ \[\e[m\]'
	fi
fi
