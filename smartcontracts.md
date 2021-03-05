# Les smart contracts avec Tezos

Les smart contracts sur Tezos sont écrits en Michelson. Ce langage à pile d'exécution est assez compliqué à utiliser. Plusieurs langages ont été créés, plus faciles d'utilisation et destinés à être compilés en Michelson, afin de faciliter le développement des smart contracts.

- [Ligo](https://ligolang.org/) : il propose 3 syntaxes différentes, ReasonLIGO, PascalLIGO et CamlLIGO, inspirées respectivement de [ReasonML](https://reasonml.github.io/), Pascal et Caml.
- [Liquidity](https://www.liquidity-lang.org/) : développé par [OCamlPro](https://www.ocamlpro.com/), il s'inspire de la syntaxe de [OCaml](http://ocaml.org/) et de [ReasonML](https://reasonml.github.io/),
- [SmartPy](https://smartpy.io/) : bibliothèque Python pour le développement de smart contracts Tezos en Python.

Les exemples que nous allons utiliser seront en Ligo avec la syntaxe ReasonML qui est assez proche du javascript.

## LIGO

LIGO est un langage assez difficile à prendre en main si l'on n'est pas familier avec la programmation fonctionnelle. Mais il existe un excellent site, avec des tutos sous forme de petits jeux de programmation, qui permettent de vite prendre les bases en mains : https://tezosacademy.io.

### Installation

```shell
wget https://ligolang.org/bin/linux/ligo
chmod +x ./ligo
sudo cp ./ligo /usr/local/bin
```

## Premier smart contract, SimpleHello

Nous allons développer un premier smart contract SimpleHello. Ce contrat va contenir une variable, le nom de la personne à saluer. Une fonction permettra de modifier le nom stockée. Une autre fonction permettra de se faire saluer.

### Principe général

Un contrat Tezos contient une zone de stockage de données. A chaque appel au contrat, le contenu de cette zone sera passée en entrée. Le contrat devra retourner le nouveau contenu.

Les contrats en Ligo ne peuvent aussi contenir qu'une seule fonction appelable depuis l'extérieur. On pourra programmer plusieurs comportements en créant plusieurs fonctions à l'intérieur du contrat et en appliquant un pattern matching sur des paramètres d'entrée.


### IDE

Il existe un IDE en ligne permettant de faire les premiers tests de smart contracts : 

https://ide.ligolang.org/

Leur exécution nécessitera cependant d'avoir le fichier source en local, à portée du compilateur.

### Code

```
// Définition de type "variant"
type entryPoint =
| UpdateName(string)
| SayHello;

// Met à jour le nom stocké
let changeName = ( ( newName): ( string) ): string => {
    newName;
};

// Dit hello avec le nom stocké
let hello = ( (contractStorage): (string) ): string => {

    // Concatenate "hello" and the name into a string
    let result : string = "Hello "  ++ contractStorage;

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

## Simulation

Une fois le code du contrat écrit, nous pouvons simuler son exécution.

```
ligo dry-run SimpleHello.ligo --syntax reasonligo main 'SayHello' '{"nobody"}'
```

Détaillons cette commande :

- ligo : l'exécutable ligo que nous venons d'installer
- dry-run : pour simuler sans réellement déployer sur la blockchain
- SimpleHello.ligo : le fichier ligo du smart contract
- --syntax reasonLigo : la syntaxe choisie
- main : le nom de la fonction principale à exécuter
- 'SayHello' : le paramètre indiquant le point d'entrée à exécuter via la fonction main
- '{"nobody"}' (ou '"nobody"') : l'état initial du storage

Nous obtenons le retour suivant :

```
( LIST_EMPTY() , "Hello nobody" )
```

Attention, avec ce test, les données modifiée dans le storage ne sont pas conservées d'un appel à l'autre. Si nous voulons tester l'enchainement de nos fonctions, nous devons les appeler successivement en indiquant le bon état initial du storage. Par exemple, tout d'abord faisons-nous saluer alors qu'aucun nom n'a été initialisé. Puis modifions le nom, puis faisons-nous saluer à nouveau. :

```
> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'SayHello' '""'
( LIST_EMPTY() , "Hello " )

> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'UpdateName("alex")' '""'
( LIST_EMPTY() , "alex" )

> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'SayHello' '"alex"'
( LIST_EMPTY() , "Hello alex" )
```

Un smart contract Tezos 

## Compilation

La simulation est positive, nous allons maintenant passer aux choses sérieuses et chercher à déployer le contrat.
Première étape, il faut le compiler. Il doit être transpilé depuis le langage choisi pour l'écriture vers du Michelson.

```
ligo compile-contract code.religo mainFunc > code.tz
```

## Déploiement

https://better-call.dev/

https://tezosacademy.io/reason/chapter-fa12

```
tezos-client originate contract <contract_name> for <user> transferring <amount_tez> from <from_user> running <tz_file> --init '<initial_storage>' --burn-cap <gaz_fee>
```

<contract_name> name given to the contract
<tz_file> path of the Michelson smart contract code (TZ file).
<amount_tez> is the quantity of tez being transferred to the newly deployed contract. If a contract balance reaches 0 then it is deactivated.
<from_user> account from which the tez are taken from (and transferred to the new contract).
<initial_storage> is a Michelson expression. The --init parameter is used to specify initial state of the storage.
<gaz_fee> it specifies the the maximal fee the user is willing to pay for this operation (using the --burn-cap parameter).

## Test du smart contract déployé

### Avec tezos-client

```
tezos-client transfer <amount_tez> from <user> to <contract_name> --arg '<entrypoint_invocation>' --dry-run
```

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