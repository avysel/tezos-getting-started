# Tezos getting started

## Présentation

Tezos est une blockchain qui a été présentée en 2014 et mise en oeuvre en 2017. Elle est le support de la cryptomonnaie du même nom dont les tokens sont appelés **Tez** (**XTZ** ou **ꜩ**) 

**Tezos est une blockchain à preuve d'enjeu**

Pour réaliser son consensus, Tezos implémente la preuve d'enjeu. C'est-à-dire que les membres du réseau vont verrouiller une partie de leurs tokens, qu'ils ne pourront plus utiliser par ailleurs, pour obtenir le droit de créer un bloc. Le créateur du prochain bloc, appelé le _baker_, sera choisi aléatoirement parmi tous les candidats. Au plus il aura verrouillé de XTZ, au plus il aura de chance d'être sélectionné. À tout moment, un _baker_ peut récupérer les tokens qu'il a verrouillés et se retirer du processus de _baking_.

Plus précisément, le mécanisme mis en oeuvre est celui de la **preuve d'enjeu déléguée**. La quantité de XTZ à verrouiller pour devenir _baker_ est très importante (8000 XTZ minimum, un *__roll__*) et n'est pas à la portée de tout le monde. Il est donc possible pour les plus petits porteurs de déléguer leurs XTZ à un _baker_ afin de le renforcer (Il ne s'agit pas de "donner" ses XTZ à un baker, mais de verrouiller ses XTZ au profit d'un baker. On peut retirer sa délégation, ou changer de baker délégué, à tout moment). En échange, celui-ci va redistribuer à ses délégateurs une partie de ses gains issus du _baking_, proportionnellement à leur participation.

**Tezos est une blockchain de troisième génération**

La première génération de blockchain est Bitcoin et les blockchains similaires, qui se contentent de gérer principalement des transactions de transfert de tokens, avec éventuellement des possibilités de scriptage assez simples.

La deuxième génération est représentée par Ethereum et ses semblables. Elle se démarque de la première par l'ajout des smart contracts et la possibilité de réaliser des applications complètes, entièrement décentralisées.

La troisième génération, dont Tezos fait partie, apporte une gouvernance _on-chain_. C'est-à-dire que le mécanisme d'évolution de ses paramètres est intégré à son fonctionnement. Pour faire évoluer certaines choses, une nouvelle version du protocole sera publiée sur un réseau de test. Les membres (les possesseurs de tokens) vont voter pour ou contre. En cas d'acceptation, l'évolution sera automatiquement appliquée sur le mainnet. On évite ainsi le douloureux mécanisme de hard fork des générations précédentes.

**But alors you are French ?**

Proposée par Arthur et Kathleen Breitman, Tezos est issue de la recherche française. Elle est écrite en OCaml. Ses équipes travaillent en étroite collaboration avec les créateurs de ce langage.

Pourquoi OCaml ? Tout simplement parce que c'est un langage fonctionnel, qui cherche la sécurité en se basant sur la validation formelle, une technique qui permet de valider mathématiquement un code avant son exécution. En gros, une fois validé et compilé, le code ne pourra pas planter à l'exécution.

