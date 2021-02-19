# Les smart contracts avec Tezos

Les smart contracts sur Tezos sont écrits en Michelson. Ce langage à pile d'exécution est assez compliqué à utiliser. Plusieurs langages ont été créés, plus faciles d'utilisation et destinés à être compilés en Michelson, afin de faciliter le développement des smart contracts.

- [Ligo](https://ligolang.org/) : il propose 3 syntaxes différentes, ReasonLIGO, PascalLIGO et CamlLIGO, inspirées respectivement de [ReasonML](https://reasonml.github.io/), Pascal et Caml.
- [Liquidity](https://www.liquidity-lang.org/) : développé par [OCamlPro](https://www.ocamlpro.com/), il s'inspire de la syntaxe de [OCaml](http://ocaml.org/) et de [ReasonML](https://reasonml.github.io/),
- [SmartPy](https://smartpy.io/) : bibliothèque Python pour le développement de smart contracts Tezos en Python.

Les exemples que nous allons utiliser seront en Ligo avec la syntaxe ReasonML qui est assez proche du javascript.

## LIGO

### Installation

```shell
wget https://ligolang.org/bin/linux/ligo
chmod +x ./ligo
sudo cp ./ligo /usr/local/bin
```

## Premier smart contract, SimpleHello

```
// Définition de type "variant"
type entryPoint =
| UpdateName(string)
| SayHello;

// Met à jour le nom stocké
let changeName = ( ( newName): ( string) ): string => {

    newName;
};

// Dis hello avec le nom stocké
let hello = ( (contractStorage): (string) ): string => {

    // Concatenate "hello" and the name into a string
    let result : string = "hello"  ++ contractStorage;

    // Return result
    result;
}

let main = ((action, contractStorage): (entryPoint, string)) => {
    let newStorage =
    switch (action) {
    | UpdateName(newName) => changeName((newName))
    | SayHello => hello((contractStorage))
  };
(([] : list (operation)), newStorage);
};
```

## IDE 

https://ide.ligolang.org/

## Compilation
```
ligo dry-run SimpleHello.ligo --syntax reasonligo main "changeName(\"toto\")"
```

## Déploiement

https://better-call.dev/

https://tezosacademy.io/reason/chapter-fa12

## Test du smart contract

### Avec tezos-client

### Avec Taquito

## Docs

https://medium.com/chain-accelerator/i-tested-tezos-b254504775be

https://medium.com/chain-accelerator/how-to-use-tezos-rpcs-16c362f45d64

https://training.nomadic-labs.com/download/interact_with_the_blockchain.pdf

https://hackernoon.com/how-to-build-a-tezos-dapp-using-taquito-and-the-beacon-sdk-0n183ymn (obsolète)

Tezos RPC guide https://tezos.gitlab.io/007/rpc.html

Taquito https://tezostaquito.io/docs/quick_start

Liquidity compiler https://www.liquidity-lang.org/edit/

Ligo https://ligolang.org/docs/next/language-basics/types