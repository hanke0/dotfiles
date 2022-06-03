#!/usr/bin/env bash

DESCRIPTION=""
USER=""
EXEC=""
SERVICE_NAME=""
DIR=""
read -r -p "Executeable: " EXEC
if [[ -z "$EXEC" ]]; then
    EXEC="$*"
    if [[ -z "$EXEC" ]]; then
        echo >&2 "please input the executable command"
        exit 1
    fi
fi

read -r -p "Working Directory: " DIR
if [[ -z "$DIR" ]]; then
    DIR=/tmp
fi

read -r -p "User: " USER
if [[ -z "$USER" ]]; then
    USER="$(whoami)"
fi

read -r -p "Service name[$(getbase "$EXEC")]: " SERVICE_NAME
if [[ -z "$SERVICE_NAME" ]]; then
    SERVICE_NAME="$(getbase "$EXEC")"
fi

read -r -p "Description: " DESCRIPTION
if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION=$FILENAME
fi

getbase() {
    echo "$@" | sed -E 's/[[:blank:]].*//g' | xargs basename
}

FILE_CONTENT="
[Unit]
Description=$DESCRIPTION
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
StartLimitInterval=60s
User=$USER
ExecStart=$EXEC
WorkingDirectory=$DIR
[Install]
WantedBy=multi-user.target
"

TMP_FILE="/tmp/systemd-$SERVICE_NAME-$RANDOM.service"
printf "%s" "$FILE_CONTENT" >"$TMP_FILE"
echo
cat "$TMP_FILE"
DST_FILE="/etc/systemd/system/$SERVICE_NAME.service"
ANSWER=
read -r -p "Above content will write to $DST_FILE, OK?[Y/n]: " ANSWER
if [[ -n "$ANSWER" && "$ANSWER" != "y" ]]; then
    echo "User abort"
    exit 127
fi
ANSWER=

set -e
sudo cp "$TMP_FILE" "$DST_FILE"
sudo systemctl start "$SERVICE_NAME"
read -r -p "Enable start on boot? [y/N]: " ANSWER
if [[ "$ANSWER" == "y" ]]; then
    sudo systemctl enable "$SERVICE_NAME"
fi
systemctl status "$SERVICE_NAME"
