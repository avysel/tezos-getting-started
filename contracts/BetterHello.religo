type pseudoEntryPoint =
| UpdateName(string);

type storage = {
  hello         : string,
  update_user       : address,
  update_date   : timestamp
};

let changeName = ( ( newName, contractStorage): ( string, storage) ): storage => {

    if (Tezos.amount >= (0.5tz + 500_000mutez)) {
        { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now }
    }
    else {
      (failwith("Must pay 1 tez to change name"): storage);
    }
};

let main = ((action, contractStorage): (pseudoEntryPoint, storage)) => {
    let newStorage = switch (action) {
    | UpdateName(newName) => changeName(newName, contractStorage)
  };
  (([] : list (operation)), newStorage);
};

/*

(record [hello="nobody"; update_user=unit;update_date=0])

'{hello:"nobody",update_user:("tz1KqTpEZ7Yob7QbPE4Hy4Wo8fHG8LhKxZSx" : address), update_date:("2000-01-01t10:10:10Z" : timestamp)}'

*/

/*
    if (Tezos.amount < 1tez) {
        let result : string = "Hello "  ++ newName;
        result;
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }*/