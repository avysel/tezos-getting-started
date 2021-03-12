#!/bin/bash

BIN_DIR="/usr/local/bin/tezos/8.2/"
BASE_DIR="~/tezos-edonet"
BASE_ENDPOINT="http://127.0.0.1:8732"

#alias tezos-client= $BIN_DIR"/"tezos-client

echo "Run: "$BIN_DIR"/tezos-client --endpoint "$BASE_ENDPOINT" --base-dir "$BASE_DIR" activate account alex with 'alex.json'"

tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account alex with "alex.json" // 6400
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account bob with "bob.json" // 43500
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR gen keys carl
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account dany with "dany.json" // 26300
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account eddy with "eddy.json" // 65300
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account fred with "fred.json" // 61400
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account greg with "greg.json" // 20800
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account harry with "harry.json" // 27900
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account igor with "igor.json" // 13900
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account james with "james.json" // 65500
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account klaus with "klaus.json" // 113200

tezos-client transfer 40000 from bob to alex --burn-cap 0.06425
tezos-client transfer 1 from alex to carl --burn-cap 0.06425
tezos-client transfer 25000 from dany to alex
tezos-client transfer 60000 from eddy to alex
tezos-client transfer 60000 from fred to alex
tezos-client transfer 20000 from greg to alex
tezos-client transfer 27000 from harry to alex
tezos-client transfer 13000 from igor to alex
tezos-client transfer 65000 from james to alex
tezos-client transfer 110000 from klaus to alex

tezos-client  register key alex as delegate
tezos-client  set delegate for bob to alex
tezos-client  set delegate for carl to alex
tezos-client  set delegate for dany to alex
tezos-client  set delegate for eddy to alex
tezos-client  set delegate for fred to alex
tezos-client  set delegate for greg to alex
tezos-client  set delegate for harry to alex
tezos-client  set delegate for igor to alex
tezos-client  set delegate for james to alex
tezos-client  set delegate for klaus to alex

tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account victor with "victor.json" # 43000
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR transfer 43000 from victor to alex
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR set delegate for victor to alex

tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account walter with "walter.json" # 72700
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR transfer 72700 from walter to alex
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR set delegate for walter to alex

tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account xavier with "xavier.json" # 199700
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR transfer 199700 from xavier to alex
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR set delegate for xavier to alex

tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account yann with "yann.json" # 44900
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR transfer 44900 from yann to alex
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR set delegate for yann to alex

tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR activate account zoe with "zoe.json" # 23400
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR transfer 23400 from zoe to alex
tezos-client --endpoint $BASE_ENDPOINT --base-dir $BASE_DIR set delegate for zoe to alex