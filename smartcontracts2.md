# Smart contracts, 2ème partie

Nous allons reprendre notre contrat **SimpleHello** de l'étape précédente nous allons l'améliorer pour qu'il devienne **BetterHello**.

Voilà ce que nous allons lui faire :
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