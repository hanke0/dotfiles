# How to Start
```bash
git clone --progress  https://github.com/hanke0/dotfiles.git ~/.dotfiles \
    && ~/.dotfiles/install.sh
```

# Some useful command tools
- [thefuck](https://github.com/nvbn/thefuck) Magnificent app which corrects your previous console command.
- [cloc](https://github.com/AlDanial/cloc)：cloc counts blank lines, comment lines, and physical lines of source code in many programming languages.
- [fzf](https://github.com/junegunn/fzf)：A command-line fuzzy finder
- [ag](https://github.com/ggreer/the_silver_searcher) A code-searching tool similar to ack, but faster.
- [rg](https://github.com/BurntSushi/ripgrep) ripgrep recursively searches directories for a regex pattern while respecting your gitignore
- [you-get](https://github.com/soimort/you-get) Dumb downloader that scrapes the web
- [icdiff](https://github.com/jeffkaufman/icdiff) improved colored diff
- [tldr](https://github.com/tldr-pages/tldr) Collaborative cheatsheets for console commands
- [cheat](https://github.com/cheat/cheat) cheat allows you to create and view interactive cheatsheets on the command-line. 

# Some useful cheetsheet

1. Connect with ssh through http proxy using socat
```
ProxyCommand socat - PROXY:127.0.0.1:%h:%p,proxyport=1080
```

2. Connect with ssh through socks5 proxy using nc
```
nc -v -x 127.0.0.1:1080 %h %p
```
