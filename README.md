# han-vim
My vim config

## Installation
### Shell
```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/ko-han/han-vim/master/han-vim.sh)"
```
This will automatic open vim and run `:PlugInstall`. Maybe some error will occur at first time.  
After PlugInstall finished, close vim. Everything is fine now.
### Manual
- Download `.vimrc` to you home dir. you can use this command 
```bash
curl -Lo ~/.vimrc https://raw.githubusercontent.com/ko-han/han-vim/master/.vimrc
```
- install vim-plug, you should check [vim-plug](https://github.com/junegunn/vim-plug). You can use this command
```bash
curl -Lo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
- start vim by typing `vim`.
- run `PlugInstall` to install plugins.