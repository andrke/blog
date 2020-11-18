#!/usr/bin/env bash

REALPATH=$(which realpath)
if [ -z $REALPATH ]; then
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
fi

LOCUST_TARGET_HOST=${LOCUST_TARGET_HOST:-http://localhost}
LOCUST_EXTRA=${LOCUST_EXTRA:-""}
LOCUST_MASTER=${LOCUST_MASTER:-locust-master}
LOCUST_FILE=${LOCUST_FILE:-locustfile.py}

# Set up directories
SCRIPT_PATH=$(realpath $(dirname "$0"))

LOCUST=$(which locust)

# A better class of script...
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

# Sanity checks
if [ -z "$LOCUST" ]; then
  echo "Please install locust"
  exit 2
fi

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Usage:
     -m|--locust-mode           Locust run mode [master, worker, standalone]
     -t|--target-host           Locust target host. Default http://localhost
     -M|--locust-master         Locust master server in worker mode
     -e|--locust-extra          Locust extra parameters. eg '--headless -u 100 -r 10'
     -l|--locust-file           Locust file Default locustfile.py
     -h|--help                  Displays this help

EOF
}



# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        case $param in
            -m | --locust-mode)
                if [ -z "$2" ]; then
                  echo missing param
                fi
                export LOCUST_MODE="$2"
                shift # past argument
                shift # past value
                ;;
            -t | --target-host)
                if [ -z "$2" ]; then
                  echo missing param
                fi
                export LOCUST_TARGET_HOST="$2"
                shift # past argument
                shift # past value
                ;;
            -M | --locust-master)
                if [ -z "$2" ]; then
                  echo missing param
                fi
                export LOCUST_MASTER="$2"
                shift # past argument
                shift # past value
                ;;
            -e | --locust-extra)
                if [ -z "$2" ]; then
                  echo missing param
                fi
                export LOCUST_EXTRA="$2"
                shift # past argument
                shift # past value
                ;;
            -l | --locust-file)
                if [ -z "$2" ]; then
                  echo missing param
                fi
                export LOCUST_FILE="$2"
                shift # past argument
                shift # past value
                ;;
            -h | --help)
                script_usage
                shift
                exit 0
                ;;
            -v | --verbose)
                verbose=true
                shift
                ;;
            *)
              script_usage
              shift
              exit 1
                ;;
        esac
    done
}

function main() {
    parse_params "$@"

    LOCUS_OPTS="-f $SCRIPT_PATH/$LOCUST_FILE --host=$LOCUST_TARGET_HOST"
    LOCUST_MODE=${LOCUST_MODE:-standalone}
    if [[ "$LOCUST_MODE" = "master" ]]; then
        LOCUS_OPTS="$LOCUS_OPTS --master"
    elif [[ "$LOCUST_MODE" = "worker" ]]; then
        if [ -z "$LOCUST_MASTER" ]; then
          echo locust master is missing
          exit 2
        fi
        LOCUS_OPTS="$LOCUS_OPTS --slave --master-host=$LOCUST_MASTER"
    fi
    LOCUS_OPTS="$LOCUS_OPTS $LOCUST_EXTRA"
    echo "$LOCUST $LOCUS_OPTS"
    $LOCUST $LOCUS_OPTS
}

main "$@"