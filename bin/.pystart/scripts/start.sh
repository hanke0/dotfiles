#!/usr/bin/env bash
set -e

PACKAGE=example
PACKAGE_UPPER=$(echo ${PACKAGE} | tr '[:lower:]' '[:upper:]')
CONFIG=${PACKAGE_UPPER//-/-}_CONFIG

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

shift_num=0
c_set=
p_set=
while 2>/dev/null getopts "c:hp:" opt
do
    case ${opt} in
        c)
            if [[ -z ${c_set} ]]; then
                if [[ -e $OPTARG ]]; then
                    export ${CONFIG}=$OPTARG
                else
                    echo "Config file not exist"
                    exit 1
                fi
                shift_num=$((${shift_num} + 2))
                c_set=1
            fi
            ;;
        h)
            usage
            exit 0
            ;;
        p)
            if [[ -z ${p_set} ]]; then
                export PYTHON_BIN_PATH=$OPTARG
                shift_num=$((${shift_num} + 2))
                p_set=1
            fi
            ;;
        :|?)
           ;;
    esac
done

[[ ${shift_num} -ne 0 ]] && shift ${shift_num}


if [[ -z ${PYTHON_BIN_PATH} ]]; then
    __python=$(which python)
    export PYTHON_BIN_PATH=${__python%\/python}
fi

echo-around "Python Path: ${PYTHON_BIN_PATH}"


case ${cmd} in
    celery)
         ${PYTHON_BIN_PATH}/celery -A rqscenario_analysis.server.celery worker --hostname worker-${PACKAGE}-${RANDOM}@%h $@
        ;;
    server)
        ${PYTHON_BIN_PATH}/gunicorn --worker-class="meinheld.gmeinheld.MeinheldWorker" rqscenario_analysis.server.flask:app $@
        ;;
    *)
        >&2 echo 'Unknown Command'
        usage
        exit 1
        ;;
esac
