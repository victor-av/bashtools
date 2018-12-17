#!/bin/bash

# Use spinner
source spinner.sh

# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize our own variables:
INPUT_FILE=""
PROTO="udp"
IPADDR="127.0.0.1"
PORT="10000"
DELAY=0.25
INFINITE_LOOP=false
SCREEN_SESSION=0

# Show help if requsted
help()
{
  echo "help?"
}

# Actually send a line
send_line()
{
  if [ $PROTO == "screen" ]; then
    if [[ $SCREEN_SESSION =~ ^[0-9]+$ ]]; then
      SCREEN_SESSIONS=($(ls -1 /var/run/screen/S-$(whoami)))
      SCREEN_SESSION=${SCREEN_SESSIONS[$SCREEN_SESSION]}
    fi
    screen -S $SCREEN_SESSION -p 0 -X stuff "$1^M"
  else
    echo "$1" > /dev/${PROTO}/${IPADDR}/${PORT}
  fi
}

# Parse passed options
while getopts "h?uta:p:d:fsS:" opt; do
  case "$opt" in
    h|\?)
      help
      exit 0
      ;;
    u)
      PROTO="udp"
      ;;
    t)
      PROTO="tcp"
      ;;
    a)
      IPADDR=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    d)
      DELAY=$OPTARG
      ;;
    f)
      INFINITE_LOOP=true
      ;;
    s)
      PROTO="screen"
      ;;
    S)
      PROTO="screen"
      SCREEN_SESSION=$OPTARG
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

# Assume that the rest is a filename as input
FILE=$@

if ! [ -r $FILE  ]; then
  echo "Cannot read from $FILE!"
  exit 1
fi

RUN=true

# Read line by line and send
while $RUN; do
  while read x; do send_line $x && spin; sleep ${DELAY}; done < $FILE
  RUN=$INFINITE_LOOP
done

echo
echo "Done."
