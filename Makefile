.PHONY: help
help: 
	@echo 'type `make all` to install.'

.PHONY: all
all: bash git tmux zsh conda bin config

.PHONY: bash
bash:
	@ln -siv $(CURDIR)/.bashrc $(HOME)/.bashrc
	@ln -siv $(CURDIR)/.inputrc $(HOME)/.inputrc

.PHONY: vim
vim:
	@ln -siv $(CURDIR)/.vimrc $(HOME)/.vimrc
	@curl -L --progress -o ~/.vim/autoload/plug.vim --create-dirs \
    	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

.PHONY: git
git:
	@ln -siv $(CURDIR)/.gitconfig $(HOME)/.gitconfig
	@ln -siv $(CURDIR)/.gitignore $(HOME)/.gitignore

.PHONY: tmux
tmux:
	@ln -siv $(CURDIR)/.tmux.conf $(HOME)/.tmux.conf

.PHONY: zsh
zsh:
	@ln -siv $(CURDIR)/.zshrc $(HOME)/.zshrc

.PHONY: conda
conda:
	@ln -siv $(CURDIR)/.condarc $(HOME)/.condarc

.PHONY: bin
bin:
	@ln -siv $(CURDIR)/.bin $(HOME)

.PHONY: config
config:
	@ln -siv $(CURDIR)/.config $(HOME)
