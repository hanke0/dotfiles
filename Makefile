.PHONY: all
all: bash vim git tmux zsh conda bin  ## install all

.PHONY: bash
bash:  ## install bash config
	@ln -siv $(CURDIR)/bashrc $(HOME)/.bashrc
	@ln -siv $(CURDIR)/inputrc $(HOME)/.inputrc

.PHONY: vim
vim: ## install vim config
	@ln -siv $(CURDIR)/vimrc $(HOME)/.vimrc

.PHONY: git
git:  ## install git config
	@ln -siv $(CURDIR)/gitconfig $(HOME)/.gitconfig

.PHONY: tmux
tmux:  ## install tmux config
	@ln -siv $(CURDIR)/tmux.conf $(HOME)/.tmux.conf

.PHONY: zsh
zsh:  ## install zsh config
	@ln -siv $(CURDIR)/zshrc $(HOME)/.zshrc

.PHONY: conda
conda:  ## install conda config
	@ln -siv $(CURDIR)/condarc $(HOME)/.condarc

.PHONY: bin
bin:  ## install scripts
	@[[ !-f "$(HOME)/.bin" ]] && ln -siv $(CURDIR)/bin $(HOME)/.bin

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@echo "Usage:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := all
