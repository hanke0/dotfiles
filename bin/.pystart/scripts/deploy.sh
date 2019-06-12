#!/usr/bin/env bash
set -e

# NOTE: Run this script in project directory!!
PACKAGE=example
MODULE=${PACKAGE//-/_}
REMOTE_ROOT=/home/rice/projects
DEVELOP_PWD=example
DEVELOP_HOST=example

tag=$(git log --pretty=%h -1)
basic_version=$(grep -E -o '__version__ = ".*"' ${MODULE}/__init__.py | sed 's/__version__ //g' | sed 's/"//g' | sed 's/= //g')
version=${basic_version}.dev${tag}

build-dev() {
    sed -iabc -e s/__version__\ =.*/__version__\ =\ \"${version}\"/ ${MODULE}/__init__.py
    rm -f ${MODULE}/__init__.pyabc
    grep __version__ ${MODULE}/__init__.py
    python setup.py -q sdist
    git checkout -- ${MODULE}/__init__.py
}

develop() {
    build-dev
    echo Sync file...
    pwd=${DEVELOP_PWD}
    host=${DEVELOP_HOST}
    sshpass -p ${pwd} rsync -azcPq etc/*.ini --rsync-path="mkdir -p ${REMOTE_ROOT}/${PACKAGE} && rsync" \
                root@${host}:${REMOTE_ROOT}/${PACKAGE}/etc/
    sshpass -p ${pwd} rsync dist/${PACKAGE}-${version}.tar.gz root@${host}:${REMOTE_ROOT}/${PACKAGE}/
    sshpass -p ${pwd} rsync -azcPq scripts/ root@${host}:${REMOTE_ROOT}/${PACKAGE}/scripts/
    sshpass -p ${pwd} rsync -azcPq etc/supervisord.d/*.ini root@${host}:/etc/supervisord.d/
    echo Sync finish

    make clean

    echo Start remote change...
    sshpass -p ${pwd} ssh root@${host} "${REMOTE_ROOT}/${PACKAGE}/scripts/restart.sh '${version}'"
}


case $1 in
    develop)
        shift
        azure
        ;;
    *)
        >&2 echo Nothing happened
        exit 1
        ;;
esac

if [[ $? -ne 0 ]]; then
    echo Failed
else
    echo Successed
fi