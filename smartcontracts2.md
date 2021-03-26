# Smart contracts, 2ème partie

Nous allons reprendre notre contrat **SimpleHello** de l'étape précédente nous allons l'améliorer pour qu'il devienne **BetterHello**.

Voilà ce que nous allons lui faire :
- Enregistrer l'adresse de celui qui demande à changer de nom
- Rendre le changement de nom payant, 1 XTZ à chaque fois
- Permettre à son propriétaire de récupérer tous ces XTZ
- Répercuter le changement de nom dans **SimpleHello** précédemment déployé
- Maintenir un historique des changements

## Point de départ

Voici donc notre point de départ, le code de **SimpleHello** (dont nous avons supprimé *getHello* qui ne servait à rien).

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

Nous lui avons ajouté un paramètre `contractStorage` de type `storage` défini précédemment. Il contiendra l'état du **storage** du contrat, que nous allons devoir modifier et retourner en intégralité.

Analysons le corps de la fonction. Il contient une seule expression, écrite sur plusieurs lignes pour la lisibilité, mais qui peut également être écrite en une seule ligne.

La modification d'un **record** se fait en générant un nouveau record et en précisant uniquement quel champs sont modifiés. Chacune de ces instructions étant séparées par une virgule. Le tout forme une expression qui retourne une copie du **record** d'entrée avec les valeurs modifiées.

` ...contractStorage, ` est le "spread operator" qui crée la copie du **record** et expose tous les champs disponibles.

`hello: "Hello "  ++ newName,    update_user: Tezos.sender,    update_date: Tezos.now` vient mettre à jour les champs avec les nouvelles valeurs.

Remarquons l'utilisation de `Tezos.sender` qui contient l'adresse qui a invoqué le contrat et `Tezos.now` qui contient le timestamp du bloc courant.

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

## Récupérer les XTZ

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