import { TezosToolkit } from '@taquito/taquito';
import { InMemorySigner, importKey } from '@taquito/signer';

// L'adresse du smart contract
const contractAddress = "KT1NzAQFhs8PmnHaUK4cdFtvnXdezKvTExBz";

// Connexion au noeud local.
const Tezos = new TezosToolkit('http://127.0.0.1:8732');

// Import de la clé privée pour signer la transaction
Tezos.setProvider({ signer: new InMemorySigner('edsk4PDm82iwUPMpsaKCRribzkgRhZCZ7T8CsKBcY25eS2c8tsJeZM') });

// Tout est Promise, nous devons être async
(async () => {

    // Chargement du smart contract
    let contract = await Tezos.contract.at(contractAddress);

    // lecture du storage courant
    console.log(`Read current storage: `+await contract.storage());

    console.log(`Update with "Hello from Taquito":`);

    // Appel de la methode "updateName"
    contract.methods.updateName("from Taquito").send()
      .then((op) => {
        // la transaction est créée, elle attend d'être confirmée
        console.log(`Waiting for ${op.hash} to be confirmed...`);

        // Après 1 confirmation, nous la considérons comme validée. Nous renvoyons le hash.
        return op.confirmation(1).then(() => op.hash);
      })
      .then( async (hash) => {
            // Le hash de la transaction est obtenu, elle est validée, nous affichons le lien pour l'afficher dans tzstats
            console.log(`Operation injected: https://edo.tzstats.com/${hash}`);

            // Affichage du nouveau storage
            console.log(`Read new storage: `+await contract.storage());
        })
      .catch(console.error);

})().catch(console.error);


/*
let contract = tezos.contract.at(contractAddress).then( (contract) => {
    console.log(`Read current storage:`);
    contract.storage().then(console.log);
});
*/