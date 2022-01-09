#!/bin/bash
#https://gist.github.com/frntn/48948505b8e0371104564dffadf9ab6b
# Calculates network and broadcast based on supplied ip address and netmask

# Usage: broadcast_calc.sh 192.168.0.1 255.255.255.0
# Usage: broadcast_calc.sh 192.168.0.1/24


tonum() {
    if [[ $1 =~ ([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+) ]]; then
        addr=$(( (${BASH_REMATCH[1]} << 24) + (${BASH_REMATCH[2]} << 16) + (${BASH_REMATCH[3]} << 8) + ${BASH_REMATCH[4]} ))
        eval "$2=\$addr"
    fi
}
toaddr() {
    b1=$(( ($1 & 0xFF000000) >> 24))
    b2=$(( ($1 & 0xFF0000) >> 16))
    b3=$(( ($1 & 0xFF00) >> 8))
    b4=$(( $1 & 0xFF ))
    eval "$2=\$b1.\$b2.\$b3.\$b4"
}

if [[ $1 =~ ^([0-9\.]+)/([0-9]+)$ ]]; then
    # CIDR notation
    IPADDR=${BASH_REMATCH[1]}
    NETMASKLEN=${BASH_REMATCH[2]}
    zeros=$((32-NETMASKLEN))
    NETMASKNUM=0
    for (( i=0; i<$zeros; i++ )); do
        NETMASKNUM=$(( (NETMASKNUM << 1) ^ 1 ))
    done
    NETMASKNUM=$((NETMASKNUM ^ 0xFFFFFFFF))
    toaddr $NETMASKNUM NETMASK
else
    IPADDR=${1:-192.168.1.1}
    NETMASK=${2:-255.255.255.0}
fi

tonum $IPADDR IPADDRNUM
tonum $NETMASK NETMASKNUM

#printf "IPADDRNUM: %x\n" $IPADDRNUM
#printf "NETMASKNUM: %x\n" $NETMASKNUM

# The logic to calculate network and broadcast
INVNETMASKNUM=$(( 0xFFFFFFFF ^ NETMASKNUM ))
NETWORKNUM=$(( IPADDRNUM & NETMASKNUM ))
BROADCASTNUM=$(( INVNETMASKNUM | NETWORKNUM ))

IPADDRBIN=$(   python -c "print(bin(${IPADDRNUM}   )[2:].zfill(32))")
NETMASKBIN=$(  python -c "print(bin(${NETMASKNUM}  )[2:].zfill(32))")
NETWORKBIN=$(  python -c "print(bin(${NETWORKNUM}  )[2:].zfill(32))")
BROADCASTBIN=$(python -c "print(bin(${BROADCASTNUM})[2:].zfill(32))")

toaddr $NETWORKNUM NETWORK
toaddr $BROADCASTNUM BROADCAST

printf "%-25s %s\n" "IPADDR=$IPADDR"       $IPADDRBIN
printf "%-25s %s\n" "NETMASK=$NETMASK"     $NETMASKBIN
printf "%-25s %s\n" "NETWORK=$NETWORK"     $NETWORKBIN
printf "%-25s %s\n" "BROADCAST=$BROADCAST" $BROADCASTBIN
