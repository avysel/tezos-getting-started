"use strict";
exports.__esModule = true;
var taquito_1 = require("@taquito/taquito");
var tezos = new taquito_1.TezosToolkit('http://127.0.0.1:8732');
//const tezos = new TezosToolkit('https://api.tez.ie/rpc/delphinet');
//const tezos = new TezosToolkit('https://api.tez.ie/rpc/mainnet');
tezos.tz
    .getBalance('tz1fj3tzFejSmPyZZ2xsqehBxQE9GGr3rK8d')
    .then(function (balance) { return console.log("Alex : " + balance.toNumber() / 1000000 + " \uA729"); })["catch"](function (error) { return console.error(JSON.stringify(error)); });
tezos.tz
    .getBalance('tz1TCoi1XMdjgazx3311Eax1ejgBeQftbq6U')
    .then(function (balance) { return console.log("Bob : " + balance.toNumber() / 1000000 + " \uA729"); })["catch"](function (error) { return console.error(JSON.stringify(error)); });
tezos.tz
    .getBalance('tz1LcjVm8PXmV2WRfM6aMnwB4VWhXMU62qzG')
    .then(function (balance) { return console.log("Carl : " + balance.toNumber() / 1000000 + " \uA729"); })["catch"](function (error) { return console.error(JSON.stringify(error)); });
