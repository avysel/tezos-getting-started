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