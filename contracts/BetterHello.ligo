// Définition de type "variant"
type entryPoint =
| UpdateName(string)
| ResetName
| SayHello;

// Définition d'un type "storage" pour un storage plus complet
type storage = {
    name : string,
    result : string
};

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

// Remet le nom à nobody s'il ne l'est pas déjà, tombe en erreur sinon
let reset = ( (contractStorage): (string) ): string => {

    let length : nat = String.length(contractStorage);
    let helloLength : nat = String.length("Hello ");
    let nameStart : nat = helloLength;
    let nameLength : int = length-helloLength;
    let nameLengthNat : nat = abs(nameLength);
    let currentName : string = String.sub (nameStart, nameLengthNat, contractStorage);

    if (currentName != "nobody") {
        let result : string = "Hello nobody";
        result;
    }
    else {
        ( failwith("Already nobody"): string );
    }
}

let main = ((action, contractStorage): (entryPoint, string)) => {
    let newStorage =
    switch (action) {
    | UpdateName(newName) => changeName(newName)
    | ResetName => reset(contractStorage)
    | SayHello => hello(contractStorage)
  };
(([] : list (operation)), newStorage);
};