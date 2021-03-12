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
| ResetName
| DoNothing;

// Met à jour le nom stocké
let changeName = ( ( newName): ( string) ): string => {
    // Concatenate "hello" and the name into a string
    let result : string = "Hello "  ++ newName;

    // Return result
    result;
};

let reset = ( (contractStorage): (string) ): string => {

    // Reset hello with nobody
    let result : string = "Hello nobody";

    // return reset hello sentence
    result;
}

// Ne fait rien, prend en entrée le storage et le retourne sans rien modifier
let nothing = ( (contractStorage): (string) ): string => {
    contractStorage;
}

let main = ((action, contractStorage): (pseudoEntryPoint, string)) => {

    let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName)
    | ResetName => reset(contractStorage)
    | DoNothing => nothing(contractStorage)
  };
  
  (([] : list (operation)), newStorage);

};
```

Détaillons ce code.

Tout d'abord, la fonction `main`, qui est le point d'entrée. Elle prend 2 paramètres : `action` qui est le nom de la fonction à appeler et `contractStorage` qui est l'état initial du storage.

`(action, contractStorage): (pseudoEntryPoint, string))` signifie que nous définissons 2 paramètres, action et contractStorage, qui seront respectivement de type `pseudoEntryPoint` et `string`.

Regardons les premières lignes : 
```
type pseudoEntryPoint =
| UpdateName(string)
| ResetName
| DoNothing;
```

Ligo permet de définir des types. Nous définissons ici le type pseudoEntryPoint` qui sera un **variant** (l'équivalent d'un enum en Java par exemple). Ce type pourra prendre différentes valeurs définies dans la liste. Nous utiliseront ce **variant** pour lister les actions possibles dans notre contrat.

Nous définissons ici 3 "actions" :
- `UpdateName(string)`, qui prend en paramètre un nouveau nom et met à jour la salutation.
- `ResetName`, qui revient à une salutation générique sans nom particulier
- `DoNothing`, qui ne fera rien. Cette fonction n'est pas utile en tant que telle mais elle nous permettra d'illustrer certaines spécificités d'un smart contract Ligo.

Regardons le contenu fonction main` :

```
let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName)
    | ResetName => reset(contractStorage)
    | DoNothing => nothing(contractStorage)
  };
```

Nous initialisons une variable `newStorage` dont l'affectation initiale dépendra de la valeur du paramètre d'entrée `action`. Il est attendu que la valeur passée pour `action` soit une des valeurs définies par `pseudoEntryPoint`. Le switch redirigera alors vers une fonction qui effectuera l'action voulue. C'est le fameux pattern matching.

Regardons maintenant la dernière instruction de `main` : 

```( ( [] : list (operation) ), newStorage );```

Il s'agit du "return", qui se définit en indiquant tout simplement en fin de fonction la valeur à retourner sans mot clé particulier. 

Le point d'entrée d'un smart contract doit retourner deux éléments : une liste d'opérations et le nouveau storage du contrat. La liste d'opération contient un ensemble d'opérations qui seront exécutées une fois l'appel au contrat terminé. Nous y trouverons par exemple des appels à d'autres smart contracts ...

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
Elle va concaténer "Hello" avec le nom passé en paramètre pour créer la nouvelle salutation dans la variable `result`, qui sera retournée.

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

Un smart contract Tezos retourne toujours 2 choses : une **liste d'opérations** et le **nouvel état du storage**.

La liste d'opération va servir, par exemple, à indiquer des appels à d'autres smart contracts à effectuer une fois que le contrat actuel a terminé son exécution sans erreur. (A noter qu'aucun appel à un autre smart contract ne peut avoir lieu pendant l'exécution d'un smart contract, les appels sont forcément mis dans celle liste d'opérations)

Le nouvel état du storage est retourné par la fonction main. Cette fonction ne peut donc pas retourner de résultat à proprement parler. Dans notre contrat, le storage sera donc parfois uniquement le nouveau nom, parfois la salutation complète.

Avec ce test, les données modifiée dans le storage ne sont pas conservées d'un appel à l'autre. Si nous voulons tester l'enchainement de nos fonctions, nous devons les appeler successivement en indiquant le bon état initial du storage. Par exemple, tout d'abord faisons-nous saluer alors qu'aucun nom n'a été initialisé. Puis modifions le nom, puis faisons-nous saluer à nouveau. :

```
> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'SayHello' '""'
( LIST_EMPTY() , "Hello " )

> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'UpdateName("alex")' '""'
( LIST_EMPTY() , "alex" )

> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'SayHello' '"alex"'
( LIST_EMPTY() , "Hello alex" )
```

Nous pouvons le modifier de cette façon, en explicitant mieux les données que nous manipulons et en utilisant un storage un peu plus complexe.

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