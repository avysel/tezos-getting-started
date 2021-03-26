# Smart contracts, 2ᵉ partie

Nous allons reprendre notre contrat **SimpleHello** de l'étape précédente nous allons l'améliorer pour qu'il devienne **BetterHello**.

Voilà ce que nous allons lui faire :
- Enregistrer l'adresse de celui qui demande à changer de nom
- Rendre le changement de nom payant, 1 XTZ à chaque fois
- Permettre à son propriétaire de récupérer tous ces XTZ
- Répercuter le changement de nom dans **SimpleHello** précédemment déployé
- Maintenir un historique des changements

## Point de départ

Voici donc notre point de départ, le code de **SimpleHello** (dont nous avons supprimé *getHello* qui ne servait à rien).

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

Notre nouveau type s'appelle **storage**. Les variables de ce type auront 3 champs ```hello``` de type ```string```, ```update_user``` de type ```address``` et ```update_date``` de type ```timestamp``` (en Ligo, le ```timestamp``` est le seul type de gestions de dates).

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

Pour tester, nous utilisons la commande `ligo dry-run` que nous avons déjà vu dans l'[article précédent](smartcontracts.md)

```
ligo dry-run BetterHello.religo  main 'UpdateName("toto")' '{hello:"nobody", update_user:("tz1..." : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}'
```

L'état initial du storage que nos devons utiliser ici est plus complexe parce qu'elle doit comporter tous les champs du **record**. Chaque valeur du record **doit être initialisée**.

Nous obtenons en retour :
```
( LIST_EMPTY() ,
  record[hello -> "Hello toto" ,
         update_date -> +1 ,
         update_user -> @"tz1..."] )

```
La salutation dans le champ `hello` a bien été mise à jour. La date est mise à jour avec `1` car `ligo dry-run` n'est lié à aucune blockchain donc nous serons toujours à la première seconde d'une simili-blockchain générée temporairement pour l'occasion. `update_user` est bien alimenté avec une adresse temporaire générée, elle aussi, pour l'occasion.

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
- `Tezos.amount >= 1 tez`
- `Tezos.amount >= 1 tz`, `tz` étant un alias de `tez`.
- `Tezos.amount >= 1000000 mutez`
- ou encore `Tezos.amount >= 1_000_000 mutez` parce qu'il est permis d'ajouter des underscores afin d'améliorer la lisibilité des grands nombres.
- ou pourquoi pas `Tezos.amount >= (0.5 tz + 500_000 mutez)`parce que les `tez` sont avant tout des nombres comme les autres.

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
- une fonction qui effectue le transfert

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

let ownerAddress : address = ("tz1TGu6TN5GSez2ndXXeDX6LgUDvLzPLqgYV" : address);

let changeName = ( ( newName, contractStorage): ( string, storage) ): return => {

    if (Tezos.amount >= (0.5tz + 500_000mutez)) {
        let newStorage = { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now };
         (([] : list (operation)), newStorage);
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }
};

let withdraw = ( (contractStorage): (storage) ): return => {

    let receiver : contract(unit) =
      switch ( Tezos.get_contract_opt (ownerAddress): option(contract(unit)) ) {
      | Some(contract) => contract
      | None => (failwith ("Not a contract") : (contract(unit)))
      };

    let withdrawOperation : operation = Tezos.transaction (unit, amount, receiver) ;
    let operations : list (operation) = [withdrawOperation];
    (operations, contractStorage);
}

let main = ((action, contractStorage): (pseudoEntryPoint, storage)) => {
    switch (action) {
    | UpdateName(newName) => changeName(newName, contractStorage)
    | Withdraw => withdraw(contractStorage)
  };
};
```

### Le test

## Répercuter le changement **SimpleHello**

## Historique des changements

## Compilation

Même opération avec les paramètres d'entrée :

```
ligo compile-parameter --syntax reasonligo SimpleHello.ligo main 'UpdateName("toto")'
> (Right "toto")
```

## Déploiement

## Test

## Conclusion

Dans cette seconde partie, nous avons appris à 
- Gérer un storage complexe avec des *records*
- Exploiter des 'build-in' Tezos (sender, source, amount ...)
- Recevoir et transférer des XTZ
- Manipuler des dates, des adresses, des nombres et des XTZ
- Interrompre une exécution de contrat
- Appeler un autre contrat
- Exploiter des structures de données
- Conditionner des opérations au propriétaire du contrat