#!/bin/bash

set -eu

################################################################################
# git commit message template
################################################################################
function setupGitCommitMessageTemplate() {
  echo 'ð Setup git commit message template'
  echo '---------------------------------------------------'

  git config --local commit.template .GIT_COMMIT_MESSAGE_TEMPLATE.md

  echo 'â Done: setup git commit message template'
  echo ''
}

################################################################################
# npm äūå­ãŪč§Ģæąš ( textlint į­ãåĨã )
################################################################################
function resolveNpmDependencies() {
  echo 'ð Resolve npm dependencies'
  echo '---------------------------------------------------'

  npm install

  echo 'â Done: resolve npm dependencies'
  echo ''
}

################################################################################
# githooks
################################################################################
function setupGitHooks() {
  echo 'ð Setup githooks'
  echo '---------------------------------------------------'

  git config --local core.hooksPath .githooks

  echo 'â Done: setup githooks'
  echo ''
}

################################################################################
# main
################################################################################
function main() {
  echo ''

  setupGitCommitMessageTemplate
  resolveNpmDependencies
  setupGitHooks
}

cat << COMMAND_BEGIN
################################################################################
# ð ïļ éįšį°åĒããŧãããĒããããūã
################################################################################
COMMAND_BEGIN

main

echo 'â Done: all setup'
