type pseudoEntryPoint =
| UpdateName(string)
| Withdraw;

type storage = {
  hello         : string,
  update_user   : address,
  update_date   : timestamp
};

type return = ( list(operation), storage);

let ownerAddress : address = ("tz1XPw3CHUauRF1qmmBwB8BgJQRSGkoTU7BY" : address);
let simpleHelloAddress : address = ("KT1Qgeo4RBWq9HzXaQDa7su8Kz9jCD3zCyhv" : address);

let changeName = ( ( newName, contractStorage): ( string, storage) ): return => {

    if (Tezos.amount >= 1tez) {
        let newStorage = { ...contractStorage, hello: "Hello "  ++ newName, update_user: Tezos.sender, update_date: Tezos.now };

        let simpleHelloContract : contract(string) =
            switch( Tezos.get_entrypoint_opt("%UpdateName", simpleHelloAddress): option(contract(string)) ) {
              | Some(contract) => contract
              | None => (failwith ("SimpleHello not found") : (contract(string)))
            };

          let callOperation : operation = Tezos.transaction (newName, 0tez, simpleHelloContract) ;

         (([] : list (operation)), newStorage);
    }
    else {
      (failwith("Must pay 1 tez to change name"): return);
    }
};

let withdraw = ( (contractStorage): (storage) ): return => {

    if (Tezos.sender != ownerAddress) {
        ( failwith("Operation not allowed") : return);
    }
    else {
        let receiver : contract(unit) =
          switch ( Tezos.get_contract_opt (ownerAddress): option(contract(unit)) ) {
          | Some(contract) => contract
          | None => (failwith ("Not a contract") : (contract(unit)))
          };

        let withdrawOperation : operation = Tezos.transaction (unit, Tezos.balance, receiver) ;
        let operations : list (operation) = [withdrawOperation];
        (operations, contractStorage);
    }
}

let main = ((action, contractStorage): (pseudoEntryPoint, storage)) => {
    switch (action) {
    | UpdateName(newName) => changeName(newName, contractStorage)
    | Withdraw => withdraw(contractStorage)
  };
};