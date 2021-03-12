// Définition de type "variant"
type pseudoEntryPoint =
| UpdateName(string)
| ResetName
| DoNothing;

let reset = ( (contractStorage): (string) ): string => {

    // Reset hello with nobody
    let result : string = "Hello nobody";

    // return reset hello sentence
    result;
}

// Met à jour le nom stocké
let changeName = ( ( newName): ( string) ): string => {
    // Concatenate "hello" and the name into a string
    let result : string = "Hello "  ++ newName;

    // Return result
    result;
};

// Ne fait rien, prend en entrée le storage et le retourne sans rien modifier
let nothing = ( (contractStorage): (string) ): string => {
    contractStorage;
}

let main = ((action, contractStorage): (pseudoEntryPoint, string)) => {
    let newStorage =
    switch (action) {
    | UpdateName(newName) => changeName(newName)
    | ResetName => reset(contractStorage)
    | DoNothing => nothing(contractStorage)
  };
(([] : list (operation)), newStorage);
};