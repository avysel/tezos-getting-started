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
    | UpdateName(newName) => changeName(newName)
    | SayHello => hello(contractStorage)
  };
(([] : list (operation)), newStorage);
};