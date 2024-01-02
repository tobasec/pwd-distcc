#!/usr/bin/env bash
set -e

if [ -z "$ALLOW_NET_RANGE" ]; then
    allow_net=10.0.0.1/16
else
    allow_net=$ALLOW_NET_RANGE
fi

if [ -z "${NICE+x}" ]; then
    nice=10
elif [ -n "$NICE" ]; then
    nice=$NICE
fi

if [ -z "${JOBS+x}" ]; then
    jobs=$(nproc --all)
elif [ -n "$JOBS" ]; then
    jobs=$JOBS
fi

# Function to sync time with NTP servers
sync_time() {
    # Specify NTP servers to sync with
    local ntp_servers="0.pool.ntp.org 1.pool.ntp.org"

    # Loop until successful sync occurs
    while true; do
        # Attempt to sync time with specified NTP servers
        ntpdate $ntp_servers || sleep 10

        # Check exit status of the previous command
        if [ "$?" = "0" ]; then
            break
        fi
    done
}

# Call function to sync time
sync_time

echo "Time has been synced. Starting the main application..."

# Define how to start distccd by default
# (see "man distccd" for more information)
distccd --daemon --user distcc --listen 127.0.0.1 --port 3632 --allow $allow_net --stats --stats-port 3633 --log-stderr --nice $nice --jobs $jobs

cloudflared --no-autoupdate --edge-bind-address $(hostname -I | awk '{print $1}') --loglevel warn tunnel run --token $CF_TUNNEL_TOKEN

exec "$@"