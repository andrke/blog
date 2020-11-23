#!/usr/bin/env bash

REALPATH=$(which realpath)
if [ -z $REALPATH ]; then
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
fi

# Set up directories
SCRIPT_PATH=$(realpath $(dirname "$0"))

LOCUST_TARGET_HOST=${LOCUST_TARGET_HOST:-http://localhost}
LOCUST_EXTRA=${LOCUST_EXTRA:-""}
LOCUST_MASTER=${LOCUST_MASTER:-locust-master}
LOCUST_FILE=${LOCUST_FILE:-locustfile.py}
LOCUST_SCRIPTS_PATH=${LOCUST_SCRIPTS_PATH:-$SCRIPT_PATH}
LOCUST_MODE=${LOCUST_MODE:-standalone}


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
     -m|--locust-mode           Locust run mode [master, worker, standalone] or LOCUST_MODE env
     -t|--target-host           Locust target host. or LOCUST_TARGET_HOST env Default http://localhost
     -M|--locust-master         Locust master server in worker mode or LOCUST_MASTER env
     -e|--locust-extra          Locust extra parameters or LOCUST_EXTRA env eg '--headless -u 100 -r 10'
     -l|--locust-file           Locust file or LOCUST_FILE env. Default locustfile.py
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

function handle_locustfile() {
  url=$(echo $LOCUST_FILE | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*")
  if [ ! -z "$url" ]; then
    locustfile_to_download=$(echo $url | awk -F"/" '{print $NF}')
    echo wget -O "$LOCUST_SCRIPTS_PATH"/"$locustfile_to_download" "$url"
    wget -O "$LOCUST_SCRIPTS_PATH"/"$locustfile_to_download" "$url"
    if [ -f "$LOCUST_SCRIPTS_PATH"/"$locustfile_to_download" ]; then
      export LOCUST_FILE="$LOCUST_SCRIPTS_PATH"/"$locustfile_to_download"
      cat $LOCUST_FILE
    else
      echo "Unable to locate $locustfile_to_download"
      exit 2
    fi
  fi
}

function main() {
    parse_params "$@"
    handle_locustfile

    LOCUS_OPTS="-f $LOCUST_FILE --host=$LOCUST_TARGET_HOST"
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