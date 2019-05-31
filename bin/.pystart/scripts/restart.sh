#!/usr/bin/env bash
set -e

version=$1
PACKAGE=example
REMOTE_ROOT=/root/projects
[[ -z ${version} ]] && >&2 echo version needed && exit 1

supervisor-restart() {
    local program
    for program in $@
    do
        supervisorctl stop ${program}
    done

    sleep 2
    for program in $@
    do
        supervisorctl start ${program}
    done

    for program in $@
    do
        supervisorctl status ${program}
    done
}

run-as-user() {
    su -s /bin/bash -g $1 $1  -c "$2"
}

chown -R 1000:1000 ${REMOTE_ROOT}/${PACKAGE}

run-as-user 1000 "
    cd /home/rice/projects/${PACKAGE} \
    && source /home/rice/.bashrc \
    && source activate ${PACKAGE} \
    && echo Install \
    && pip uninstall -y ${PACKAGE} \
    && pip install -q ${PACKAGE}-${version}.tar.gz \
    && rm -f /home/rice/projects/{PACKAGE}/${PACKAGE}-${version}.tar.gz \
    && pip list | grep rq
"

supervisorctl update
supervisor-restart ${PACKAGE}-server ${PACKAGE}-celery