Tezos a été certifiée par [l'ANSSI](https://www.ssi.gouv.fr/) pour son respect du protocole [eIDAS](https://www.ssi.gouv.fr/entreprise/reglementation/confiance-numerique/le-reglement-eidas/). Elle peut être utilisée dans des projets sensibles concernant les intérêts français.

Le langage d'écriture des smart contracts est le Michelson. C'est un langage à pile d'exécution, Turing complet, qui permet une vérification formelle des smart contracts à la compilation. Cela évite de nombreuses erreurs lors de l'exécution qu'on retrouve souvent dans les smart contracts des blockchains de deuxième génération.

**Dune Network ?**

En explorant l'écosystème Tezos, on trouve régulièrement mention du projet Dune Network. Il s'agit d'un projet concurrent émanant d'une scission de la communauté Tezos. L'équipe d’OCamlPro aurait souhaité prendre ses distance avec l'équipe de Tezos, suite à des divergences d'ordre financier, et aurait forké le protocole pour en faire sa propre blockchain, avec une vision un peu différente de la gouvernance _on-chain_.

Ses ambitions et façons de faire semblent plutôt opaques à l'heure actuelle.

## Fonctionnement

Tezos fonctionne en **cycles**. Un cycle est une unité temporelle équivalente à la durée nécessaire pour créer 4096 blocs. Avec un rythme d'environ 1 bloc par minute, 1 cycle dure donc environ 2 jours, 20 heures et 15 minutes.

### Processus de baking

Tezos élit des **bakers**, aléatoirement, parmi la liste de tous les nœuds qui se sont déclarés comme _délégué_, proportionnellement à la somme de XTZ verrouillés (un baker est un délégué, un utilisateur qui délègue ses XTZ est un délégateur. A noter qu'un baker n'a pas obligatoirement besoin de délégateurs pour fonctionner, il peut se la jouer solo, mais il a moins de chances d'être sélectionné pour le baking). Le baker ainsi sélectionné va pouvoir créer le prochain bloc à ajouter à la chaine et le communiquer au réseau. Il va recevoir un certain nombre de XTZ en récompense.
Plusieurs bakers sont élu pour créer un bloc, avec une liste de priorités. Le plus prioritaire va essayer de créer un bloc. S'il n'y parvient pas dans le délai imparti, la main passera au suivant. Un bloc généré par le baker n'ayant pas la priorité sera tout simplement invalide et refusé par le réseau.

Tezos repose aussi sur les **endorsers**, des bakers qui vont pouvoir "tamponner" le bloc nouvellement créé pour le soutenir, moyennent, là aussi, récompense. Ensuite, chaque autre membre du réseau va devoir valider le bloc sur sa propre version de la chaine.

Les _bakers_ et les _endorsers_ sont choisi au début de chaque cycle, pour tous les blocs du cycle.

Pour créer en bloc ou le soutenir, un _baker_ va devoir geler une partie de ses avoirs, qui ne seront disponibles que 5 cycles plus tard.

On trouve aussi les **accusers**. Ces membres du réseau surveillent qu'un baker ne crée pas deux blocs concurrents en même temps ou ne soutienne pas deux fois un bloc. Dans le cas où une accusation est correcte, l'_accuser_ qui l'a émise récupère une partie des fonds qui ont été gelés par le _baker_ ou l'_endorser_. L'autre partie est brûlée.

(Pour rappel, brûler une cryptomonnaie revient à en détruire une quantité donnée. C'est une action irreversible, qui ne doit pas être effectuée à la légère. Elle peut-être effectuée dans le cadre du protocole lui-même dans certain cas, ou par un utilisateur, volontairement ou par erreur, en envoyant des fonds à une adresse n'appartenant à personne.)

### Processus d'évolution

doc : https://blog.octo.com/tezos-une-blockchain-auto-evolutive-partie-1-3/

L'évolution du processus se fait en 4 étapes qui durent 8 cycles chacune. 

Premièrement, le **proposal**, pendant laquelle les évolutions seront soumises à la communauté.

Ensuite, l'**exploration vote**,

Puis le **testing**,

Et enfin, le **promote vote**,

## Architecture

- **tezos-node** : c'est le cœur de la blockchain, il gère le protocole.
- **tezos-client** : il permet d'interagir avec ```tezos-node```.
- **tezos-admin-client** : un outil d'administration pour le ```tezos-node```
- **tezos-baker** : le baker, il permet de participer au consensus en créant de nouveaux blocs.
- **tezos-endorser** : l'endorser, il permet de participer au consensus en validant les blocs créés par d'autres bakers.
- **tezos-accuser** : l'accusateur

Le baker et l'endorser ne sont pas obligatoire si on cherche simplement à faire tourner un nœud pour accéder aux données de la blockchain ou envoyer des transactions.

## Installation

### Via apt

Sur Ubuntu, il est facile d'installer Tezos via le gestionnaire de paquets :
```
sudo add-apt-repository ppa:serokell/tezos && sudo apt-get update
sudo apt-get install tezos-client
sudo apt-get install tezos-node
sudo apt-get install tezos-baker-007-psdelph1
```
À noter que seuls ```tezos-node```, ```tezos-client ``` et le ```tezos-baker``` du testnet actuel sont disponibles via cette façon de faire.
Pour avoir l'intégralité des exécutables (accuser, endorser), il faut installer à partir des sources.

### Depuis les sources

## Connexion au bon réseau

Un répertoire ```.tezos-node``` est créé à la racine du compte qui a servi à l'installation.
On y trouve un fichier ```config.json```.

Modifions-le pour préciser sur quel nœud se connecter, avec le champ ```network``` :

```
{
  "p2p": {
    "bootstrap-peers": [
      ...
    ]
  },
  "network": "delphinet"
}
```

[Vérifiez bien quel est le testnet du moment](https://tezos.gitlab.io/introduction/test_networks.html). Si vous utilisez un testnet abandonné car l'évolution qu'il contient a déjà été intégrée au mainnet, vous risquez d'être le seul nœud connecté, vous ne pourrez pas faire grand-chose.
Ici, nous nous connectons sur Delphinet.

Dorénavant, en étant connecté sur un testnet, le résultat de toutes nos commandes via ```tezos-client``` seront précédés d'un avertissement indiquant que nous ne sommes pas sur le mainnet.

## Création de l'identité et des comptes

Afin de pouvoir faire partie sur réseau Tezos, il faut que notre nœud puisse être identifié. Il faut générer une identité :

```
tezos-node identity generate
```

Ca prendra un peu de temps pour générer les clés. Un fichier ```identity.json``` sera ensuite généré dans le répertoire ```~/.tezos-node```. Il contiendra nos clés publiques et privées. À conserver soigneusement et en sécurité !


## Lancement du nœud

Pour lancer le nœud Tezos local, on utilise la commande suivante :

```
tezos-node run --rpc-addr 127.0.0.1:8732 --data-dir ~/tezos-delphinet --network delphinet
```

On précise le paramètre ```--rpc-addr url:port``` pour activer l'interface RPC qui permettra de communiquer avec le nœud.
Par défaut, elle se lance sur le port 8732, il n'est donc pas obligatoire de le préciser.

Il est possible de définir le répertoire où seront stockées les données avec ```--data-dir``` (par défaut, dans ```.tezos-node```) et de préciser sur quel réseau se connecter avec ```--network``` (si nous ne l'avons pas précisé dans ```config.json```, et par défaut, ```mainnet```).

Lors du premier lancement, il sera nécessaire d'attendre un long moment (plusieurs heures voire plusieurs jours) pour qu'il se synchronise avec le réseau et récupère tout l'historique de ce qui a été fait avant notre arrivée.


## Connexion au nœud via RPC

Il est maintenant possible de se connecter au nœud et de l'interroger via RPC. Par exemple, pour connaitre la version du protocole qui est exécutée, on peut interroger l'URL suivante en GET via cURL, Postman ... : 

```
curl 127.0.0.1:8732/network/version
```

On peut aussi utiliser le client Tezos
```
tezos-client rpc get /network/version
```

## Wallet et comptes

Pour passer à la phase suivante, celle de l'utilisation du wallet et des comptes, il faut que notre nœud se soit synchronisé avec le réseau.
Pour le vérifier :

```
tezos-client get timestamp
```
Si cette commande affiche une date et une heure dans le passé, c'est que le nœud n'est pas synchronisé, il faut donc attendre encore un peu.

Une fois synchronisé, nous pouvons créer des comptes, le ```tezos-client``` joue également le rôle de wallet. Commençons par 2 comptes :

```
tezos-client gen keys alex
tezos-client gen keys bob
```
Ces commandes vont créer deux alias de comptes, Alex et Bob. 

Vérifions que les comptes ont bien été créés :

```
> tezos-client list known contracts
alex: tz1.....
bob: tz1......
```

Les deux alias doivent s'afficher, ainsi que leurs adresses.

Pour la suite, nous pourrons utiliser indifféremment les adresses tz1 ou leurs alias.


Comme nous sommes sur le testnet, nous pouvons les alimenter avec des ꜩ obtenus via le faucet : https://faucet.tzalpha.net/

Générons deux fichiers d'identités et enregistrons les sous les noms ```alex.json``` et ```bob.json```.

Initialisons les comptes créés avec les données du faucet :

```
tezos-client activate account alex with "alex.json"
tezos-client activate account bob with "bob.json"
```

Ces opérations en seront pas immédiates, il faudra attendre que la transaction soit inclue dans un bloc.

Vérifions les balances :
```
> tezos-client get balance for alex
6492.631450 ꜩ
> tezos-client get balance for bob
43540.194615 ꜩ
```
Et voilà, nous sommes riches ! Bob semble avoir eu plus de chance qu'Alex. Le faucet est aléatoire sur les sommes distribuées.

Nous allons tester un premier transfert de 1 ꜩ d'Alex vers Bob :
```
tezos-client transfer 1 from alex to bob --dry-run
```

L'option ```--dry-run``` permet de simuler la transaction sans l'envoyer sur le réseau, pour la tester. Nous obtenons alors la description de tout ce qui changera grâce cette transaction : les changements de balances, les frais, le gaz utilisé, les adresses impactées ...

Après vérification, nous allons lancer la transaction pour de bon cette fois, en enlevant le ```--dry-run``` : 
```
tezos-client transfer 1 from alex to bob
```
Là encore, il faut attendre un petit moment que la transaction soit prise en compte.

Vérifions les balances à nouveau :
```
> tezos-client get balance for alex
6491.631450 ꜩ
> tezos-client get balance for bob
43541.194615 ꜩ
```
Le ꜩ a bien été transféré.

## Création de compte sans faucet

Maintenant, nous allons créer un troisième compte :
```
tezos-client gen keys carl
```

Nous allons immédiatement lui transférer 1 ꜩ depuis Alex :
```
tezos-client transfer 1 from alex to carl
```

Nous obtenons une erreur :
``The operation will burn ꜩ0.06425 which is higher than the configured burn cap (ꜩ0).
Use `--burn-cap 0.06425` to emit this operation.``

Nos deux premiers comptes ont été initialisés grâce à un faucet qui les a, en quelque sorte, pré créés sur la blockchain. Notre troisième compte est quant à lui initialisé de façon tout à fait standard.
Quand une adresse est créée sur un client Tezos, elle n'est pas créée sur la blockchain tant qu'elle n'est pas utilisée dans une transaction. Lors de sa première transaction, elle sera diffusée sur le réseau. Afin de limiter le risque de création d'adresses en masse, cette opération requiert de brûler 0.06425 ꜩ. Nous devons donc indiquer que nous sommes prêt à brûler cette somme en ajoutant ```--burn-cap 0.06425``` à notre commande.


Elle devient donc :
```
tezos-client transfer 1 from alex to carl --burn-cap 0.06425
```
Comme d'habitude, une fois inclue dans la blockchain, nous obtenons le résumé de son exécution et nous pouvons y lire que 0.06425 ꜩ ont été brûlés depuis le compte d'Alex, en plus des frais de transaction et de la somme transférée.

Vérifions une dernière fois nos balances :

```
> tezos-client get balance for alex
6488.565316 ꜩ

> tezos-client get balance for bob
43543.194615 ꜩ

> tezos-client get balance for carl
1 ꜩ
```

## Ressources supplémentaires

Pour avoir la liste de toutes les commandes disponibles : ```tezos-client man```. Et il y en a un sacré paquet !

Elles sont aussi disponibles sur le [GitLab de Tezos](https://tezos.gitlab.io/alpha/cli-commands.html)

Nous pouvons inspecter nos transactions sur l'explorateur de blocks [Tezblock Delphinet](https://delphinet.tezblock.io/)

## Baking et délégation

### Le baker

Pour devenir baker, la première condition est de détenir 8000 ꜩ. Avec le faucet, il est facile de réunir cette somme sur le testnet. Sur le mainnet, pas le choix, il faut passer à la caisse.

Si je souhaite qu'Alex devienne baker, je vais lui transférer quelques milliers de ꜩ depuis le compte de Bob pour qu'il atteigne les 8000 ꜩ. Nous sommes maintenant experts dans cette manipulation :

```
tezos-client transfer 5000 from bob to alex
```

Puis pour vérifier :

``` 
> tezos-client get balance for alex
11488.564958 ꜩ
```
Et hop, une bonne chose de faite.

Ensuite, nous devons enregistrer le compte d'Alex en tant que _baker_ délégué :

``` 
tezos-client register key alex as delegate
```

Une fois enregistré, il faut un peu de patience. Notre _baker_ ne sera autorisé qu'après 7 cycles, soit un peu moins de 3 semaines.

...

3 semaines plus tard ...

...

Heureusement, nous sommes sur un testnet. Et sur les testnets, le nombre de blocs par cycles n'est que de 2048 au lieu de 4096 et qu'un bloc est créé toutes les 30 secondes au lieu de toutes les minutes. Ce qui donne des cycles d'environ 17 heures. 7 cycles ne vont durer que 5 jours.
...

Donc, 5 jours plus tard ...

...

Nous devons apparaître daans la [liste des _bakers_ de Delphinet](https://delphinet.tezblock.io/baker/list).

Nous avons installé le _baker_ précédemment. Il s'agit d'un exécutable qui va s'appuyer sur le nœud local pour créer des blocs, et il va le faire pour le compte d'un utilisateur.

Pour le lancer, pour le compte d'Alex :
```
tezos-baker-007-PsDELPH1 run with local node ~/.tezos-node alex
```

Tant que le message ```No slot found at level xxxxxx (max_priority = 64)``` s'affiche, c'est que notre baker n'a obtenu encore le droit de créer de bloc.

### Déléguer

Si nous ne pouvons pas ou ne voulons pas exploiter un _baker_, nous pouvons déléguer nos ꜩ à un _baker_ de notre choix.

Pour notre exemple, sur Delphinet, nous pouvons trouver la [liste des _bakers_](https://delphinet.tezblock.io/baker/list), comme vu précédemment.
Une liste des _bakers_ est disponible pour le mainnet sur [MyTezosBaker](https://mytezosbaker.com/).

Le choix d'un _baker_ à qui déléguer nos ꜩ se fait sur plusieurs critères. D'abord, la confiance que nous lui accordons pour se comporter convenablement sur le réseau, c'est-à-dire ne pas être hors service trop souvent, ne pas chercher à contourner les règles au risque d'être repéré par un _accuser_ ...

On peut aussi regarder le taux de rentabilité qu'il propose, de quel pays il vient, quelle organisation le soutient ... Bref, le choix n'est pas uniquement technique mais bien en ensemble de critères qui peuvent être propres à chacun.

Une fois notre _baker_ choisi, let's delegate !



Déléguer son compte à un baker se fait en deux étapes. D'abord, notre clé publique doit être révélée :
```
tezos-client reveal key for carl
```

Ensuite, la délégation : 

```
tezos-client set delegate for carl to <adresse tz1 du baker choisi>
```

Chaque étape coûte quelques ꜩ. La révélation peut être omise. Dans ce cas, elle sera effectuée automatiquement lors de la délégation.

Et voilà, nous avons délégué le compte de Carl à un _baker_. Il faudra attendre la fin du cycle pour que notre délégation soit prise en compte. Puis, à chaque cycle où notre baker sera sélectionné pour créer ou soutenir un block, nous recevrons une partie de la récompense. 

Les sommes perçues seront versées sur l'adresse que nous avons déléguée, elles viendront donc grossir notre délégation.

Et pour mettre fin à la délégation :

```
tezos-client withdraw delegate from carl
```

## Tezos + Node.js = Taquito

Nous allons réaliser un petit script Node.js pour se connecter à la blockchain.

Nous utiliserons [Taquito](https://tezostaquito.io/docs/quick_start), un framework écrit en Typescript qui permet de communiquer avec un nœud Tezos. Si vous êtes familier d'Ethereum, il est l'équivalent de Web3.js.

Installons-le : 

```
npm install @taquito/taquito
```

Nous allons pour le moment, faire un simple script qui va se connecter au nœud local et récupérer les balances de nos 3 comptes : 

```
import { TezosToolkit } from '@taquito/taquito';

const tezos = new TezosToolkit('http://127.0.0.1:8732');

tezos.tz
  .getBalance('tz1...')
  .then((balance) => console.log(`Alex : ${balance.toNumber() / 1000000} ꜩ`))
  .catch((error) => console.error(JSON.stringify(error)));

tezos.tz
    .getBalance('tz1...')
    .then((balance) => console.log(`Bob : ${balance.toNumber() / 1000000} ꜩ`))
    .catch((error) => console.error(JSON.stringify(error)));

tezos.tz
  .getBalance('tz1...')
  .then((balance) => console.log(`Carl : ${balance.toNumber() / 1000000} ꜩ`))
  .catch((error) => console.error(JSON.stringify(error)));
```

On compile et on exécute le fichier javascript généré ; et on obtient le même résultat qu'avec le tezos-client :

```
> tsc index.ts
> node index.js
Alex : 6488.565316 ꜩ
Bob : 43543.194615 ꜩ
Carl : 1 ꜩ
```

## Changer de testnet

Nous avons vu que les testnets de Tezos se succèdent en se remplaçant. Il faudra donc de temps en temps se connecter à nouveau réseau pour se préparer à un changement ou changer de testnet.

Nous allons devoir initialiser un autre nœud Tezos. Heureusement, il y a des commandes d'initialisation faciles à utiliser (que nous aurions aussi pu utiliser pour notre réseau initial).

Notre nœud actuel est connecté à Delphinet. Nous allons donc nous connecter au suivant, Edonet, pour être prêt le jour où ce dernier prendra la main sur Delphinet.

Créons un répertoire qui contiendra tous les éléments de notre nœud Edonet :
```
mkdir ~/tezos-edonet
```

On crée ensuite la configuration, qui initialise la connexion à Edonet et la liste des bootstrap peers :
```
tezos-node config init --data-dir ~/tezos-edonet --network edonet
```

Puis l'identité :
```
tezos-node identity generate --data-dir ~/tezos-edonet
```

Et finalement, nous pouvons le lancer, avec un port RPC différent que celui qui tourne déjà sur Delphinet :
```
tezos-node run --rpc-addr 127.0.0.1:8733 --data-dir ~/tezos-edonet
```

Le jour où Delphinet sera arrêté, nous pourrons supprimer le répertoire ```.tezos-node``` dans lequel nous avions laissé, par défaut, les données de notre nœud.

---------------


# Les smart contracts sur Tezos

Les smart contracts sur Tezos sont écrits en Michelson. Ce langage à pile d'exécution est assez compliqué à utiliser. Plusieurs langages ont été créés, plus faciles d'utilisation et destinés à être compilés en Michelson, afin de faciliter le développement des smart contracts.

- [Ligo](https://ligolang.org/) : il propose 3 syntaxes différentes, ReasonLIGO, PascalLIGO et CamlLIGO, inspirées respectivement de [ReasonML](https://reasonml.github.io/), Pascal et Caml.
- [Liquidity](https://www.liquidity-lang.org/) : développé par [OCamlPro](https://www.ocamlpro.com/), il s'inspire de la syntaxe de [OCaml](http://ocaml.org/) et de [ReasonML](https://reasonml.github.io/), 
- [SmartPy](https://smartpy.io/) : bibliothèque Python pour le développement de smart contracts Tezos en Python.

Les exemples que nous allons utiliser seront en Ligo avec la syntaxe ReasonML qui est assez proche du javascript.

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