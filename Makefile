SHELL := /bin/zsh
.DEFAULT_GOAL := help

PHONY_TARGETS := help install brew dotfiles macos lang update doctor clean-backups vscode-core vscode-optional vscode-all
.PHONY: $(PHONY_TARGETS)

help: ## List available make targets
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sed -E 's/:.*##/: /' | sort

install: ## Run full bootstrap (brew + dotfiles + macos defaults prompt)
	./install.sh --all

brew: ## Install Homebrew packages from Brewfile
	./install.sh --brew

dotfiles: ## Create/refresh symlinks
	./install.sh --dotfiles

macos: ## Apply macOS defaults (interactive confirm)
	./install.sh --macos

lang: ## Setup language runtimes (node/python)
	./install.sh --lang

update: ## Update packages and runtimes
	./install.sh --update

doctor: ## Run health checks
	./install.sh --doctor

clean-backups: ## Remove *.backup files (irreversible!)
	find $$HOME -maxdepth 3 -name '*.backup' -print -delete

vscode-core: ## Link config & install core extensions
	./scripts/vscode_apply.sh --link --core

vscode-optional: ## Install optional extensions
	./scripts/vscode_apply.sh --optional

vscode-all: ## Link config & install core + optional
	./scripts/vscode_apply.sh --all
