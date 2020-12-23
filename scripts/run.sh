#!/bin/bash

trap 'exit 0'  SIGKILL SIGTERM SIGHUP SIGINT EXIT

first=true

while true
do
    if [ ! -x $WATCH_FILE ]; then
        if $first; then
            printf "$WATCH_FILE does not exist (yet ?).."
            first=0
        fi
        printf "."
        sleep ${SLEEPING_TIME:-1}
        continue
    else
        echo "$WATCH_FILE exists"
    fi

    if [ -f .git/index.lock ]; then
	rm -f .git/index.lock
    fi

    NOTICED=userdata/jsondb/empty-things-noticed

    # inotifywait -r -e modify -e delete -e create -t ${RECONCILE_SECONDS:-300} $WATCH_FILE
    while git diff HEAD --exit-code &>/dev/null && ! test -f ${NOTICED}; do
        sleep 10
        echo -n "."
    done
    echo

    # commit all files from current dir:
    git add --all .

    if [ -d userdata/jsondb ]; then
        THINGS=userdata/jsondb/org.eclipse.smarthome.core.thing.Thing.json
        SIZE=$(stat -c '%s' ${THINGS} || echo 0)
        if [ "${SIZE}" -le 1000 ]; then
            if [ -f ${NOTICED} ]; then
                echo "Resetting ${THINGS} and removing ${NOTICED}"
                git reset
                git checkout HEAD ${THINGS}
                rm -f ${NOTICED}
            else
                echo "Waiting for OpenHAB to notice empty things"
            fi
            sleep 10
            continue
        else
            echo "Removing orphan ${NOTICED}"
            rm -f ${NOTICED}
        fi
    fi

    # commit with custom message:
    msg=`eval $GIT_COMMIT_MESSAGE`
    git commit -m "${msg:-"no commit message"}" || continue

    if [ $REMOTE_NAME ] && [ $REMOTE_URL ]; then
        # push to repository in the background
        git push $REMOTE_NAME $REMOTE_BRANCH
    fi
done
