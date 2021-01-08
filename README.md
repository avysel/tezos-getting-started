# tezos-getting-started
Getting started with Tezos (installation, first smart contract)


Typescript framework : Taquito https://tezostaquito.io/docs/quick_start

(Typescript https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html)

https://medium.com/chain-accelerator/i-tested-tezos-b254504775be
https://medium.com/chain-accelerator/how-to-use-tezos-rpcs-16c362f45d64

## Présentation

Tezos a été présentée en 2014 et mise en oeuvre en 2017. Elle est le support de la cryptomonnaie du même nom dont les tokens sont appelés **Tez** (symbole **XTZ** ou **ꜩ**) 

**Tezos est une blockchain à preuve d'enjeu**

Pour réaliser son concensus, Tezos implémente la preuve d'enjeu. C'est à dire que les membre du réseau vont verrouiller une partie de leurs tokens pour obtenir le droit de créer un bloc. Le créateur du prochain block, appeler le _baker_, sera choisi aléatoirement parmi tous les candidats. Au plus il aura verrouillé de XTZ, au plus il aura de chance d'être sélectionné.

Plus précisément, le mécanisme mis en oeuvre est celui de la **preuve d'enjeu déléguée**. La quantité de XTZ à verrouiller pour devenir _baker_ est très importante (8000 XTZ minimum) et n'est pas à la portée de tout le monde. Il est donc possible pour les plus petits porteurs de déléguer leurs XTZ à un _baker_ afin de le renforcer. En échange, celui-ci va redistribuer à ses délégateurs une partie de ses gains issus du _baking_, proportionnellement à leur participation.

**Tezos est une blockchain de troisième génération**

La première génération étant Bitcoin et les blockchains similaires, qui se contentent de gérer principalement des transactions de transfert de tokens, avec éventuellement des possibilités de scritage assez simples.

Le deuxième génération est représentée par Ethereum et ses semblables. Elle se démarque de la première par l'ajout des smart contracts et la possibilité de réaliser des applications complètes, entièrement décentralisées.

La troisième génération, dont Tezos fait partie, ajoute une gouvernance _on-chain_. C'est à dire que le mécanisme d'évolution de ses paramètres est intégré à son fonctionnement. Pour faire évoluer certaines choses, il est ainsi possible de publier sur le réseau une proposition d'évolution. Les membres vont voter pour ou contre. En cas d'acceptation, l'évolution sera automatiquement appliquée. On évite ainsi le douloureux mécanisme de hard fork des générations précédentes.

**Tezos est une blockchain issue de la recherche française**

Proposée par Arthur et Kathleen Breitman, Tezos est issue de la recherche française. Elle est écrite en OCaml. Ses équipes travaillent en étroite collaboration avec les créateurs de ce langage.

Le langage d'écriture des smart contracts est le Michelson. C'est un langage à pile d'exécution, Turing complet qui permet une validation fonctionnelle lors de la compilation, qui détecte les erreurs en avance de phase. Cela évite de nombreuses erreurs lors de l'exécution qu'on retrouve souvent dans les smart contracts des blockchains de deuxième génération.

Tezos a été certifiée par l'ANSSI pour être utilisée dans des projets sensibles concernant les intérêts français. 

## Installation

## Création de l'identité et des comptes

Afin de pouvoir faire partie su réseau Tezos, il faut que notre noeud puisse être identifié. Il faut générer une identité :

```tezos-node identity generate```

Un fichier ```identity.json``` sera généré dans le répertoire ```~/.tezos-node```. Il contiendra nos clés publiques et privées. A conserver soigneusement et en sécurité !

Nous pouvons aussi créer des comptes personnels.

## Lancement du noeud

Pour lancer le noeud Tezos local, on utilise la commande suivante :

```tezos-node run --rpc-addr 127.0.0.1```

On précise le paramètre ```--rpc-addr url:port``` pour activer l'interface RPC qui permettra de communiquer avec le noeud.
Par défaut, elle se lance sur le port 8732. Mais il est possible de préciser un autre port, par exemple le 9999 :

Lors du premier lancement, il sera nécessaire d'attendre un long moment (plusieurs heures voire plusieurs jours) pour qu'il se synchronise avec le réseau et récupère tout l'historique du réseau auquel il est connecté.


## Connexion au noeud via RPC

Il est maintenant possible de se connecter au noeud et de l'interroger via RPC. Par exemple, pour connaitre la version exécutée :
On peut interroger l'URL suivante en GET via cURL, Postman ...

```127.0.0.1:8732/network/version```

On peut aussi utiliser le client Tezos
```tezos-client rpc get /network/version```

## Utilisation du framework Taquito

Taquito est un framework écrit en Typescript qui permet de communiquer avec un noeud Tezos. Si vous êtes familier d'Ethereum, il est l'équivalent de Web3.js.

## Premier smart contract