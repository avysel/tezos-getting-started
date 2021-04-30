# Les smart contracts avec Tezos #2, notions avancées

Nous allons reprendre notre contrat `SimpleHello` de l'étape précédente et nous allons l'améliorer pour qu'il devienne **BetterHello**.

Voilà ce que nous allons lui faire :
- Enregistrer l'adresse de celui qui demande à changer de nom
- Rendre le changement de nom payant, 1 XTZ à chaque fois
- Permettre à son propriétaire de récupérer tous ces XTZ
- Répercuter le changement de nom dans `SimpleHello` précédemment déployé

## Point de départ

Voici donc notre point de départ, le code de `SimpleHello` (dont nous avons supprimé `getHello` qui ne servait à rien).

Cette fois, notre fichier s'appelle `BetterHello.religo`.

```
type pseudoEntryPoint =
| UpdateName(string);

let changeName = ( ( newName): ( string) ): string => {
    let result : string = "Hello "  ++ newName;
    result;
};

let main = ((action, contractStorage): (pseudoEntryPoint, string)) => {
    let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName)
  };
  (([] : list (operation)), newStorage);
};
```

## Enregistrer l'adresse de l'émetteur

### Le code
Nous allons maintenant stocker la salutation mais aussi l'adresse de celui qui a changé le nom la dernière fois et la date de la mise à jour. Nous allons donc devoir modifier le **storage** du contrat pour qu'il puisse prendre en charge plusieurs données. Pour cela, nous allons utiliser un **record**, qui est un type composite (un peu comme un **struct** en C/C++)

Créons d'abord le **record** :

```
type storage = {
  hello         : string,
  update_user   : address,
  update_date   : timestamp
};
```

Notre nouveau type s'appelle **storage**. Les variables de ce type auront 3 champs ```hello``` de type ```string```, ```update_user``` de type ```address``` et ```update_date``` de type ```timestamp``` (en Ligo, le ```timestamp``` est le seul type de gestion de dates).

Modifions notre fonction ```changeName``` pour utiliser ce nouveau type :

```
let changeName = ( ( newName, contractStorage): ( string, storage) ): storage => {
      ...contractStorage,
     hello: "Hello "  ++ newName,
     update_user: Tezos.sender,
     update_date: Tezos.now
};
```

Nous lui avons ajouté un paramètre `contractStorage` de type `storage` défini précédemment. Il contiendra l'état du **storage** du contrat, que nous allons devoir modifier et retourner en intégralité. Nous avons donc aussi modifié le type de retour en `storage`.

Analysons le corps de la fonction. Il contient une seule expression, écrite sur plusieurs lignes pour la lisibilité, mais qui peut également être écrite en une seule ligne.

La modification d'un **record** se fait en générant un nouveau record et en précisant uniquement quel champs sont modifiés. Chacune de ces instructions étant séparées par une virgule. Le tout forme une expression qui retourne une copie du **record** d'entrée avec les valeurs modifiées.

` ...contractStorage, ` est le "spread operator" qui crée la copie du **record** et expose tous les champs disponibles.

`hello: "Hello "  ++ newName,    update_user: Tezos.sender,    update_date: Tezos.now` vient mettre à jour les champs avec les nouvelles valeurs.

Remarquons l'utilisation de `Tezos.sender` qui contient l'adresse qui a invoqué le contrat et `Tezos.now` qui contient le timestamp du bloc courant.


#### Sender vs source
Dans le cas d'un utilisateur qui appelle un contrat A qui lui-même appelle un contrat B, dans B `Tezos.sender` sera l'adresse de A. L'adresse de l'utilisateur à l'origine de la chaîne sera `Tezos.source`.

#### Date et heure
Il n'est pas possible d'obtenir le timestamp de l'heure "réelle" car cette instruction sera exécutée sur un réseau distribué, donc sans serveur central qui peut fournir une horloge "officielle". Chaque noeud peut avoir une heure locale légèrement différente des autres, cette donnée ne peut donc pas être exploitée. C'est le timestamp du bloc, créé par le baker, qui est utilisé comme repère temporel.

## Le test

Pour tester, nous utilisons la commande `ligo dry-run` que nous avons déjà vu dans l'[article précédent](smartcontracts.md). Nous y ajoutons `--sender tz1...` pour indiquer l'adresse avec laquelle nous appelons.

```
ligo dry-run BetterHello.religo  main 'UpdateName("toto")' '{hello:"nobody", update_user:("tz1..." : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}' --sender tz1...
```

