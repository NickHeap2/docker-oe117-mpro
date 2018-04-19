#!/bin/sh

set -e

signal_handler() {

    echo "Stopping mpro session..."
    if [ ! -z "${pid}" ]
    then
      kill ${pid}
    fi
    # graceful shutdown so exit with 0
    exit 0
}
# trap SIGTERM and call the handler to cleanup processes
trap 'signal_handler' SIGTERM SIGINT

# most servers use a lock file so clear it up now if needed
if [ ! -z "${LOCK_FILE}" ]
then
  echo "Removing lock file ${LOCK_FILE}..."
  rm -f ${LOCK_FILE}
fi

LOG_FILE="/usr/wrk/${LOG_FILE_NAME}.log"
touch ${LOG_FILE}

# start mpro session
echo "Starting mpro session..."
mpro ${MPRO_STARTUP} -clientlog ${LOG_FILE} -logginglevel ${LOGGING_LEVEL} -logentrytypes ${LOG_ENTRY_TYPES} &

# get pid of mpro session 
echo "Waiting for mpro to start..."

RETRIES=0
while true
do
  if [ "${RETRIES}" -gt 10 ]
  then
    break
  fi

  pid=`ps aux|grep '[_]progres'|awk '{print $2}'`
  if [ ! -z "${pid}" ]
  then
    case "${pid}" in
      ''|*[!0-9]*) continue ;;
      *) break ;;
    esac
  fi
  sleep 1
  RETRIES=$((RETRIES+1))
done
# did we get the pid?
if [ -z "${pid}" ]
then
  echo "$(date +%F_%T) ERROR: Mpro process not found exiting."
  exit 1
fi

echo "Mpro running as pid: ${pid}"

# keep tailing log file until mpro process exits
tail --pid=${pid} -f ${LOG_FILE} & wait ${!}

# things didn't go well
exit 1
