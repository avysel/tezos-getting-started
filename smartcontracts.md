# Les smart contracts avec Tezos #1, prise en mains

Les smart contracts sur Tezos sont écrits en [Michelson](https://www.michelson.org/). Ce langage à pile d'exécution est assez compliqué à utiliser. Plusieurs langages ont été créés afin de produire du code plus facilement, et qui sont compilés pour donner du Michelson :

- [Ligo](https://ligolang.org/) : il propose 3 syntaxes différentes, ReasonLIGO, PascalLIGO et CamlLIGO, inspirées respectivement de [ReasonML](https://reasonml.github.io/), Pascal et Caml.
- [SmartPy](https://smartpy.io/) : bibliothèque Python pour le développement de smart contracts Tezos en Python.
- [Morley](https://serokell.io/project-morley) : bibliothèque Haskell

Les exemples que nous allons utiliser seront en Ligo avec la syntaxe ReasonML qui est assez proche du javascript (Enfin, disons plutôt moins éloignée du javascript que les autres :) ).

## LIGO

### Installation

Tout d'abord, installons le compilateur LIGO : 

```shell
wget https://ligolang.org/bin/linux/ligo
chmod +x ./ligo
sudo cp ./ligo /usr/local/bin
```

### IDE

Il existe un IDE en ligne permettant de faire les premiers tests de smart contracts :

https://ide.ligolang.org/

Leur exécution nécessitera cependant d'avoir le fichier source en local, à portée du compilateur. 

Pour nos exemples, un simple éditeur de texte et le compilateur Ligo suffiront.


## Premier smart contract, SimpleHello

Nous allons développer un premier smart contract `SimpleHello`. Ce contrat va contenir une variable, le nom de la personne à saluer. Une fonction permettra de modifier le nom stockée. Une autre fonction permettra de se faire saluer.

### Principe général

Un contrat Tezos contient **une zone de stockage de données** (couramment appelée **storage**) et **un point d'entrée**. 

**Seul le point d'entrée est appelé**, à la différence d'autres langage où l'on peut définir des fonctions et les appeler distinctement les unes des autres.

Autre spécificité, la fonction de point d'entrée devra toujours **retourner l'intégralité du storage** stockées dans ce contrat. Cette valeur de retour ne sera pas exploitée pour être retournée à l'appelant, mais pour mettre à jour le contenu de la blockchain.

En mixant les deux conditions précédentes, nous comprenons vite qu'il ne sera pas possible de développer des getters et setters comme on peut trouver un peu partout. Mais comme le storage sera toujours disponible en totalité, pas besoin de getters.

Nous pourrons tout de même programmer plusieurs comportements en créant plusieurs fonctions à l'intérieur du contrat. Il faudra préciser en entrée du contrat quelle fonction appeler en utilisant un pattern matching sur ces paramètres d'entrée.


### Code

Voyons tout de suite le code de notre contrat exemple, que nous avons écrit dans un fichier `SimpleHello.ligo` :

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

Les fonctions se définissent sur le modèle suivant :

```
let functionName = ( (param1Name, param2Name, ...) : (param1Type, param2Type, ...) ) : returnType => {
    function body
}
```
Donc `(action, contractStorage): (pseudoEntryPoint, string))` signifie que nous définissons 2 paramètres, `action` et `contractStorage`, qui seront respectivement de type `pseudoEntryPoint` et `string`.

Regardons les premières lignes : 
```
type pseudoEntryPoint =
| UpdateName(string)
| GetHello;
```

Ligo permet de définir des types. Nous définissons ici le type `pseudoEntryPoint` qui sera un **variant** (l'équivalent d'un enum en Java par exemple). Ce type pourra prendre différentes valeurs définies dans la liste. Nous utiliserons ce **variant** pour lister les actions possibles dans notre contrat.

Nous définissons ici 2 "actions" :
- `UpdateName(string)` qui prend en paramètre un nouveau nom et met à jour la salutation.
- `GetHello` qui retourne la salutation

Regardons le contenu de la fonction `main` :

```
let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName)
    | GetHello => getHello(contractStorage)
  };
```

Nous créons une variable `newStorage` dont l'affectation initiale dépendra de la valeur du paramètre d'entrée `action`. La valeur passée pour `action` doit être une des valeurs définies par `pseudoEntryPoint`. Le switch redirigera alors vers une fonction qui effectuera l'action voulue. C'est le fameux pattern matching.

Regardons maintenant la dernière instruction de `main` : 

```( ( [] : list (operation) ), newStorage );```

Il s'agit du "return", qui se définit en indiquant tout simplement en fin de fonction la valeur à retourner, sans mot clé particulier. 

Le point d'entrée d'un smart contract doit retourner deux éléments : **une liste d'opérations et le nouveau storage du contrat**. La liste d'opération va servir, par exemple, à indiquer des appels à d'autres smart contracts à effectuer une fois que le contrat actuel a terminé son exécution sans erreur. (A noter qu'aucun appel à un autre smart contract ne peut avoir lieu pendant l'exécution d'un smart contract, les appels sont forcément mis dans celle liste d'opérations)

Ici, nous avons donc `[]` de type `list(operation)`, vide, car aucune opération n'est à exécuter ensuite dans notre exemple. Et `newStorage`, la nouvelle valeur du storage, qui aura été modifiée par l'appel à une des fonctions de notre contrat.


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
Elle va concaténer "Hello" avec le nom passé en paramètre pour créer la nouvelle salutation dans la variable `result`, qui sera retournée. La phrase "Hello newName" sera donc la nouvelle valeur du storage du contrat.

```
// Retourne le storage courant
let getHello = ( (contractStorage): (string) ): string => {
    contractStorage;
}
```
La fonction `getHello` va retourner le storage courant du contrat. Il va donc nous retourner la salutation. Le storage d'un contrat est toujours entièrement accessible. Donc cette fonction n'a pas de réelle utilité car elle ne fait rien de particulier, mais elle illustre bien le fonctionnement de Ligo. Nous le verrons plus tard lorsque nous allons essayer de l'appeler.

Attention : cet exemple fonctionne parce que notre storage ne contient qu'une seule valeur. Dans le cas de storage comprenant plusieurs valeurs (nous verrons les types `record` plus tard), si le `main` ne retourne qu'une seule d'entre elles, elle deviendra le nouveau storage et le reste sera écrasé.

## Simulation

Une fois le code du contrat écrit, nous pouvons simuler son exécution avec la commande `ligo dry-run`. Cette commande exécute le contrat hors de la blockchain, il n'a donc pas de storage. Nous allons devoir indiquer la valeur initiale d'un storage. De même, chaque appel est indépendant et les valeurs de storage, initiales ou modifiées, ne sont pas gardées en mémoire d'un appel à l'autre.

```
ligo dry-run SimpleHello.ligo --syntax reasonligo main 'GetHello' '{"Hello nobody"}'
```

Détaillons cette commande :

- `ligo` : l'exécutable ligo que nous venons d'installer
- `dry-run` : pour simuler sans réellement déployer sur la blockchain
- `SimpleHello.ligo` : le fichier contenant le code du smart contract
- `--syntax reasonLigo` : la syntaxe Ligo choisie
- `main` : le nom du point d'entrée à exécuter
- `'GetHello'` : le paramètre `action` de notre point d'entrée
- `'{"Hello nobody"}' (ou '"Hello nobody"')` : l'état initial du storage, le paramètre `contractStorage`. Notez bien les `'` qui délimitent la valeur du storage initial et les `"` qui délimitent une chaine de caractère dans ce storage initial.

Nous obtenons le retour suivant :

```
( LIST_EMPTY() , "Hello nobody" )
```

Nous voyons bien les 2 choses retournées par un contrat : la **liste d'opérations** (vide, dans notre cas) et le **nouvel état du storage**.

Testons maintenant la mise à jour en partant d'un storage initial vide en appelant le pseudo point d'entrée `UpdateName(string)` :

```
> ligo dry-run SimpleHello.ligo --syntax reasonligo main 'UpdateName("alex")' '{""}'
( LIST_EMPTY() , "Hello alex" )
```
Ca fonctionne !

## Compilation

La simulation est positive, nous allons maintenant passer aux choses sérieuses et chercher à déployer le contrat.
Première étape, il faut le compiler. Il doit être transpilé depuis le langage choisi pour l'écriture vers du Michelson.

```
ligo compile-contract --syntax reasonligo SimpleHello.ligo main > SimpleHello.tz
```

En détail :
- `ligo compile-contract` : la commande de compilation
- `--syntax reasonligo` : la syntaxe choisie
- `SimpleHello.ligo main > SimpleHello.tz` : nom du fichier Ligo, nom du point d'entrée, `>` et nom du fichier `.tz` pour la sortie du résultat Michelson. 

Il est possible de ne pas préciser la syntaxe en renommant notre fichier `.ligo` en `.religo`, l'extension spécifique à ReasonLigo :

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

Notez au passage que les noms des points d'entrée GetHello et UpdateName ont perdu leur majuscule initiale (Nous aurions très bien pu l'écrire en camelCase dès le départ). Pour les appeler, il faudra bien utiliser la syntaxe générée en Michelson.

Il ne reste plus qu'à le déployer.

## Déploiement

Au déploiement d'un contrat, il faut préciser la valeur initiale du storage. Nous l'avons déjà expérimenté précédemment lors de la simulation avec la commande ligo. Le déploiement nécessite que cette expression soit en syntaxe Michelson cette fois.

Il existe une commande pour convertir l'expression Ligo vers l'expression Michelson.
```
> ligo compile-storage SimpleHello.ligo --syntax reasonligo main  '{"Hello nobody"}'
"Hello nobody"
```

Bon, notre storage initial étant une simple chaîne, nous obtenons une autre chaine, rien d'exceptionnel. Mais pour un contrat nécessitant un storage initial plus complexe, cette commande sera bien utile.

Nous pouvons déployer en utilisant `tezos-client`. Cette opération s'appelle l'**origination** d'un contrat.

Pour déployer un contrat, il faut préciser combien de XTZ le compte de déploiement lui transfert, même si c'est 0 XTZ.

Voilà la commande : 

```
tezos-client originate contract <contract_name> transferring <amount_tez> from <originator_address> running <contract_file> --init '<storage_expression>' --burn-cap 0.09225
```

Détaillons cette commande :
- `tezos-client originate contract` commande de déploiement
- `<contract_name>` nom du smart contract
- `transferring <amount_tez>` montant de XTZ à transférer au contrat depuis <originator_address>. Un contrat ne doit pas avoir 0 XTZ sinon il est désactivé.
- `from <originator_address>` l'adresse du compte propriétaire du contrat, depuis laquelle prélever les XTZ à envoyer au contrat
- `running file <contract_file>` fichier .tz à déployer
- `--init '<storage_expression>'` initialise la valeur initiale de storage au moyen de l'expression michelson obtenue précédemment
- `--burn-cap 0.09225` un montant de XTZ à brûler pour pouvoir déployer le contrat (au cas où la valeur indiquée serait trop juste, un message d'erreur donnera la bonne valeur)
  
Pour notre contrat, ça donnera : 

```
tezos-client originate contract SimpleHello transferring 0 from tz1... running SimpleHello.tz --init '""' --burn-cap 0.09225
```

Dans le résultat de cette exécution, nous voyons le détail des différentes opérations et des frais payés. Et bien entendu, l'adresse de notre contrat. Elle commence par **KT1**.

Le site [BetterCallDev](https://better-call.dev/) propose une interface web pour visualiser les contrats. Il faut choisir le réseau sur lequel nous avons déployé. Ici, Edo2net. Puis saisir l'adresse KT1 dans le champ de recherche en haut à droite, et si notre contrat est bien déployé, nous pourrons voir les détails : le code Michelson, la valeur du storage ...

Cela montre également la transparence de Tezos, où tous les contrats, code et storage, sont visibles par tout le monde.

## Test du smart contract déployé

Nous pouvons maintenant tester notre contrat.

### Avec tezos-client

Pour interagir avec un smart contract, la commande est la suivante :

```
tezos-client transfer <amount_tez> from <user> to <contract_name> --entrypoint '<entry_point>' --arg '<entry_params>' --burn-cap 0.0025 --dry-run
```

- `tezos client transfer` (tout appel à un contrat est d'abord un transfert de XTZ, fut-il de zéro)
- `<amount_tez>` le nombre de XTZ à envoyer au contrat avec cette transaction
- `from <user>` l'adresse tz1 utilisée pour envoyer la transaction d'appel
- `to <contract_name>` le nom du contrat ou son adresse KT1
- `--entrypoint <entry_point>` le point d'entrée à appeler
- `--arg <entry_params>` les paramètres d'appel au point d'entrée
- `--burn-cap 0.0025` un montant de XTZ à brûler afin de pouvoir modifier le storage, non obligatoire si le storage n'est pas modifié (si nous passons une chaine vide en paramètre, dans notre exemple)
- `--dry-run` pour simuler la transaction sans l'envoyer réellement. A ne pas mettre pour envoyer la transaction pour de bon.

```
tezos-client transfer 0 from tz1... to SimpleHello --entrypoint 'updateName' --arg '"alex"' --burn-cap 0.0025
```

Essayons maintenant de lire le storage : 
```
tezos-client transfer 0 from tz1... to SimpleHello --entrypoint 'getHello'
```

Nous n'obtenons aucun retour. Le storage n'est pas retourné lors d'un appel à une fonction. Nous avons donc la confirmation que cette fonction est inutile.
Nous pouvons accéder directement au storage via la commande :

```
> tezos-client get contract storage for SimpleHello (ou KT1...)
"Hello alex"
```

Nous pouvons aussi directement interroger notre nœud local via RPC si nous en avons un :
```
curl http://localhost:8732/chains/main/blocks/head/context/contracts/<adresse KT1 du contrat>/storage
```

### Avec Taquito

Nous allons essayer de faire la même chose avec [Taquito](https://tezostaquito.io/), le framework Typescript pour Tezos [que nous avons vu précédemment](https://blog.ineat-group.com/2021/03/demarrer-avec-la-blockchain-tezos/).

Cette fois, nous allons modifier la blockchain, donc nous allons de voir initialiser le framework avec notre clé privée afin de signer la transaction.
Dans l'exemple, nous allons passer notre clé directement dans le code. Taquito fourni aussi des extensions pour importer une clé depuis un wallet dans le navigateur, beaucoup plus sécurisé.

Pour obtenir la clé privé du compte qui enverra la transaction :

```tezos-client show address tz1... -S```

Dans notre exemple, nous allons d'abord lire et afficher le storage du contrat, puis le modifier pour obtenir "Hello from Taquito" et enfin, lire le nouveau storage.

Notre code est le suivant :

```javascript
import { TezosToolkit } from '@taquito/taquito';
import { InMemorySigner, importKey } from '@taquito/signer';

// L'adresse du smart contract
const contractAddress = "KT1...";

// Connexion au noeud local.
const Tezos = new TezosToolkit('http://127.0.0.1:8732');

// Import de la clé privée pour signer la transaction
Tezos.setProvider({ signer: new InMemorySigner('<YOUR_PRIVATE_KEY>') });

// Tout est Promise, nous devons être async
(async () => {

    // Chargement du smart contract
    let contract = await Tezos.contract.at(contractAddress);

    // lecture du storage courant
    console.log(`Read current storage: `+await contract.storage());

    console.log(`Update with "Hello from Taquito":`);

    // Appel de la methode "updateName"
    contract.methods.updateName("from Taquito").send()
      .then((op) => {
        // la transaction est créée, elle attend d'être confirmée
        console.log(`Waiting for ${op.hash} to be confirmed...`);

        // Après 1 confirmation, nous la considérons comme validée. Nous renvoyons le hash.
        return op.confirmation(1).then(() => op.hash);
      })
      .then( async (hash) => {
            // Le hash de la transaction est obtenu, elle est validée, nous affichons le lien pour l'afficher dans tzstats
            console.log(`Operation injected: https://edo.tzstats.com/${hash}`);

            // Affichage du nouveau storage
            console.log(`Read new storage: `+await contract.storage());
        })
      .catch(console.error);

})().catch(console.error);
```

## Evolutions

Nous avons vu ici un smart contract très simple pour poser les bases du Ligo. 

De nombreuses autres possibilité existent :
- Créer un storage complexe, composé d'un structure plus complète, pour gérer un ensemble de valeurs.
- Recevoir et envoyer des XTZ
- Interagir avec autre smart contracts
- Manipuler des collections et des structures de contrôle
- Gérer des exceptions
- ...

Nous verrons un [exemple plus complexe au prochain épisode](smartcontracts2.md).

En attendant, vous pouvez vous entrainer avec d'excellents petits sites : [Tezos Academy](https://tezosacademy.io) pour Ligo et [Cryptocode School](https://cryptocodeschool.in/tezos/) pour SmartPy, qui proposent des tutos sous forme de jeux.


## Liens

[Découverte de Tezos](https://blog.ineat-group.com/2021/03/demarrer-avec-la-blockchain-tezos/)

[Michelson](https://www.michelson.org/), [Ligo](https://ligolang.org/), [SmartPy](https://smartpy.io/), [Morley](https://serokell.io/project-morley).

[IDE Ligo en ligne](https://ide.ligolang.org/)

[BetterCallDev](https://better-call.dev/)

[Tezos RPC guide](https://tezos.gitlab.io/007/rpc.html)

[Taquito](https://tezostaquito.io/docs/quick_start)

[Tezos Academy](https://tezosacademy.io), [Cryptocode School](https://cryptocodeschool.in/tezos/)