L'état initial du storage que nos devons utiliser ici est plus complexe parce qu'elle doit comporter tous les champs du **record**. Chaque valeur du record **doit être initialisée**.

Nous obtenons en retour :
```
( LIST_EMPTY() ,
  record[hello -> "Hello toto" ,
         update_date -> +1 ,
         update_user -> @"tz1..."] )

```
La salutation dans le champ `hello` a bien été mise à jour. La date est mise à jour avec `1` car `ligo dry-run` n'est lié à aucune blockchain donc nous serons toujours à la première seconde d'une simili-blockchain générée temporairement pour l'occasion. `update_user` est bien alimenté avec l'adresse indiquée par `--sender`.


## Rendre le changement de nom payant

Nous allons exiger de recevoir 1 XTZ pour autoriser le changement de nom. Si nous ne les recevons pas, l'exécution du contrat tombera en échec.

Le contrat sera propriétaire des XTZ envoyés.

### Le code

Voilà le code modifié de `changeName` : 

```
let changeName = ( ( newName, contractStorage): ( string, storage) ): storage => {

    if (Tezos.amount >= 1tez) {
        { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now }
    }
    else {
      (failwith("Must pay 1 tez to change name"): storage);
    }
};
```

Nous utilisons `Tezos.amount` pour connaître le montant de XTZ transférés au contrat. Le nombre obtenu peut être exploité avec 2 type : `tez` (un nombre de XTZ) ou `mutez` un millionième de `tez`.

Nous pouvons écrire notre condition de plusieurs façons :
- `Tezos.amount >= 1tez`
- `Tezos.amount >= 1tz`, `tz` étant un alias de `tez`.
- `Tezos.amount >= 1000000mutez`
- ou encore `Tezos.amount >= 1_000_000mutez` parce qu'il est permis d'ajouter des underscores afin d'améliorer la lisibilité des grands nombres.
- ou pourquoi pas `Tezos.amount >= (0.5tz + 500_000mutez)`parce que les `tez` sont avant tout des nombres comme les autres.

Regardons maintenant ce qui se passe dans le `else` :

``` 
( failwith("Must pay 1 tez to change name"): storage);
```
`failwith("Must pay 1 tez to change name")` permet d'interrompre l'exécution du script et de retourner un message d'erreur.

Le problème est que notre fonction doit retourner un objet de type `storage`. Si on l'interrompt, elle ne retourne rien, ce qui n'est pas accepté dans un langage fortement et statiquement typé comme Ligo.
Pour ça, nous allons utiliser une **annotation**. C'est une syntaxe qui va permettre d'aider le compilateur en indiquant quel type l'expression annotée aurait dû avoir.

`( expression : type attendu)`

Nous annotons donc notre `failwith` avec le type `storage`.

### Le test

Ajoutons `--amount 1` à notre instruction de test pour simuler l'envoi de 1 XTZ :

```
ligo dry-run BetterHello.religo  main 'UpdateName("toto")' '{hello:"nobody",update_user:("tz1..." : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}' --amount 1
```

Le retour :
```
( LIST_EMPTY() ,
  record[hello -> "Hello toto" ,
         update_date -> +1 ,
         update_user -> @"tz1..."] )

```

Testons maintenant en envoyant une somme inférieure : 
```
ligo dry-run BetterHello.religo  main 'UpdateName("toto")' '{hello:"nobody",update_user:("tz1..." : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}' --amount 0.5
```

Le constat est alors sans appel :

```
failwith("Must pay 1 tez to change name")
```

## Récupérer les XTZ

Maintenant que le contrat ramène un peu d'argent, en tant que propriétaire, nous souhaitons retirer tous ces XTZ sur notre wallet. Mais il ne faut pas que tout le monde puisse le faire ! 

Nous allons mettre en place plusieurs choses :
- une constante qui contient notre adresse, seule autorisée à retirer les XTZ.
- une fonction `Withdraw` qui effectue le transfert vers notre adresse uniquement si nous l'appelons depuis celle-ci.

### Le code

Nous avons vu précédemment qu'il n'est pas possible d'appeler un autre contrat ou de transférer des XTZ pendant l'exécution d'un contrat. Ces opérations sont listées pendant l'exécution, retournées une fois l'appel terminé puis exécutées.

Nous allons devoir remplir le fameux champ `([] : list (operation)` retourné par le point d'entrée `main`.

