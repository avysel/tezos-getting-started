import { TezosToolkit } from '@taquito/taquito';

const tezos = new TezosToolkit('http://127.0.0.1:8732');
//const tezos = new TezosToolkit('https://api.tez.ie/rpc/delphinet');
//const tezos = new TezosToolkit('https://api.tez.ie/rpc/mainnet');

tezos.tz
  .getBalance('tz1fj3tzFejSmPyZZ2xsqehBxQE9GGr3rK8d')
  .then((balance) => console.log(`Alex : ${balance.toNumber() / 1000000} ꜩ`))
  .catch((error) => console.error(JSON.stringify(error)));

tezos.tz
    .getBalance('tz1TCoi1XMdjgazx3311Eax1ejgBeQftbq6U')
    .then((balance) => console.log(`Bob : ${balance.toNumber() / 1000000} ꜩ`))
    .catch((error) => console.error(JSON.stringify(error)));

tezos.tz
  .getBalance('tz1LcjVm8PXmV2WRfM6aMnwB4VWhXMU62qzG')
  .then((balance) => console.log(`Carl : ${balance.toNumber() / 1000000} ꜩ`))
  .catch((error) => console.error(JSON.stringify(error)));
