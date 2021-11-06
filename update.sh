#!/usr/bin/env bash

set -e

ABS_PATH="$(realpath "$0")"
ROOT_DIR="$(dirname "$ABS_PATH")"

# compitable with nginx proxy for github
export GIT_SSL_NO_VERIFY=1
cd "$ROOT_DIR"

/usr/bin/git pull -q origin master
date >/tmp/han-dotfiles-cron.txt