Notre fonction de retrait va donc devoir retourner une liste d'opérations et la nouvelle valeur du storage (qui ne devrait pas changer lors de l'exécution de cette fonction).

Nous allons également devoir modifier la fonction `changeName` pour qu'elle retourne également ces deux éléments. Ainsi, l'appel à nos deux fonctions retournera un résultat compatible avec ce que `main` attend.

Nous obtenons alors le code suivant :

```
type pseudoEntryPoint =
| UpdateName(string)
| Withdraw;

type storage = {
  hello         : string,
  update_user   : address,
  update_date   : timestamp
};

type return = ( list(operation), storage);

let ownerAddress : address = ("tz1..." : address);

let changeName = ( ( newName, contractStorage): ( string, storage) ): return => {

    if (Tezos.amount >= 1tez) {
        let newStorage = { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now };
         (([] : list (operation)), newStorage);
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }
};

let withdraw = ( (contractStorage): (storage) ): return => {

    if (Tezos.sender != ownerAddress) {
        ( failwith("Operation not allowed") : return);
    }
    else {
        let receiver : contract(unit) =
          switch ( Tezos.get_contract_opt (ownerAddress): option(contract(unit)) ) {
          | Some(contract) => contract
          | None => (failwith ("Not a contract") : (contract(unit)))
          };

        let withdrawOperation : operation = Tezos.transaction (unit, amount, receiver) ;
        let operations : list (operation) = [withdrawOperation];
        (operations, contractStorage);
    }
}

let main = ((action, contractStorage): (pseudoEntryPoint, storage)) => {
    switch (action) {
    | UpdateName(newName) => changeName(newName, contractStorage)
    | Withdraw => withdraw(contractStorage)
  };
};
```

Détaillons ces changements : 

```
type pseudoEntryPoint =
| UpdateName(string)
| Withdraw;
```
Nous ajoutons la valeur `Withdraw` pour le pattern matching des points d'entrée.

```
let ownerAddress : address = ("tz1..." : address);
``` 
Nous créons `ownerAddress` qui contient notre adresse Tezos, celle avec laquelle nous devons appeler `withdraw` et qui recevra l'argent.

```
type return = ( list(operation), storage);
```
Nous définissions un type qui s'appelle `return` et qui contient une liste d'opérations et un `storage`. C'est le type de retour attendu pour `main`. Nous l'appliquons à toutes les fonctions du pattern matching appliqué dans `main`.

```
let changeName = ( ( newName, contractStorage): ( string, storage) ): return => {

    if (Tezos.amount >= 1tez) {
        let newStorage = { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now };
         (([] : list (operation)), newStorage);
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }
};
```

`changeName` retourne maintenant un `return`. La modification du storage est placée dans une variable `newStorage` qui sera retournée conjointement à une liste d'opérations vide afin de correspondre à la définition de `return`.

Le fait de regrouper plusieurs valeurs pour les utiliser ou les retourner conjointement s'appelle un **tuple**. (x,y,z) ou (listOperations, storage) sont des tuples. Un tuple diffère d'un **record** car il n'a pas besoin d'être déclaré avant d'être utilisé.

L'annotation sur le `failwith` est également modifiée pour `return`.

```
let withdraw = ( (contractStorage): (storage) ): return => {

    if (Tezos.sender != ownerAddress) {
        ( failwith("Operation not allowed") : return);
    }
    else {
        let receiver : contract(unit) =
          switch ( Tezos.get_contract_opt(ownerAddress): option(contract(unit)) ) {
          | Some(contract) => contract
          | None => (failwith ("Not a contract") : (contract(unit)))
          };

        let withdrawOperation : operation = Tezos.transaction (unit, Tezos.balance, receiver) ;
        let operations : list (operation) = [withdrawOperation];
        (operations, contractStorage);
    }
}
```

Nous créons la fonction `withdraw` pour retirer l'argent accumulé sur le contrat.

Tout d'abord, nous vérifions avec `Tezos.sender != ownerAddress` que personne d'autre que nous ne puisse exécuter cette fonction.

Ensuite, nous chargeons le contrat correspondant à notre adresse (dans Tezos, tout est considéré comme un contrat, même les simples adresses de comptes) avec `Tezos.get_contract_opt(ownerAddress): option(contract(unit)) `
Cette instruction signifie que nous appelons `Tezos.get_contract_opt(ownerAddress)` qui peut retourner un `option(contract(unit))`.

