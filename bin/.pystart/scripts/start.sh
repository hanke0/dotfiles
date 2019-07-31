#!/usr/bin/env bash
set -e

PACKAGE=example
MODULE=${PACKAGE//-/_}
MODULE_UPPER=$(echo ${MODULE} | tr '[:lower:]' '[:upper:]')
CONFIG=${MODULE_UPPER}_CONFIG

echo-around() {
    local n=$((${#1} + 6))
    echo
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo '* ' $1 ' *'
    printf '%*s' ${n} '' | tr ' ' '*' && printf '\n'
    echo
}


usage() {
    echo "Usage: $0 <COMMAND> [-c config] [command-options]"
    echo Command:
    echo "  celery        celery worker"
    echo "  server        http server  "
    echo Note:
    echo "  environment '${CONFIG}' also could set config"
}

cmd=$1
shift

case ${cmd} in
    celery)
        ;;
    server)
        ;;
    *)
        >&2 echo 'Unknown Command'
        usage
        exit 1
        ;;
esac

echo-around "Start ${cmd}"


if [[ -z ${LD_PRELOAD} ]]; then
    if [[ -e "/usr/lib64/libjemalloc.so.2" ]]; then
        export LD_PRELOAD="/usr/lib64/libtcmalloc.so.4"
    elif [[ -e "/usr/lib64/libtcmalloc.so.4" ]]; then
        export LD_PRELOAD="/usr/lib64/libtcmalloc.so.4"
    fi
fi

echo-around "LD_PRELOAD=$LD_PRELOAD"


stop=0

while [[ stop -eq 0 ]]
do
    case $1 in
        -c)
            if [[ -e $2 ]]; then
                export ${CONFIG}=$2
            else
                echo "Config file not exist"
                exit 1
            fi
            shift 2
            ;;
        -h)
            usage
            exit 1
            ;;
        -p)
            if [[ -d $2 ]]; then
                export PYTHON_BIN_PATH=$2
            else
                echo "invalid python path"
                exit 1
            fi
            shift 2
            ;;
        --)
            stop=1
            shift
            echo stop
            ;;
        *)
            stop=1
            exit 1
            ;;
    esac
    [[ $# -eq 0 ]] && stop=1
done


if [[ -z ${PYTHON_BIN_PATH} ]]; then
    __python=$(which python)
    export PYTHON_BIN_PATH=${__python%\/python}
fi

echo-around "Python Path: ${PYTHON_BIN_PATH}"
echo-around "Config Path: ${!CONFIG}"
echo-around "Argument: $*"

case ${cmd} in
    celery)
         ${PYTHON_BIN_PATH}/celery -A ${MODULE}.server.celery worker --hostname worker-${PACKAGE}-${RANDOM}@%h $@
        ;;
    server)
        ${PYTHON_BIN_PATH}/gunicorn --worker-class="meinheld.gmeinheld.MeinheldWorker" ${MODULE}.server.flask:app $@
        ;;
    *)
        >&2 echo 'Unknown Command'
        usage
        exit 1
        ;;
esac
