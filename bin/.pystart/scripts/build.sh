#!/usr/bin/env bash

set -e

build() {
    python setup.py ${PYBUILD_FLAG:=sdist}
}

function soft-clean {
	find . -name *.egg-info -exec rm -rf {} +
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
}

trap soft-clean EXIT

clean() {
    soft-clean
	rm -rf dist build
}

upload() {
	twine upload dist/* -r ${PYPI:=rq}
}

case $1 in
    build)
        clean
        build
        soft-clean
        ;;
    release)
        clean
        build
        upload
        soft-clean
        ;;
    clean)
        clean
        ;;
    *)
        2>&1 echo Error
        exit 1
        ;;
esac
