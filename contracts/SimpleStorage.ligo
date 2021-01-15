// https://medium.com/coinmonks/getting-started-with-ligo-13ea2c4e844e

// Définition de type
type storage = int;

// Définition de type "variant"
type action =
| Increment(int)
| Decrement(int);

// Définition des fonctions
// let functionName = ( (param1, param2): (param1Type, param2Type) ): returnType => functionBody

let add = ((storage, count): (int, int)): int => storage + count;
let sub = ((storage, count): (int, int)): int => storage - count;

// Définition du point d'entrée du smart contract
let main = ((p,s): (action, storage)) => {
    let storage =
        switch (p) {
            | Increment(n) => add((s, n))
            | Decrement(n) => sub((s, n))
        };
    ([]: list(operation), storage);
};