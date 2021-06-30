#! /bin/bash

# Define the scripts usage message.
function print_usage() {
    echo
    echo "Usage:"
    echo
    echo "    -f </path/to/file> - The full path to the file you wish to check"
    echo "    -w <n> - Alert Warning if file larter than <n> mb."
    echo "    -c <n> - Alert Critical if file larger than <n> mb."
    echo "    -s <k|m> - Tell script to use Kb or Mb. Default is Mb."
    echo "    -h (help -- this message.)"
    echo
    echo
}


# Parse the cmd line args:
while getopts ": f: w: c: s: d h" opt
do
    case "$opt" in
        f)
            FILE="${OPTARG}"
        ;;
        w)
            WARN_SIZE="${OPTARG}"
        ;;
        c)
            CRIT_SIZE="${OPTARG}"
        ;;
        s)
            SCALE="${OPTARG}"
        ;;
        d)
            DEBUG="YES"
        ;;
        h)
            print_usage
            exit 0
        ;;
        \?)
            echo "ERROR: -$OPTARG does not appear to be a valid argument!"
            print_usage
            exit 4
        ;;
        :)
            echo "ERROR: Please include a manditory option for -${OPTARG}"
            print_usage
            exit 4
        ;;
        *)
            echo "ERROR: -${OPTARG} is not recognized"
            print_usage
            exit 4
        ;;
    esac
done


# Run sanity checks against args and set any defaults:
if [ ! ${WARN_SIZE} ] || [ ! ${CRIT_SIZE} ]
then
  print_usage
  exit 1
fi

if [ ${SCALE} ]
then # Make sure set properly
  if [ ${SCALE} != "k" ] && [ ${SCALE} != "m" ] && [${SCALE} != "g" ] 
  then
    print_usage
    exit 1
  fi
else # Not set, set default
  SCALE="m"  #Mb
fi

if [ ! -f ${FILE} ] && [ ! -d ${FILE} ]
then
  echo "$FILE is not a file (or directory). Unable to proceed. Exiting."
  exit 1
fi


# The Nagios status codes, stolen from the Nagois utils.sh file.
declare -i STATE_OK=0
declare -i STATE_WARNING=1
declare -i STATE_CRITICAL=2
declare -i STATE_UNKNOWN=3


# Declare the initial service check status.
HOSTNAME="$(hostname -f)"


# Main command to run:
FILE_SIZE=$(du -s${SCALE} ${FILE} | awk '{print $1}')

    # Start in OK state:
    state=${STATE_OK}
    cmdstatus="${FILE} size: ${FILE_SIZE}${SCALE}b | size=${FILE_SIZE}${SCALE}b;${WARN_SIZE};${CRIT_SIZE}" 

    # WARN if over <n>:
    if [ "${FILE_SIZE}" -gt "${WARN_SIZE}" ]
    then
        state=${STATE_WARNING}
        cmdstatus="${FILE} size: ${FILE_SIZE}${SCALE}b | size=${FILE_SIZE}${SCALE}b;${WARN_SIZE};${CRIT_SIZE}" 
    fi

    # CRITICAL if over <n>:
    if [ "${FILE_SIZE}" -gt "${CRIT_SIZE}" ]
    then
        state=${STATE_CRITICAL}
        cmdstatus="${FILE} size: ${FILE_SIZE}${SCALE}b | size=${FILE_SIZE}${SCALE}b;${WARN_SIZE};${CRIT_SIZE}" 
    fi


# Report on final status:
case ${state} in
    ${STATE_OK} )
        echo "OK: ${cmdstatus}";;

    ${STATE_WARNING} )
        echo "WARNING: ${cmdstatus}";;

    ${STATE_CRITICAL} )
        echo "CRITICAL: ${cmdstatus}";;

    *)
        echo "UNKNOWN: ${cmdstatus}";;
esac


# DEBUG SECTION: Helps with setup of initial check.
if [ ${DEBUG} ]
  then
    echo
    echo "Debug:  -f:  ${FILE}"
    echo "Debug:  -w:  ${WARN_SIZE}"
    echo "Debug:  -c:  ${CRIT_SIZE}"
    echo
    echo "Debug:  File size found:  ${FILE_SIZE}"
    echo
fi


exit ${state}
