#!/bin/bash

# How to run:
# ./run-tezos.sh [hangzhounet] [8732] [xtz1...|alias]
# $1: name of network
# $2: port of node
# $3: address or alias of account to use as baker
#
# This script will start a tezos node (using given port), baker, endorser (linked to previously started node) for the given network.
# Data must be changed directly in the script: path to tezos binaries, names of binaries, ip address (default 127.0.0.1), data dir.
#
# example:
# ./run-tezos.sh edonet 8732 alex
#


PORT=$2
ACCOUNT=$3

echo "Run $1 on port $PORT for account $ACCOUNT"


HANGZHOU2NET_NODE="tezos-node"
HANGZHOU2NET_BAKER="tezos-baker-011-PtHangz2"
HANGZHOU2NET_ENDORSER="tezos-endorser-011-PtHangz2"

case $1 in

  hangzhounet )
    echo "Starting Hangzhou2net"
    DATA_DIR=$HOME"/tezos/hangzhounet"
    BASE_ENDPOINT="127.0.0.1:"$PORT
    NODE=$HANGZHOU2NET_NODE
    BAKER=$HANGZHOU2NET_BAKER
    ENDORSER=$HANGZHOU2NET_ENDORSER
    LOG="log-hangzhounet.txt"
    ;;
  mainnet )
    echo "Starting mainnet"

    ;;

  * )
    echo "Unknown network"
    ;;
esac

echo "Run node: "$NODE" run --rpc-addr "$BASE_ENDPOINT" --data-dir "$DATA_DIR" --log-output="$DATA_DIR"/"$LOG
$NODE run --rpc-addr $BASE_ENDPOINT --data-dir $DATA_DIR --log-output=$DATA_DIR"/"$LOG &

sleep 3

echo "Run baker: "$BAKER" --endpoint http://"$BASE_ENDPOINT" --base-dir "$DATA_DIR" run with local node "$DATA_DIR $ACCOUNT
$BAKER --endpoint "http://"$BASE_ENDPOINT --base-dir $DATA_DIR run with local node $DATA_DIR $ACCOUNT &

echo "Run endorser: "$ENDORSER" --endpoint http://"$BASE_ENDPOINT" --base-dir "$DATA_DIR" run "$ACCOUNT
$ENDORSER --endpoint "http://"$BASE_ENDPOINT --base-dir $DATA_DIR run $ACCOUNT &
