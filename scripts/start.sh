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

# start mpro session
echo "Starting mpro session..."
mpro ${MPRO_STARTUP} -clientlog /usr/wrk/mpro.log -logginglevel ${LOGGING_LEVEL} -logentrytypes ${LOG_ENTRY_TYPES} &

while true
do
  # get pid of mpro session 
  echo "Waiting for mpro to start..."
  pid=`ps aux|grep '[_]progres'|awk '{print $2}'`
  if [ ! -z "${pid}" ]
  then
    break
  fi
  sleep 1
done
echo "Mpro running as pid: ${pid}"

# keep tailing log file until mpro process exits
tail --pid=${pid} -f /usr/wrk/mpro.log & wait ${!}

# things didn't go well
exit 1
