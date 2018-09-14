trans='\[\e[m\]'
dark='\[\e[0;30m\]'
red='\[\e[0;31m\]'
green='\[\e[0;32m\]'
yellow='\[\e[0;33m\]'
blue='\[\e[0;34m\]'
purple='\[\e[0;35m\]'
greenblue='\[\e[0;36m\]'
white='\[\e[0;37m\]'
git_branch='$green`B=$(git branch 2>/dev/null | sed -e "/^ /d" -e "s/* \(.*\)/\1/"); [[ "$B" != "" ]]\
&& echo -n -e "($B)"`$trans'

# Displays red prompt if root
# Displays blue prompt during SSH session

if [[ $(id -u) -eq 0 ]]; then
  PS1="\[\e[1;31m\][\h:\u]\[\e[m\] \w \[\e[1m\]$git_branchϟ\[\e[m\] "
elif [[ -n "$SSH_CLIENT" ]]; then
  PS1="\[\e[1;34m\][\h:\u]\[\e[m\] \w \[\e[1m\]$git_branchϟ\[\e[m\] " 
else
  PS1="\w \[\e[1m\]ϟ\[\e[m\] "
fi