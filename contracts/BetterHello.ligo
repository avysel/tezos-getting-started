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