#!/bin/bash

# How to run:
# ./run-tezos.sh [delphinet|edonet] [8732] [xtz1...|alias]
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


# BIN_DIR=$HOME"/.opam/for_tezos/bin"
BIN_DIR="/usr/local/bin/tezos/8.2"
PORT=$2
ACCOUNT=$3

echo "Run $1 on port $PORT for account $ACCOUNT"

DELPHINET_BAKER="tezos-baker-007-PsDELPH1"
DELPHINET_NODE="tezos-node"
DELPHINET_ENDORSER="tezos-endorser-007-PsDELPH1"

EDONET_NODE="tezos-node"
EDONET_BAKER="tezos-baker-008-PtEdo2Zk"
EDONET_ENDORSER="tezos-endorser-008-PtEdo2Zk"

case $1 in
  delphinet )
    echo "Starting Delphinet"
    DATA_DIR=$HOME"/.tezos-node"
    BASE_ENDPOINT="127.0.0.1:"$PORT
    NODE=$DELPHINET_NODE
    BAKER=$DELPHINET_BAKER
    ENDORSER=$DELPHINET_ENDORSER
    LOG="log-delphinet.txt"
    ;;

  edonet )
    echo "Starting Edonet"
    DATA_DIR=$HOME"/.tezos-node"
    BASE_ENDPOINT="127.0.0.1:"$PORT
    NODE=$EDONET_NODE
    BAKER=$EDONET_BAKER
    ENDORSER=$EDONET_ENDORSER
    LOG="log-edonet.txt"
    ;;

  mainnet )
    echo "Starting mainnet"

    ;;

  * )
    echo "Unknown network"
    ;;
esac

echo "Go to "$BIN_DIR
cd $BIN_DIR

echo "Run node: ./"$NODE run --rpc-addr $BASE_ENDPOINT --data-dir $DATA_DIR --log-output=$DATA_DIR"/"$LOG
$NODE run --rpc-addr $BASE_ENDPOINT --data-dir $DATA_DIR --log-output=$DATA_DIR"/"$LOG &

sleep 3

echo "Run baker: "$BAKER --endpoint "http://"$BASE_ENDPOINT run with local node $DATA_DIR $ACCOUNT
$BAKER --endpoint "http://"$BASE_ENDPOINT run with local node $DATA_DIR $ACCOUNT &

echo "Run endorser: "$ENDORSER --endpoint "http://"$BASE_ENDPOINT run $ACCOUNT
$ENDORSER --endpoint "http://"$BASE_ENDPOINT run $ACCOUNT &
