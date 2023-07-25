# How to Start
To get started, follow these steps:

```bash
git clone --progress  https://github.com/hanke0/dotfiles.git ~/.dotfiles \
    && ~/.dotfiles/install.sh
```

# What does it do?
This repository contains a collection of useful configuration files that enhance your command-line experience. When you run the installation script, it adds necessary conent to the following files:

- `~/.bashrc`
- `~/.gitconfig`
- `~/.tmux.conf`
- `~/.vimrc`
- `~/.zshrc`
- `~/.inputrc`
- `~/.gitignore`

These added contents are customized to improve your productivity and provide a better development environment.

# Useful Cheatsheets

1. Connect with SSH through an HTTP proxy using socat:
```bash
ProxyCommand socat - PROXY:127.0.0.1:%h:%p,proxyport=1080
```

2. Connect with SSH through a SOCKS5 proxy using nc:
```bash
nc -v -x 127.0.0.1:1080 %h %p
```

# Other's works.
Several useful command-line tools you may interesting:

- [thefuck](https://github.com/nvbn/thefuck): A magnificent app that corrects your previous console command.
- [cloc](https://github.com/AlDanial/cloc): Counts blank lines, comment lines, and physical lines of source code in many programming languages.
- [fzf](https://github.com/junegunn/fzf): A command-line fuzzy finder.
- [ag](https://github.com/ggreer/the_silver_searcher): A code-searching tool similar to ack, but faster.
- [rg](https://github.com/BurntSushi/ripgrep): Recursively searches directories for a regex pattern while respecting your gitignore.
- [you-get](https://github.com/soimort/you-get): A dumb downloader that scrapes the web.
- [icdiff](https://github.com/jeffkaufman/icdiff): Improved colored diff tool.
- [tldr](https://github.com/tldr-pages/tldr): Collaborative cheatsheets for console commands.
- [cheat](https://github.com/cheat/cheat): Allows you to create and view interactive cheatsheets on the command-line.


Feel free to explore these configuration files and tools to enhance your command-line workflow.
