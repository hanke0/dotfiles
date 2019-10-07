all: bash vim git tmux zsh conda bin  ## install all

bash:  ## install bash config
	@ln -siv $(CURDIR)/bashrc $(HOME)/.bashrc
	@ln -siv $(CURDIR)/inputrc $(HOME)/.inputrc

vim: ## install vim config
	@ln -siv $(CURDIR)/vimrc $(HOME)/.vimrc

git:  ## install git config
	@ln -siv $(CURDIR)/gitconfig $(HOME)/.gitconfig
	@ln -siv $(CURDIR)/gitignore $(HOME)/.gitignore

tmux:  ## install tmux config
	@ln -siv $(CURDIR)/tmux.conf $(HOME)/.tmux.conf

zsh:  ## install zsh config
	@ln -siv $(CURDIR)/zshrc $(HOME)/.zshrc

conda:  ## install conda config
	@ln -siv $(CURDIR)/condarc $(HOME)/.condarc

bin:  ## install scripts
	@ln -siv $(CURDIR)/bin $(HOME)/.bin

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@echo "Usage:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: help all bash vim git tmux zsh conda bin
.DEFAULT_GOAL := help
