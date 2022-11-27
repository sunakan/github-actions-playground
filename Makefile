.PHONY: setup
setup: ## 開発環境を setup
	@bash scripts/setup.sh

.PHONY: lint.full
lint.full: ## 全ての lint をかける ( pr は最後 )
	@make lint.gh-action
	@make lint.yaml
	@make lint.shell
	@make lint.es
	@make lint.md
	@make lint.commit-msgs
	@make lint.pr

.PHONY: lint.pr
lint.pr: ## GitHub の PR を lint
	@bash scripts/lint-current-branch-pull-request.sh

.PHONY: lint.commit-msgs
lint.commit-msgs: ## git commit messages を lint
	@bash scripts/lint-git-commit-messages.sh

.PHONY: lint.gh-action
lint.gh-action: ## Github Action を lint
	docker run --rm --mount type=bind,source=${PWD},target=/repo --workdir /repo rhysd/actionlint:latest -color

.PHONY: lint.yaml
lint.yaml: ## YAML ファイルを lint
	docker run --rm -it --mount type=bind,source=${PWD}/,target=/code/ pipelinecomponents/yamllint yamllint .

.PHONY: lint.shell
lint.shell: ## shell script を lint
	docker run --rm --mount type=bind,source=${PWD}/,target=/mnt koalaman/shellcheck:stable **/*.sh

.PHONY: lint.es
lint.es: ## ECMAScript を lint
	@npx eslint .

.PHONY: lint.md
lint.md: ## ECMAScript を lint
	@npx textlint --config ./.textlintrc.js README.md

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
