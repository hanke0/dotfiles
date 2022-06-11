#!/usr/bin/env bash

shfmt -w -i 4 -- .bashrc *.sh **/*.sh
shellcheck -e SC1090 -- .bashrc *.sh **/*.sh
