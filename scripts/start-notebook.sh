#!/bin/bash

set -e

while [ -n "$1" ]; do
    case $1 in
        -r)
            shift
            REQUIREMENTS="$1"
            ;;
        -s)
            shift
            SCRIPT="$1"
            ;;
        *)
            echo "usage: $0 [-r <requirements-path>] [-s <script-path>]" >&2
            echo "  use -r to specify a requirements.txt file for pip" >&2
            echo "  use -s to source an activation/environment script" >&2
            exit 1
            ;;
    esac
    shift
done

[ -n "$REQUIREMENTS" ] && sudo pip install -r "$REQUIREMENTS"

[ -n "$SCRIPT" ] && source "$SCRIPT"

cd /opt

sudo /usr/sbin/nginx
sudo service ssh restart
exec jupyter notebook --no-browser --NotebookApp.token=""
