# Les smart contracts avec Tezos

Les smart contracts sur Tezos sont écrits en Michelson. Ce langage à pile d'exécution est assez compliqué à utiliser. Plusieurs langages ont été créés, plus faciles d'utilisation et destinés à être compilés en Michelson, afin de faciliter le développement des smart contracts.

- [Ligo](https://ligolang.org/) : il propose 3 syntaxes différentes, ReasonLIGO, PascalLIGO et CamlLIGO, inspirées respectivement de [ReasonML](https://reasonml.github.io/), Pascal et Caml.
- [Liquidity](https://www.liquidity-lang.org/) : développé par [OCamlPro](https://www.ocamlpro.com/), il s'inspire de la syntaxe de [OCaml](http://ocaml.org/) et de [ReasonML](https://reasonml.github.io/),
- [SmartPy](https://smartpy.io/) : bibliothèque Python pour le développement de smart contracts Tezos en Python.

Les exemples que nous allons utiliser seront en Ligo avec la syntaxe ReasonML qui est assez proche du javascript (Enfin, disons plutôt moins éloignée du javascript que les autres :) ).

## LIGO

LIGO est un langage assez difficile à prendre en main si l'on n'est pas familier avec la programmation fonctionnelle. Mais il existe un excellent site, avec des tutos sous forme de petits jeux de programmation, qui permettent de vite prendre les bases en mains : https://tezosacademy.io.

### Installation

```shell
wget https://ligolang.org/bin/linux/ligo
chmod +x ./ligo
sudo cp ./ligo /usr/local/bin
```

### IDE

Il existe un IDE en ligne permettant de faire les premiers tests de smart contracts :

https://ide.ligolang.org/

Leur exécution nécessitera cependant d'avoir le fichier source en local, à portée du compilateur.


## Premier smart contract, SimpleHello

Nous allons développer un premier smart contract SimpleHello. Ce contrat va contenir une variable, le nom de la personne à saluer. Une fonction permettra de modifier le nom stockée. Une autre fonction permettra de se faire saluer.

### Principe général

Un contrat Tezos contient **une zone de stockage de données** (couramment appelée **storage**) et **un point d'entrée**. 

**Seul le point d'entrée est appelé**, à la différence d'autres langage où l'on peut définir des fonctions et les appeler distinctement les unes des autres.

Autre spécificité, l'appel au point d'entrée du contrat **retournera toujours l'intégralité des données** stockées dans ce contrat.

En mixant les deux conditions précédentes, nous comprenons vite qu'il ne sera pas possible de développer des getters et setters comme on peut trouver un peu partout.

Mais nous pourrons tout de même programmer plusieurs comportements en créant plusieurs fonctions à l'intérieur du contrat. Il faudra préciser en entrée du contrat quelle fonction appeler en utilisant un pattern matching sur ces paramètres d'entrée.


### Code

Voyons tout de suite le code de notre contrat exemple : 

```
// Définition de type "variant"
type pseudoEntryPoint =
| UpdateName(string)
| GetHello;

// Met à jour le nom stocké
let changeName = ( ( newName): ( string) ): string => {
    // Concatenate "hello" and the name into a string
    let result : string = "Hello "  ++ newName;

    // Return result
    result;
};

// Retourne le storage courant
let getHello = ( (contractStorage): (string) ): string => {
    contractStorage;
}

let main = ((action, contractStorage): (pseudoEntryPoint, string)) => {

    let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName)
    | GetHello => getHello(contractStorage)
  };

  (([] : list (operation)), newStorage);

};
```

### Détaillons ce code.

Tout d'abord, la fonction `main`, qui est le point d'entrée. Elle prend 2 paramètres : `action` qui est le nom de la fonction à appeler et `contractStorage` qui est l'état initial du storage.

`(action, contractStorage): (pseudoEntryPoint, string))` signifie que nous définissons 2 paramètres, action et contractStorage, qui seront respectivement de type `pseudoEntryPoint` et `string`.

Regardons les premières lignes : 
```
type pseudoEntryPoint =
| UpdateName(string)
| GetHello;
```

Ligo permet de définir des types. Nous définissons ici le type `pseudoEntryPoint` qui sera un **variant** (l'équivalent d'un enum en Java par exemple). Ce type pourra prendre différentes valeurs définies dans la liste. Nous utiliseront ce **variant** pour lister les actions possibles dans notre contrat.

Nous définissons ici 3 "actions" :
- `UpdateName(string)` qui prend en paramètre un nouveau nom et met à jour la salutation.
- `GetHello` qui retourne la salutation

Regardons le contenu de la fonction `main` :

```
let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName)
    | GetHello => getHello(contractStorage)
  };
```

Nous créons une variable `newStorage` dont l'affectation initiale dépendra de la valeur du paramètre d'entrée `action`. Il est attendu que la valeur passée pour `action` soit une des valeurs définies par `pseudoEntryPoint`. Le switch redirigera alors vers une fonction qui effectuera l'action voulue. C'est le fameux pattern matching.

Regardons maintenant la dernière instruction de `main` : 

```( ( [] : list (operation) ), newStorage );```

Il s'agit du "return", qui se définit en indiquant tout simplement en fin de fonction la valeur à retourner, sans mot clé particulier. 

Le point d'entrée d'un smart contract doit retourner deux éléments : une liste d'opérations et le nouveau storage du contrat. La liste d'opération va servir, par exemple, à indiquer des appels à d'autres smart contracts à effectuer une fois que le contrat actuel a terminé son exécution sans erreur. (A noter qu'aucun appel à un autre smart contract ne peut avoir lieu pendant l'exécution d'un smart contract, les appels sont forcément mis dans celle liste d'opérations)

Ici, nous avons donc `[]` de type `list(operation)`, vide, car aucune opération n'est à exécuter ensuite dans notre exemple. Et `newStorage`, la nouvelle valeur du storage, qui aura été modifiée par l'appel à une des fonctions de notre contrat.

Les fonctions se définissent sur le modèle suivant :

```
let functionName = ( (param1Name, param2Name, ...) : (param1Type, param2Type, ...) ) : returnType => {
    function body
}
```

Voyons donc nos fonctions :
```
// Met à jour le nom stocké
let changeName = ( ( newName): ( string) ): string => {
    // Concatenate "hello" and the name into a string
    let result : string = "Hello "  ++ newName;

    // Return result
    result;
};
```

La fonction `changeName` prend un paramètre `newName` de type `string` et elle retourne une string. 
Elle va concaténer "Hello" avec le nom passé en paramètre pour créer la nouvelle salutation dans la variable `result`, qui sera retournée. La phrase "Hello <newName>" sera donc la nouvelle valeur du storage du contrat.

```
// Retourne le storage courant
let getHello = ( (contractStorage): (string) ): string => {
    contractStorage;
}
```
La fonction `getHello` va retourner le storage courant du contrat. Il va donc nous retourner la salutation.

Attention : cet exemple fonctionne parce que notre storage ne contient qu'une seule valeur. Dans le cas de storage comprenant plusieurs valeurs, si le `main` ne retourne qu'une seule d'entre elles, elle deviendra le nouveau storage et le reste sera écrasé.

## Simulation

Une fois le code du contrat écrit, nous pouvons simuler son exécution avec la commande `ligo dry-run`. Cette commande exécute le contrat hors de la blockchain, il n'a donc pas de storage. Nous allons devoir indiquer la valeur initiale d'un storage. De même, chaque appel est indépendant et les valeurs de storage, initiales ou modifiées, ne sont pas gardées en mémoire d'un appel à l'autre.

```
ligo dry-run SimpleHello.ligo --syntax reasonligo main 'GetHello' '{"Hello nobody"}'
```

Détaillons cette commande :

- ligo : l'exécutable ligo que nous venons d'installer
- dry-run : pour simuler sans réellement déployer sur la blockchain
- SimpleHello.ligo : le fichier ligo du smart contract
- --syntax reasonLigo : la syntaxe choisie
- main : le nom du point d'entrée à exécuter
- 'GetHello' : le paramètre `action` de notre point d'entrée
- '{"Hello nobody"}' (ou '"Hello nobody"') : l'état initial du storage, le paramètre `contractStorage`.

Nous obtenons le retour suivant :

```
( LIST_EMPTY() , "Hello nobody" )
```

Nous voyons bien les 2 choses retournées par un contrat : la **liste d'opérations** (vide, dans notre cas) et le **nouvel état du storage**.

Testons maintenant la mise à jour en partant d'un storage initial vide :

```
> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'UpdateName("alex")' '{""}'
( LIST_EMPTY() , "Hello alex" )
```

## Compilation

La simulation est positive, nous allons maintenant passer aux choses sérieuses et chercher à déployer le contrat.
Première étape, il faut le compiler. Il doit être transpilé depuis le langage choisi pour l'écriture vers du Michelson.

```
ligo compile-contract --syntax reasonligo SimpleHello.ligo main > SimpleHello.tz
```

Il est possible de ne pas préciser la syntaxe en utilisant l'extension de fichier spécifique à ReasonML dans notre cas en remplaçant `SimpleHello.ligo` en `SimpleHello.religo` et compiler de cette façon :

```
ligo compile-contract SimpleHello.religo main > SimpleHello.tz
```

Nous obtenons un fichier `SimpleHello.tz` comportant le code de notre smart contract écrit en Michelson, avec notre fonction `main` utilisée comme point d'entrée.

```
{ parameter (or (unit %getHello) (string %updateName)) ;
  storage string ;
  code { DUP ;
         CAR ;
         IF_LEFT { DROP ; CDR } { SWAP ; DROP ; PUSH string "Hello " ; CONCAT } ;
         NIL operation ;
         PAIR } }
```

Un peu moins facile à lire, n'est-ce pas ?

Il ne reste plus qu'à le déployer.

## Déploiement

https://better-call.dev/

https://tezosacademy.io/reason/chapter-fa12

Au déploiement d'un contrat, il faut préciser la valeur initiale du storage. Nous l'avons déjà expérimenté précédemment lors de la simulation avec la commande ligo. Le déploiement nécessitera que cette expression soit en Michelson cette fois.

Il existe une commande pour convertir l'expression Ligo vers l'expression Michelson.
```
> ligo compile-storage SimpleHello.ligo --syntax reasonligo main  '{""}'
""
```
Bon, notre storage initial étant une simple chaîne vide, nous obtenons un autre chaine vide, rien d'exceptionnel. Mais pour un contrat nécessitant un storage initial plus complexe, cette commande sera bien utile.


Nous pouvons déployer en utilisant `tezos-client`. Cette opération s'appelle l'**origination** d'un contrat.
```
tezos-client originate contract SimpleHello transferring 0 from contractor running SimpleHello.tz --init '""' --burn-cap 0.09225
```

```
tezos-client originate contract <contract_name> transferring <amount_tez> from <originator_address> running <contract_file> --init '<storage_expression>' --burn-cap 0.09225
```

Détaillons cette commande :
- tezos-client originate :
- <contract_name> nom du smart contract
- <amount_tez> montant de XTZ à transférer au contrat depuis <originator_address>. Un contrat ne doit pas avoir 0 XTZ sinon il est désactivé.
- <originator_address> l'adresse depuis laquelle prélever les XTZ à envoyer au contrat
- <contract_file> fichier .tz obtenu lors de la compilation
- --init '<storage_expression>' initialise la valeur initiale de storage au moyen de l'expression michelson obtenue précédemment
- --burn-cap 0.09225 un montant de XTZ à brûler pour pouvoir déployer le contrat
  
Dans le résultat de cette exécution, nous voyons le détail des différentes opérations et des frais payés.

## Test du smart contract déployé

Nous pouvons maintenant tester notre contrat.

+ ligo compile parameter

https://better-call.dev/edo2net/KT1NzAQFhs8PmnHaUK4cdFtvnXdezKvTExBz/interact?entrypoint=updateName

```tezos-client transfer 0 from alex to KT1NzAQFhs8PmnHaUK4cdFtvnXdezKvTExBz --entrypoint 'updateName' --arg '"toto"' --burn-cap 0.0025

```

### Avec tezos-client

```
tezos-client transfer <amount_tez> from <user> to <contract_name> --arg '<entrypoint_invocation>' --dry-run
```

### Avec Taquito

## Evolutions

Nous avons vu ici un simple smart contract pour poser les bases du Ligo. De nombreuses autres possibilité existent :
- Créer un storage complexe, composé d'un structure plus complète, pour gérer un ensemble de valeurs.
- Recevoir et envoyer des XTZ
- Interagir avec autre smart contracts
- Manipuler des collections et des structures de contrôle
- Gérer des exceptions
- ...


## Docs

https://medium.com/chain-accelerator/i-tested-tezos-b254504775be

https://medium.com/chain-accelerator/how-to-use-tezos-rpcs-16c362f45d64

https://training.nomadic-labs.com/download/interact_with_the_blockchain.pdf

https://hackernoon.com/how-to-build-a-tezos-dapp-using-taquito-and-the-beacon-sdk-0n183ymn (obsolète)

Tezos RPC guide https://tezos.gitlab.io/007/rpc.html

Taquito https://tezostaquito.io/docs/quick_start

Liquidity compiler https://www.liquidity-lang.org/edit/

Ligo https://ligolang.org/docs/next/language-basics/types