C'est ce que l'on appelle un `Optional`. Ca signifie que cette fonction retournera soit un objet de type `contract` soit rien (si le contrat n'existe pas, ou que l'adresse est erronée par exemple). Pour exploiter un `optional`, nous allons appliquer un pattern matching sur les valeurs `Some(value)`, qui signifie que la valeur espérée est présente dans le champ `value`, et `None` qui indique qu'il n'y a pas de donnée retournée.

Le `unit` de `contract(unit)` représente un type de donnée qui ne contient aucune valeur (comme `null` dans d'autres langages). Un `contract` peut prendre des paramètres en ... paramètre. Nous n'avons pas besoin d'en passer ici, donc nous utilisons `unit`.

Le résultat de cet appel est stocké dans la variable `receiver` de type `contract(unit)`, qui représente l'entité à qui l'on peut envoyer des fonds.

```
let withdrawOperation : operation = Tezos.transaction (unit, Tezos.balance, receiver) ;
```
Maintenant nous créons l'opération de transfer avec `Tezos.transaction` qui prend en paramètres des options (`unit` pour nous, car pas d'option spéciale dans notre cas), le montant à transférer (ici `Tezos.balance`, la balance du contrat), et le destinataire (le `receiver` que nous avons défini au-dessus).  

Puis nous créons une liste d'opérations que nous retournons conjointement au `storage` du contrat que nous n'avons pas exploité. Mais que nous devons quand même retourner pour qu'il ne soit pas écrasé.

```
let main = ((action, contractStorage): (pseudoEntryPoint, storage)) => {
    switch (action) {
    | UpdateName(newName) => changeName(newName, contractStorage)
    | Withdraw => withdraw(contractStorage)
  };
};
```

Et pour finir nous modifions `main` en ajoutant le pattern matching avec `Withdraw` et en simplifiant la gestion du retour étant donné que les deux fonctions retournent la même chose maintenant.

### Le test

Testons :
```
ligo dry-run BetterHello.religo  main 'Withdraw' '{hello:"nobody",update_user:("tz1" : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}' --amount 1
```

Le résultat :
```
failwith("Operation not allowed")
```
Effectivement, nous ne l'appelons pas de la bonne adresse.

Ajoutons `--sender tz1...` pour préciser notre adresse d'appel, qui doit être la même que `ownerAddress` et `--balance 10` pour définir la balance de notre contrat pour ce test à 10 XTZ :

```
ligo dry-run BetterHello.religo  main 'Withdraw' '{hello:"nobody",update_user:("tz1..." : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}' --amount 1 --sender tz1... --balance 10
```

Nous obtenons :

```
( CONS(Operation(0135a1ec49145785df89178dcb6e96c9a9e1e71e0a0000000180ade204000053c1edca8bd5c21c61d6f1fd091fa51d562aff1d00) ,
       LIST_EMPTY()) ,
  record[hello -> "nobody" ,
         update_date -> +946721410 ,
         update_user -> @"tz1..."] )

```

Notre opération apparaît bien dans la liste retournée. Mais `ligo dry-run` ne nous permet pas de vérifier son exécution. Nous le testerons par la suite.

## Répercuter le changement sur SimpleHello

Maintenant, à chaque fois que quelqu'un paye pour modifier le nom dans `BetterHello`, nous lui offrons la mise à jour dans `SimpleHello` que nous avons déjà déployé précédemment.

Nous allons créer une nouvelle variable qui contient l'adresse de SimpleHello, une fonction `callSimpleHello` qui fera l'appel et nous l'appelerons depuis `changeName`.

Ajoutons donc une variable avec l'adresse de SimpleHello

```
let simpleHelloAddress : address = ("KT1Qgeo4RBWq9HzXaQDa7su8Kz9jCD3zCyhv" : address);
```


Et le reste du code :
```
let callSimpleHello = ( (newName): (string) ): operation => {
       let simpleHelloContract : contract(string) =
            switch( Tezos.get_entrypoint_opt("%updateName", simpleHelloAddress): option(contract(string)) ) {
              | Some(contract) => contract
              | None => (failwith ("SimpleHello not found") : (contract(string)))
            };

       let callOperation : operation = Tezos.transaction (newName, 0tez, simpleHelloContract) ;
       callOperation;
}
```
Elle fonctionne de la même façon que `withdraw`. Sauf que cette fois, nous utilisons `Tezos.get_entrypoint_opt("%updateName", simpleHelloAddress)` pour créer l'objet à utiliser pour interagir avec le contrat. Il prend en paramètre le nom du point d'entrée préfixé par "%". Attention également à bien prendre le point d'entrée en syntaxe Michelson, celui dans le fichier SimpleHello.tz. Dans notre cas, celui du fichier Ligo commence par une majuscule. Si nous avions utilisé celui là, l'optional aurait retourné `None` car `UpdateName` avec majuscule n'existe pas dans le contrat déployé en Michelson.

