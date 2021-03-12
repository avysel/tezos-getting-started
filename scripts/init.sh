#!/bin/bash

#BIN_DIR="/usr/local/bin/tezos/8.2/"
BASE_DIR="/home/alexandrevan/.tezos-node"
BASE_ENDPOINT="http://127.0.0.1:8732"
BAKER_ACCOUNT="tz1fj3tzFejSmPyZZ2xsqehBxQE9GGr3rK8d"

isnum() { awk -v a="$1" 'BEGIN {print (a == a + 0)}'; }

# move to directory that contains acocunts files
cd accounts/new

# for each file in given directory
for entry in "."/*
do
  while read -r line; do

    #only work with line "account"
    if [[ $line == *"amount"* ]]; then

      #extract amount and account name (file name)
      amount=`echo $line | sed "s/\"amount\": \"//" | sed "s/\",//"`
      name=`echo $entry | sed "s/.\///" | sed "s/.json//"`

      res=`isnum "$amount"`
      # if amount well read
      if [ "$res" == "1" ]; then

          #remove mutez and let 1 tez for account
          amount=$(($amount/1000000));
          amount=$(($amount-1))
          echo $name ":" $amount;

          #create account from file
          echo "tezos-client --endpoint "$BASE_ENDPOINT" --base-dir "$BASE_DIR" activate account "$name" with \"$entry\""
          tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account $name with "$entry"

          #transfer amount to baker
          echo "tezos-client --endpoint "$BASE_ENDPOINT" --base-dir "$BASE_DIR" transfer "$amount" from "$name" to "$BAKER_ACCOUNT
          tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR transfer $amount from $name to $BAKER_ACCOUNT

          #set delegate to baker
          echo "tezos-client --endpoint "$BASE_ENDPOINT" --base-dir "$BASE_DIR" set delegate for "$name" to "$BAKER_ACCOUNT
          tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR set delegate for $name to $BAKER_ACCOUNT
      fi
    fi

  done < $entry
done