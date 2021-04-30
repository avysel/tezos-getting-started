#!/bin/bash

# How to run:
# ./run-tezos.sh [delphinet|edonet|florencenet] [8732] [xtz1...|alias]
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

DELPHINET_BAKER="tezos-baker-007-PsDELPH1"
DELPHINET_NODE="tezos-node"
DELPHINET_ENDORSER="tezos-endorser-007-PsDELPH1"

EDONET_NODE="/home/alexandrevan/tezos/tezos/tezos-node"
EDONET_BAKER="/home/alexandrevan/tezos/tezos/tezos-baker-008-PtEdo2Zk"
EDONET_ENDORSER="/home/alexandrevan/tezos/tezos/tezos-endorser-008-PtEdo2Zk"

FLORENCENET_NODE="/home/alexandrevan/tezos/tezos/tezos-node"
FLORENCENET_BAKER="/home/alexandrevan/tezos/tezos/tezos-baker-009-PsFLoren"
FLORENCENET_ENDORSER="/home/alexandrevan/tezos/tezos/tezos-endorser-009-PsFLoren"

case $1 in

  edonet )
    echo "Starting Edonet"
    DATA_DIR=$HOME"/.tezos-node"
    BASE_ENDPOINT="127.0.0.1:"$PORT
    NODE=$EDONET_NODE
    BAKER=$EDONET_BAKER
    ENDORSER=$EDONET_ENDORSER
    LOG="log-edonet.txt"
    ;;
  florencenet )
    echo "Starting Florencenet"
    DATA_DIR=$HOME"/tezos-florencenet"
    BASE_ENDPOINT="127.0.0.1:"$PORT
    NODE=$FLORENCENET_NODE
    BAKER=$FLORENCENET_BAKER
    ENDORSER=$FLORENCENET_ENDORSER
    LOG="log-florencenet.txt"
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
