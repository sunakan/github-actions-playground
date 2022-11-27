#!/bin/bash

set -eu

################################################################################
# git commit message template
################################################################################
function setupGitCommitMessageTemplate() {
  echo '🚀 Setup git commit message template'
  echo '---------------------------------------------------'

  git config --local commit.template .GIT_COMMIT_MESSAGE_TEMPLATE.md

  echo '✅ Done: setup git commit message template'
  echo ''
}

################################################################################
# main
################################################################################
function main() {
  echo ''

  setupGitCommitMessageTemplate
}

cat << COMMAND_BEGIN
################################################################################
# 🛠️ 開発環境をセットアップします
################################################################################
COMMAND_BEGIN

main

echo '✅ Done: all setup'
