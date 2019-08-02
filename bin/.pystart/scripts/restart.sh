#!/usr/bin/env bash
set -e

version=$1
PACKAGE=example
MODULE=${PACKAGE//-/_}
REMOTE_ROOT=/root/projects
#[[ -z ${version} ]] && >&2 echo version needed && exit 1

supervisor-restart() {
    local ascending=$@
    local descending
    local program
    for program in $ascending
    do
        descending="${program} ${descending}"
        supervisorctl stop ${program} || true
    done
    sleep 2
    for program in $descending
    do
        supervisorctl start ${program} || true
    done

    for program in $descending
    do
        supervisorctl status ${program}
    done
}

run-as-user() {
    su -s /bin/bash -g $1 $1  -c "$2"
}

user-name() {
    s=$(id $1 | awk '{print $1}' | awk -F= '{print $2}' | awk -F'(' '{print $2}')
    echo ${s:0:-1}
}

chown -R 1000:1000 ${REMOTE_ROOT}/${PACKAGE}

runuser=$(user-name 1000)

run-as-user ${runuser}  "
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