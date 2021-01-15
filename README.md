# tezos-getting-started

## Présentation

Tezos a été présentée en 2014 et mise en oeuvre en 2017. Elle est le support de la cryptomonnaie du même nom dont les tokens sont appelés **Tez** (symbole **XTZ** ou **ꜩ**) 

**Tezos est une blockchain à preuve d'enjeu**

Pour réaliser son consensus, Tezos implémente la preuve d'enjeu. C'est à dire que les membres du réseau vont verrouiller une partie de leurs tokens pour obtenir le droit de créer un bloc. Le créateur du prochain block, appeler le _baker_, sera choisi aléatoirement parmi tous les candidats. Au plus il aura verrouillé de XTZ, au plus il aura de chance d'être sélectionné.

Plus précisément, le mécanisme mis en oeuvre est celui de la **preuve d'enjeu déléguée**. La quantité de XTZ à verrouiller pour devenir _baker_ est très importante (8000 XTZ minimum) et n'est pas à la portée de tout le monde. Il est donc possible pour les plus petits porteurs de déléguer leurs XTZ à un _baker_ afin de le renforcer. En échange, celui-ci va redistribuer à ses délégateurs une partie de ses gains issus du _baking_, proportionnellement à leur participation.

**Tezos est une blockchain de troisième génération**

La première génération étant Bitcoin et les blockchains similaires, qui se contentent de gérer principalement des transactions de transfert de tokens, avec éventuellement des possibilités de scriptage assez simples.

La deuxième génération est représentée par Ethereum et ses semblables. Elle se démarque de la première par l'ajout des smart contracts et la possibilité de réaliser des applications complètes, entièrement décentralisées.

La troisième génération, dont Tezos fait partie, apporte une gouvernance _on-chain_. C'est-à-dire que le mécanisme d'évolution de ses paramètres est intégré à son fonctionnement. Pour faire évoluer certaines choses, une nouvelle version du protocole sera publiée sur un réseau de test. Les membres vont voter pour ou contre. En cas d'acceptation, l'évolution sera automatiquement appliquée sur le mainnet. On évite ainsi le douloureux mécanisme de hard fork des générations précédentes.

**But alors you are french ?**

Proposée par Arthur et Kathleen Breitman, Tezos est issue de la recherche française. Elle est écrite en OCaml. Ses équipes travaillent en étroite collaboration avec les créateurs de ce langage.

Tezos a été certifiée par l'ANSSI pour être utilisée dans des projets sensibles concernant les intérêts français.

Le langage d'écriture des smart contracts est le Michelson. C'est un langage à pile d'exécution, Turing complet qui permet une validation fonctionnelle lors de la compilation, qui détecte les erreurs en avance de phase. Cela évite de nombreuses erreurs lors de l'exécution qu'on retrouve souvent dans les smart contracts des blockchains de deuxième génération.


## Installation

Sur Ubuntu, il est facile d'installer Tezos via le gestionnaire paquets :
```
sudo add-apt-repository ppa:serokell/tezos && sudo apt-get update
sudo apt-get install tezos-client
sudo apt-get install tezos-node
```

## Création de l'identité et des comptes

Afin de pouvoir faire partie sur réseau Tezos, il faut que notre noeud puisse être identifié. Il faut générer une identité :

```
tezos-node identity generate
```

Un fichier ```identity.json``` sera généré dans le répertoire ```~/.tezos-node```. Il contiendra nos clés publiques et privées. A conserver soigneusement et en sécurité !


## Lancement du noeud

Pour lancer le noeud Tezos local, on utilise la commande suivante :

```tezos-node run --rpc-addr 127.0.0.1:8732```

On précise le paramètre ```--rpc-addr url:port``` pour activer l'interface RPC qui permettra de communiquer avec le noeud.
Par défaut, elle se lance sur le port 8732, il n'est donc pas obligatoire de le préciser.

Lors du premier lancement, il sera nécessaire d'attendre un long moment (plusieurs heures voire plusieurs jours) pour qu'il se synchronise avec le réseau et récupère tout l'historique du réseau auquel il est connecté.


## Connexion au noeud via RPC

Il est maintenant possible de se connecter au noeud et de l'interroger via RPC. Par exemple, pour connaitre la version exécutée :
On peut interroger l'URL suivante en GET via cURL, Postman ...

```127.0.0.1:8732/network/version```

On peut aussi utiliser le client Tezos
```tezos-client rpc get /network/version```

## Wallet et comptes

Pour passer à la phase suivante, celle de l'utilisation du wallet et des comptes, il faut que notre noeud se soit synchronisé avec le réseau.
Pour le vérifier :

```
tezos-client get timestamp
```
Si cette commande affiche une date et une heure dans le passé, c'est que le noeud n'est pas synchronisé, il faut donc attendre encore un peu.

Un fois synchronisé, nous pouvons créer des comptes, le ```tezos-client``` jouant également le rôle de wallet. Commençons par 2 comptes :

```
tezos-client gen keys alex
tezos-client gen keys bob
```
Ces commandes vont créer deux alias de comptes, alex et bob. 

Vérifions que les comptes ont bien été créés :

```
tezos-client list known contracts
> alex: tz1.....
> bob: tz1......
```

Les deux alias doivent s'afficher, ainsi que leurs adresses.

Comme nous sommes sur le testnet, nous pouvons les alimenter avec des XTZ obtenus via le faucet : https://faucet.tzalpha.net/

Générons deux fichiers d'identités et enregistrons les sous les noms ```alex.json``` et ```bob.json```.

Initialisons les comptes créés avec les données du faucet :

```
tezos-client activate account alex with "alex.json"
tezos-client activate account bob with "bob.json"
```

Vérifions les balances :
```
tezos-client get balance for alex
> 654.65 ꜩ
tezos-client get balance for bob
> 23432.76 ꜩ
```
Et voilà, nous sommes riches !

Nous allons tester un premier transfert de 1ꜩ de alex vers bob :
```
tezos-client transfer 1 from alice to bob --dry-run
```

L'option ```--dry-run``` permet de simuler la transaction sans l'envoyer sur le réseau, pour la tester.

Vérifions les balances à nouveau :
```
tezos-client get balance for alex
> 653.65 ꜩ
tezos-client get balance for bob
> 23433.76 ꜩ
```
Le ꜩ a bien été transféré.

## Utilisation du framework Taquito

Taquito est un framework écrit en Typescript qui permet de communiquer avec un noeud Tezos. Si vous êtes familier d'Ethereum, il est l'équivalent de Web3.js.

## Premier smart contract

Les smart contracts sur Tezos sont écrits en Michelson. Ce langage est assez compliqué à utiliser. Le Langage Ligo a été créé pour faciliter leur écriture. Il est transpilé en Michelson par la suite afin d'être injecté sur la blockchain.

## Docs

https://medium.com/chain-accelerator/i-tested-tezos-b254504775be

https://medium.com/chain-accelerator/how-to-use-tezos-rpcs-16c362f45d64

https://training.nomadic-labs.com/download/interact_with_the_blockchain.pdf

https://hackernoon.com/how-to-build-a-tezos-dapp-using-taquito-and-the-beacon-sdk-0n183ymn (obsolète)

Tezos RPC guide https://tezos.gitlab.io/007/rpc.html

Taquito https://tezostaquito.io/docs/quick_start

Liquidity compiler https://www.liquidity-lang.org/edit/

Ligo https://ligolang.org/docs/next/language-basics/types