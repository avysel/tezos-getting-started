type pseudoEntryPoint =
| UpdateName(string);

type storage = {
  hello         : string,
  update_user       : address,
  update_date   : timestamp
};

type return = (list (operation), storage);

let changeName = ( ( newName, contractStorage): ( string, string) ): storage => {
    { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now }
};

let main = ((action, contractStorage): (pseudoEntryPoint, storage)) => {
    let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName, contractStorage)
  };
  (([] : list (operation)), newStorage);
};

/*

(record [hello="nobody"; update_user=unit;update_date=0])

'{hello:"nobody",update_user:unit, update_date:0}'

*/

/*
    if (Tezos.amount < 1tez) {
        let result : string = "Hello "  ++ newName;
        result;
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }*/