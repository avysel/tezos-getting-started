# Tezos getting started

## Présentation

Tezos est une blockchain qui a été présentée en 2014 et mise en oeuvre en 2017. Elle est le support de la cryptomonnaie du même nom dont les tokens sont appelés **Tez** (**XTZ** ou **ꜩ**) 

**Tezos est une blockchain à preuve d'enjeu**

Pour réaliser son consensus, Tezos implémente la preuve d'enjeu. C'est-à-dire que les membres du réseau vont verrouiller une partie de leurs tokens, qu'il ne pourront plus utiliser par ailleurs, pour obtenir le droit de créer un bloc. Le créateur du prochain bloc, appelé le _baker_, sera choisi aléatoirement parmi tous les candidats. Au plus il aura verrouillé de XTZ, au plus il aura de chance d'être sélectionné. A tout moment, un _baker_ peut récupérer les tokens qu'il a verrouillé et se retirer du processus de _baking_.

Plus précisément, le mécanisme mis en oeuvre est celui de la **preuve d'enjeu déléguée**. La quantité de XTZ à verrouiller pour devenir _baker_ est très importante (8000 XTZ minimum) et n'est pas à la portée de tout le monde. Il est donc possible pour les plus petits porteurs de déléguer leurs XTZ à un _baker_ afin de le renforcer (Il ne s'agit pas de "donner" ses XTZ à un baker, mais de verrouiller ses XTZ au profit d'un baker. On peut déverrouiller sa délégation à tout moment pour les utiliser ou les déléguer à un autre baker). En échange, celui-ci va redistribuer à ses délégateurs une partie de ses gains issus du _baking_, proportionnellement à leur participation.

**Tezos est une blockchain de troisième génération**

La première génération de blockchain est Bitcoin et les blockchains similaires, qui se contentent de gérer principalement des transactions de transfert de tokens, avec éventuellement des possibilités de scriptage assez simples.

La deuxième génération est représentée par Ethereum et ses semblables. Elle se démarque de la première par l'ajout des smart contracts et la possibilité de réaliser des applications complètes, entièrement décentralisées.

La troisième génération, dont Tezos fait partie, apporte une gouvernance _on-chain_. C'est-à-dire que le mécanisme d'évolution de ses paramètres est intégré à son fonctionnement. Pour faire évoluer certaines choses, une nouvelle version du protocole sera publiée sur un réseau de test. Les membres (les possesseurs de tokens) vont voter pour ou contre. En cas d'acceptation, l'évolution sera automatiquement appliquée sur le mainnet. On évite ainsi le douloureux mécanisme de hard fork des générations précédentes.

**But alors you are french ?**

Proposée par Arthur et Kathleen Breitman, Tezos est issue de la recherche française. Elle est écrite en OCaml. Ses équipes travaillent en étroite collaboration avec les créateurs de ce langage.

