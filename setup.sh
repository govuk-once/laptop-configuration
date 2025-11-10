#!/usr/bin/env bash
set -euxo pipefail

echo "Ask for work email address and github username"

echo "Configuring git"
git config --global alias.unstage "reset HEAD --"
git config --list | grep alias
git config --global commit.gpgsign true
git config --global user.email "your.name@digital.cabinet-office.gov.uk"
git config --global user.name "your_github_username"

echo "Configuring gds-cli"
gds-cli config email your.name@digital.cabinet-office.gov.uk
