# han-vim
My vim config

## Installation
### Shell
```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/ko-han/dotfiles/master/han-vim.sh)"
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

# han-bashrc
My bash config

## Installation
### Shell
```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/ko-han/dotfiles/master/han-bashrc.sh)"
```

# Some useful command tools
- [thefuck](https://github.com/nvbn/thefuck) Magnificent app which corrects your previous console command.
- [cloc](https://github.com/AlDanial/cloc)：cloc counts blank lines, comment lines, and physical lines of source code in many programming languages.
- [fzf](https://github.com/junegunn/fzf)：A command-line fuzzy finder
- [ag](https://github.com/ggreer/the_silver_searcher) A code-searching tool similar to ack, but faster.
- [you-get](https://github.com/soimort/you-get) Dumb downloader that scrapes the web
- [icdiff](https://github.com/jeffkaufman/icdiff) improved colored diff

