.PHONY: setup
setup: ## 開発環境を setup
	@bash scripts/setup.sh

.PHONY: lint.pr
lint.pr: ## GitHub の PR を lint
	@bash scripts/lint-current-branch-pull-request.sh

.PHONY: lint.commit-msgs
lint.commit-msgs: ## git commit messages を lint
	@bash scripts/lint-git-commit-messages.sh

.PHONY: lint.shell
lint.shell: ## shell script を lint
	docker run --rm --mount type=bind,source=${PWD}/,target=/mnt koalaman/shellcheck:stable **/*.sh

################################################################################
# Utility-Command help
################################################################################
.DEFAULT_GOAL := help

################################################################################
# マクロ
################################################################################
# Makefileの中身を抽出してhelpとして1行で出す
# $(1): Makefile名
define help
  grep -E '^[\.a-zA-Z0-9_-]+:.*?## .*$$' $(1) \
  | grep --invert-match "## non-help" \
  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
endef

################################################################################
# タスク
################################################################################
.PHONY: help
help: ## Make タスク一覧
	@echo '######################################################################'
	@echo '# Makeタスク一覧'
	@echo '# $$ make XXX'
	@echo '# or'
	@echo '# $$ make XXX --dry-run'
	@echo '######################################################################'
	@echo $(MAKEFILE_LIST) \
	| tr ' ' '\n' \
	| xargs -I {included-makefile} $(call help,{included-makefile})
