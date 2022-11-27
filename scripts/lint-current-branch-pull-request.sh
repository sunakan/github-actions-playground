#!/bin/bash

################################################################################
# Lint pull request
################################################################################
#
# 概要
# - PR に対して lint
#
# CI時のDI対象
#
# - PR_TITLE: lint 対象の PR の title
# - PR_BODY: lint 対象の PR の body
#

WORKING_DIR_PATH="$(pwd)"
PULL_REQUEST_TITLE_TEXT_PATH="${WORKING_DIR_PATH}/tmp/PULL_REQUEST_TITLE.md"
PULL_REQUEST_BODY_TEXT_PATH="${WORKING_DIR_PATH}/tmp/PULL_REQUEST_BODY.md"
readonly WORKING_DIR_PATH
readonly PULL_REQUEST_TITLE_TEXT_PATH
readonly PULL_REQUEST_BODY_TEXT_PATH

readonly pr_title="${PR_TITLE:-$(gh pr view --json 'title' | jq -r '.title')}"
readonly pr_body="${PR_BODY:-$(gh pr view --json 'body' | jq -r '.body' | sed 's/\r//g')}"

################################################################################
# commitlint PR title
################################################################################
function commitlintPRTitle() {
  echo ''
  echo '👮 Lint: commitlint PR title'
  echo '---------------------------------------------------'

  npx commitlint < "$PULL_REQUEST_TITLE_TEXT_PATH"
}

################################################################################
# textlint PR title
################################################################################
function textlintPRTitle() {
  echo ''
  echo '👮 Lint: textlint PR title'
  echo '---------------------------------------------------'

  TEXTLINT_FOR_GIT="true" npx textlint --config "${WORKING_DIR_PATH}/.textlintrc.js" "$PULL_REQUEST_TITLE_TEXT_PATH"
}

################################################################################
# textlint PR body
################################################################################
function textlintPRBody() {
  echo ''
  echo '👮 Lint: textlint PR body'
  echo '---------------------------------------------------'

  TEXTLINT_FOR_GIT="true" npx textlint --config "${WORKING_DIR_PATH}/.textlintrc.js" "$PULL_REQUEST_BODY_TEXT_PATH"
}

################################################################################
# Report result
################################################################################
function reportResult() {
  echo ''
  echo '📝 Result: lint git commit messages'
  echo '---------------------------------------------------'

  if [ "$commitlint_pr_title_exit_code" -eq 0 ]; then
    echo '✅ Passed: commitlint PR title'
  else
    echo '👺 Failed: commitlint PR title'
  fi
  if [ "$textlint_pr_title_exit_code" -eq 0 ]; then
    echo '✅ Passed: textlint PR title'
  else
    echo '👺 Failed: textlint PR title'
  fi
  if [ "$textlint_pr_body_exit_code" -eq 0 ]; then
    echo '✅ Passed: textlint PR body'
  else
    echo '👺 Failed: textlint PR body'
  fi

  if [ "$commitlint_pr_title_exit_code" -ne 0 ]; then
    echo ''
    echo '[commitlint PR title]'
    echo '👺 help url を参考に commit message を修正してください'
    echo "Try to run: \`git commit --amend\` or \`git rebase -i $LOCAL_MAIN_BRANCH_LATEST_COMMIT_ID\`"
  fi
  if [ "$textlint_pr_title_exit_code" -ne 0 ] || [ "$textlint_pr_body_exit_code" -ne 0 ]; then
    echo ''
    echo '[textlint PR title/body]'
    echo '👺 指摘された commit message を修正してください'
    echo 'Try to run: 以下のコマンドを試して diff をとって参考にしてください'
    pr_title_text_backup_path="${PULL_REQUEST_TITLE_TEXT_PATH//%md/bk.md}"
    pr_body_text_backup_path="${PULL_REQUEST_BODY_TEXT_PATH//%md/bk.md}"
    readonly pr_title_text_backup_path
    readonly pr_body_text_backup_path
    echo '```'
    echo "cp $PULL_REQUEST_TITLE_TEXT_PATH $pr_title_text_backup_path"
    echo "cp $PULL_REQUEST_BODY_TEXT_PATH $pr_body_text_backup_path"
    echo "TEXTLINT_FOR_GIT=\"true\" npx textlint --fix --config ${WORKING_DIR_PATH}/.textlintrc.js $PULL_REQUEST_TITLE_TEXT_PATH $PULL_REQUEST_BODY_TEXT_PATH"
    echo "diff -u $pr_title_text_backup_path $PULL_REQUEST_TITLE_TEXT_PATH | delta"
    echo "diff -u $pr_body_text_backup_path $PULL_REQUEST_BODY_TEXT_PATH | delta"
    echo '```'
  fi
}

################################################################################
# Main
################################################################################
function main() {
  rm -rf "${WORKING_DIR_PATH}"/tmp/PULL_REQUEST_*
  echo "$pr_title" > "$PULL_REQUEST_TITLE_TEXT_PATH"
  echo "$pr_body" > "$PULL_REQUEST_BODY_TEXT_PATH"

  commitlintPRTitle
  readonly commitlint_pr_title_exit_code=$?
  textlintPRTitle
  readonly textlint_pr_title_exit_code=$?
  textlintPRBody
  readonly textlint_pr_body_exit_code=$?

  reportResult

  [[ $commitlint_pr_title_exit_code = 0 ]] && [[ $textlint_pr_title_exit_code = 0 ]] && [[ $textlint_pr_body_exit_code = 0 ]]
}

cat << COMMAND_BEGIN
################################################################################
# 👮 Lint PR
################################################################################
PR TITLE: $pr_title
PR BODY:  長くなるので、載せません
---------------------------------------------------
COMMAND_BEGIN

if [ "$pr_title" = "" ]; then
  current_branch_name="$(git rev-parse --abbrev-ref HEAD)"
  readonly current_branch_name
  echo "現在の ${current_branch_name} ブランチの PR はまだ作成していません"
  echo 'lint を skip します'
  exit 0
fi

mkdir -p tmp
main
