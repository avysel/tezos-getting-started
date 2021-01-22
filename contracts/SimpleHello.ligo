// Définition de type
type storage = string;

// Définition de type "variant"
type action =
| UpdateName(string)
| SayHello();

let changeName = ( (storage, newName): (storage, string) ) => {
    storage = name;
};

let main = ( (a,s): (action, storage) ) => {


}
