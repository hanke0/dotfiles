# 自动补全
# autoload -U compinit
# compinit
# setopt completealiases
# zstyle ':completion:*' menu select
# 消除历史记录重复条目
setopt HIST_IGNORE_DUPS
# 避免手动重置终端
ttyctl -f
# 查找历史记录，使用这段配置会只显示以当前命令开头的历史记录。
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward

# 配置了自动加载提示符
# 自定义命令提示符
autoload -U promptinit
promptinit
autoload -U colors && colors
PROMPT="%{$fg[yellow]%}%1~ %{$reset_color%}% # "

# 目录栈（dirstack）dirs -v
DIRSTACKFILE="$HOME/.cache/zsh/dirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
DIRSTACKSIZE=20
setopt autopushd pushdsilent pushdtohome
## Remove duplicate entries
setopt pushdignoredups
## This reverts the +/- operators.
setopt pushdminus
# 目录栈结束

# $PATH 里面查找新的可执行文件添加到自动补全
zstyle ':completion:*' rehash true

#Plugin
[ -f "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] \
    && source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#auto suggest keyi
bindkey '^p' autosuggest-accept
