#!/usr/bin/env bash
set -euo pipefail

read -rp "What is your digital.cabinet-office.gov.uk email address: " emailaddress
read -rp "What is your github username: " githubusername

echo "Configuring git"
git config --global alias.unstage "reset HEAD --"
git config --list | grep alias
git config --global commit.gpgsign true
git config --global user.email "$emailaddress"
git config --global user.name "$githubusername"

echo "Configuring gds-cli"
gds-cli config email "$emailaddress"
