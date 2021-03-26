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