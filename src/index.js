"use strict";
exports.__esModule = true;
var taquito_1 = require("@taquito/taquito");
var tezos = new taquito_1.TezosToolkit('http://127.0.0.1:8732');
//const tezos = new TezosToolkit('https://api.tez.ie/rpc/carthagenet');
//const tezos = new TezosToolkit('https://api.tez.ie/rpc/mainnet');
tezos.tz
    .getBalance('tz1fj3tzFejSmPyZZ2xsqehBxQE9GGr3rK8d')
    .then(function (balance) { return console.log(balance.toNumber() / 1000000 + " \uA729"); })["catch"](function (error) { return console.error(JSON.stringify(error)); });
/*
tezos.rpc
  .getBalance('tz1fj3tzFejSmPyZZ2xsqehBxQE9GGr3rK8d')
  .then((balance) => console.log(`${balance.toNumber() / 1000000} ꜩ`))
  .catch((error) => console.error(JSON.stringify(error)));*/ 
