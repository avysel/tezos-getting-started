#!/bin/bash

BIN_DIR=$HOME"/.opam/for_tezos/bin"
PORT=$2
ACCOUNT=$3

echo "Run $1 on port $PORT for account $ACCOUNT"

DELPHINET_BAKER="tezos-baker-007-PsDELPH1"
DELPHINET_NODE="tezos-node"
DELPHINET_ENDORSER="tezos-endorser-007-PsDELPH1"

EDONET_NODE="tezos-node"
EDONET_BAKER="tezos-baker-008-PtEdoTez"
EDONET_ENDORSER="tezos-endorser-008-PtEdoTez"

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
    DATA_DIR=$HOME"/tezos-edonet"
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
./$NODE run --rpc-addr $BASE_ENDPOINT --data-dir $DATA_DIR --log-output=$DATA_DIR"/"$LOG &

sleep 3

echo "Run baker: "$BAKER --endpoint "http://"$BASE_ENDPOINT run with local node $DATA_DIR $ACCOUNT
$BAKER --endpoint "http://"$BASE_ENDPOINT run with local node $DATA_DIR $ACCOUNT &

echo "Run endorser: "$ENDORSER --endpoint "http://"$BASE_ENDPOINT run $ACCOUNT
$ENDORSER --endpoint "http://"$BASE_ENDPOINT run $ACCOUNT &
