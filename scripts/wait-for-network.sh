#

# usage: waitForNetwork <container name>

waitForNetwork() {
    if [ -z "$1" ]; then
        echo "usage: waitForNetwork <container name>"
        return
    fi

    TARG="$1"
    echo "waiting for IPV4 network ..."
    NW=$(lxc list $TARG | grep $TARG | awk -F '|' '{print $4}' |  tr -d '[:space:]')
    while [ -z "$NW" ]; do
        echo "waiting for IPV4 network ..."
        sleep 1
        NW=$(lxc list $TARG | grep $TARG | awk -F '|' '{print $4}' |  tr -d '[:space:]')
    done
    echo "network $TARG : $NW"
}
