#!/usr/bin/env bash

# NOTE: Run this script in project directory!!

PACKAGE=example
PACKAGE_UPPER=$(echo ${PACKAGE} | tr '[:lower:]' '[:upper:]')
CONFIG=${PACKAGE_UPPER//-/-}_CONFIG
CONFIG_VAR_NAME=$(echo '$'"$CONFIG")


[[ -z $(eval ${CONFIG_VAR_NAME}) ]] && export ${CONFIG_VAR_NAME}=etc/debug.ini
export FLASK_APP=${PACKAGE}.server.flask
export FLASK_ENV=debug
export FLASK_DEBUG=on
export CELERY=${PACKAGE}.server.celery

worker() {
    celery -A ${CELERY} worker -l info -c 1 -E $@
}

run-server() {
    flask run
}

shell() {
    flask shell
}

cmd=$1
shift
case ${cmd} in
    worker)
      worker $@
      ;;
    run-server)
      run-server
      ;;
    shell)
      shell
      ;;
    *)
      echo Not support command ${cmd}
      ;;
 esac