Nous manipulons un object `contract(string)` parce que notre fonction `updateName` de `SimpleHello` prend une `string` en paramètre.

Nous créons l'opération avec `Tezos.transaction` qui prend en premier paramètre `newName`, la valeur à passer en paramètre à `updateName` de `SimpleHello`. Les deuxième et troisième paramètres sont toujours le montant à transférer et le destinataire.

Enfin, nous retournons l'opération.

Cette fois, pas besoin de retourner le storage étant donné que notre fonction sera appelée depuis une autre fonction et non `main`.

```
let changeName = ( ( newName, contractStorage): ( string, storage) ): return => {

    if (Tezos.amount >= 1tez) {
        let newStorage = { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now };
        let callOperation : operation = callSimpleHello(newName);

         (([callOperation] : list (operation)), newStorage);
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }
};
```
Dans `changeName`, il suffit d'appeler `callSimpleHello`, et de mettre l'opération récupérée dans la liste passée en résultat.

## Compilation et déploiement

Notre contrat est au point, nous allons pouvoir le compiler.

```
ligo compile-contract BetterHello.religo main > BetterHello.tz
```

Nous devons également compiler la valeur initiale de notre storage, plus complexe cette fois :
```
ligo compile-storage BetterHello.religo main  '{hello:"nobody",update_user:("tz1..." : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}'
```
On obtient :
```
(Pair (Pair "nobody" "2000-01-01T10:10:10Z") "tz1...")
```

Nous pouvons déployer :

```
tezos-client originate contract BetterHello transferring 0 from tz1... running BetterHello.tz --init '(Pair (Pair "nobody" "2000-01-01T10:10:10Z") "tz1...")' --burn-cap 0.224
```
Vous aurez peut-être un message qui vous demande d'augmenter le burn-cap. Ce contrat étant plus gros que `SimpleHello`, il nécessite plus de ressources.


## Test

Nous pouvons le tester.

Changer le nom sans payer :
```
tezos-client transfer 0 from tz1... to BetterHello --entrypoint 'updateName' --arg '"alex"' --burn-cap 0.0025
```
La transaction n'est même pas envoyée, le client Tezos repère tout de suite qu'une condition n'est pas remplie. C'est l'avantage avec la validation formelle, pas besoin d'exécution, donc de payer des frais de transactions pour rien, pour se rendre compte que ça ne fonctionnera pas.

Donc on paye :
```
tezos-client transfer 1 from tz1... to BetterHello --entrypoint 'updateName' --arg '"alex"' --burn-cap 0.0025
```
Dans un [explorateur de bloc](https://edo.tzstats.com/), nous pouvons aller inspecter cette transaction et notre contrat. Nous devons trouver qu'il a bien émis une transaction vers `SimpleHello` et que sa balance et maintenant de 1 XTZ.

Essayons de récupérer cet argent :
```
tezos-client transfer 0 from tz1... to BetterHello --entrypoint 'withdraw'  --burn-cap 0.0055
```
Nous pouvons constater que 1 XTZ a été transféré depuis le contrat vers notre adresse. Il est également intéressant de constater que les appels entre nos deux contrats ne coûtent rien du tout. 

## Conclusion

Dans cette seconde partie, nous avons appris à 
- Gérer un storage complexe avec des *records*
- Exploiter des 'build-in' Tezos (sender, source, amount ...)
- Recevoir et transférer des XTZ
- Manipuler des dates, des adresses, des nombres et des XTZ
- Interrompre une exécution de contrat
- Appeler un autre contrat
- Conditionner des opérations au propriétaire du contrat

Il est possible d'aller encore plus loin :
- Historiser les changements de nom grâce à des structures de données telles que Maps ou des Lists
- Exploiter l'intégralité des built-in Tezos offerts par Ligo
- Optimiser l'écriture du contrat pour optimiser les coûts de déploiement

Mais avec tout ce que nous avons vu, nous avons déjà largement de quoi écrire des applications décentralisées complètes avec Tezos !