Tezos a été certifiée par [l'ANSSI](https://www.ssi.gouv.fr/) pour son respect du protocole [eIDAS](https://www.ssi.gouv.fr/entreprise/reglementation/confiance-numerique/le-reglement-eidas/). Elle peut être utilisée dans des projets sensibles concernant les intérêts français.

Le langage d'écriture des smart contracts est le Michelson. C'est un langage à pile d'exécution, Turing complet, qui permet une vérification formelle des smart contracts à la compilation. Cela évite de nombreuses erreurs lors de l'exécution qu'on retrouve souvent dans les smart contracts des blockchains de deuxième génération.

**Dune Network ?**

En explorant l'écosystème Tezos, on trouve régulièrement mention du projet Dune Network. Il s'agit d'un projet concurrent émanant d'une scission de la communauté Tezos. L'équipe de OCamlPro aurait souhaité prendre ses distance avec l'équipe de Tezos, suite à des divergences d'ordre financier, et aurait forké le protocole pour en faire sa propre blockchain, avec une vision un peu différente de la gouvernance _on-chain_.

Ses ambitions et façons de faire semblent plutôt opaques à l'heure actuelle.


## Fonctionnement

Tezos fonctionne en **cycles**. Un cycle est une unité de temps équivalent au temps nécessaire à la création de 4096 blocs. Avec un rythme d'environ 1 bloc par minute, 1 cycle dure donc environ 2 jours, 20 heures et 15 minutes.

### Transactions

liste des transactions ? (transfert, delegating, baking candidate ...)

### Processus de baking

Tezos élit des **bakers**, aléatoirement, parmi la liste de tous les noeuds qui se sont déclarés comme baker, proportionnellement au montant de XTZ verrouillés. Le baker ainsi sélectionné va pouvoir créer le prochain bloc à ajouter à la chaine et le communiquer au réseau. Il va recevoir un certain nombre de XTZ en récompense.
Plusieurs bakers sont élu pour créer un bloc, avec une liste de priorités. Le plus prioritaire va essayer de créer un bloc. S'il n'y parvient pas dans le délai imparti, la main passera au suivant. Un bloc généré par le baker n'ayant pas la priorité sera tout simplement invalide et refusé par le réseau.

Tezos repose aussi sur les **endorser**, des bakers qui vont pouvoir "tamponner" le bloc nouvellement créé pour le soutenir, moyennent, là aussi, récompense. Ensuite, chaque autre membre du réseau va devoir valider le bloc sur sa propre version de la chaine.

Les bakers et les endorser sont choisi au début de chaque cycle, pour tous les blocs du cycle.

Pour créer en bloc ou le soutenir, un baker va devoir geler une partie de ses avoirs, qui ne seront disponibles que 5 cycles plus tard.

On trouve aussi les **accuser**. Ces membres du réseau surveillent qu'un baker ne crée pas deux blocs concurrents en même temps ou ne soutienne pas deux fois un bloc. Dans le cas où une accusation est correcte, l'_accuser_ qui l'a émise récupère une partie des fonds qui ont été gelés par le baker ou l'_endorser_. L'autre partie est brûlée.

### Processus d'évolution

doc : https://blog.octo.com/tezos-une-blockchain-auto-evolutive-partie-1-3/

L'évolution du processus se fait en 4 étapes qui durent 8 cycles chacune. 

Premièrement, le **proposal**, pendant laquelle les évolutions seront soumises à la communauté.

Ensuite, l'**exploration vote**,

Puis le **testing**,

Et enfin, le **promote vote**,

## Architecture

- **tezos-node** : c'est le coeur de la blockchain, il gère le protocole.
- **tezos-client** : il permet d'interagit avec tezos-node.
- **tezos-baker** : le baker, il permet de participer au consensus en créant de nouveaux blocs.
- **tezos-endorser** : l'endorser, il permet de participer au consensus en validant les blocs créés par d'autres bakers.
- **tezos-accuser** : l'accusateur

Le baker et l'endorser ne sont pas obligatoire si on cherche simplement à faire tourner un noeud pour accéder aux données de la blockchain ou envoyer des transactions.

## Installation

### Via apt

Sur Ubuntu, il est facile d'installer Tezos via le gestionnaire paquets :
```
sudo add-apt-repository ppa:serokell/tezos && sudo apt-get update
sudo apt-get install tezos-client
sudo apt-get install tezos-node
```

### Depuis les sources


## Création de l'identité et des comptes

Afin de pouvoir faire partie sur réseau Tezos, il faut que notre noeud puisse être identifié. Il faut générer une identité :

```
tezos-node identity generate
```

Un fichier ```identity.json``` sera généré dans le répertoire ```~/.tezos-node```. Il contiendra nos clés publiques et privées. A conserver soigneusement et en sécurité !


## Lancement du noeud

Pour lancer le noeud Tezos local, on utilise la commande suivante :

```
tezos-node run --rpc-addr 127.0.0.1:8732
```

On précise le paramètre ```--rpc-addr url:port``` pour activer l'interface RPC qui permettra de communiquer avec le noeud.
Par défaut, elle se lance sur le port 8732, il n'est donc pas obligatoire de le préciser.

Lors du premier lancement, il sera nécessaire d'attendre un long moment (plusieurs heures voire plusieurs jours) pour qu'il se synchronise avec le réseau et récupère tout l'historique du réseau auquel il est connecté.


## Connexion au noeud via RPC

Il est maintenant possible de se connecter au noeud et de l'interroger via RPC. Par exemple, pour connaitre la version du protocole qui est exécutée, on peut interroger l'URL suivante en GET via cURL, Postman ... : 

```
curl 127.0.0.1:8732/network/version
```

On peut aussi utiliser le client Tezos
```
tezos-client rpc get /network/version
```

## Wallet et comptes

Pour passer à la phase suivante, celle de l'utilisation du wallet et des comptes, il faut que notre noeud se soit synchronisé avec le réseau.
Pour le vérifier :

```
tezos-client get timestamp
```
Si cette commande affiche une date et une heure dans le passé, c'est que le noeud n'est pas synchronisé, il faut donc attendre encore un peu.

Une fois synchronisé, nous pouvons créer des comptes, le ```tezos-client``` jouant également le rôle de wallet. Commençons par 2 comptes :

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

[Taquito](https://tezostaquito.io/docs/quick_start) est un framework écrit en Typescript qui permet de communiquer avec un noeud Tezos. Si vous êtes familier d'Ethereum, il est l'équivalent de Web3.js.


---------------


# Les smart contracts sur Tezos

Les smart contracts sur Tezos sont écrits en Michelson. Ce langage à pile d'exécution est assez compliqué à utiliser. Plusieurs langages ont été créés, plus faciles d'utilisation et destinés à être compilés en Michelson, afin de faciliter le développement des smart contracts.

- [Ligo](https://ligolang.org/) : il propose 3 syntaxes différentes, ReasonLIGO, PascalLIGO et CamlLIGO, inspirées respectivement de [ReasonML](https://reasonml.github.io/), Pascal et Caml.
- [Liquidity](https://www.liquidity-lang.org/) : dévelopé par [OCamlPro](https://www.ocamlpro.com/), il s'inspire de la syntaxe de [OCaml](http://ocaml.org/) et de [ReasonML](https://reasonml.github.io/), 
- [SmartPy](https://smartpy.io/) : bilbiothèque Python pour le développement de smart contracts Tezos en Python.

Les exemples que nous allons utiliser seront en Ligo avec la syntaxe ReasonML qui est assez proche du javacript.

## Premier smart contract, SimpleStorage

## Compilation

## Déploiement

## Test du smart contract 

### Avec tezos-client

### Avec Taquito

## Docs

https://medium.com/chain-accelerator/i-tested-tezos-b254504775be

https://medium.com/chain-accelerator/how-to-use-tezos-rpcs-16c362f45d64

https://training.nomadic-labs.com/download/interact_with_the_blockchain.pdf

https://hackernoon.com/how-to-build-a-tezos-dapp-using-taquito-and-the-beacon-sdk-0n183ymn (obsolète)

Tezos RPC guide https://tezos.gitlab.io/007/rpc.html

Taquito https://tezostaquito.io/docs/quick_start

Liquidity compiler https://www.liquidity-lang.org/edit/

Ligo https://ligolang.org/docs/next/language-basics/types