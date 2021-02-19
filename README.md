# Démarrer avec Tezos

Partons à la découverte de Tezos, une blockchain de troisième génération. Nous allons découvrir son fonctionnement et comment rejoindre le réseau, l’utiliser et participer à son consensus.
## Présentation

[Tezos](https://tezos.com/) est une blockchain qui a été présentée en 2014 et mise en oeuvre en 2017. Elle est le support de la cryptomonnaie du même nom dont les tokens sont appelés **Tez** (**XTZ** ou **ꜩ**). Elle propose une plateforme de smart contracts et se positionne parmi les concurrents d’Ethereum.

**Tezos est une blockchain à preuve d'enjeu**

Pour réaliser son consensus, Tezos implémente la preuve d'enjeu. C'est-à-dire que les membres du réseau vont verrouiller une partie de leurs tokens, qu'ils ne pourront plus utiliser par ailleurs, pour obtenir le droit de créer un bloc. Le créateur du prochain bloc, appelé le _baker_, sera choisi aléatoirement parmi tous les candidats en fonction du nombre de tokens possédés.

Plus précisément, le mécanisme mis en oeuvre est celui de la **preuve d'enjeu liquide** (ou LPoS, Liquid Proof of Stake). La quantité de XTZ à posséder pour devenir baker est très importante (8000 XTZ minimum, un _roll_) et n'est pas à la portée de tout le monde. Il est donc possible pour les plus petits porteurs de déléguer leurs XTZ à un baker afin de le renforcer (Il ne s'agit pas de "donner" ses XTZ à un baker, mais de déposer ses XTZ au profit d'un baker. On peut retirer sa délégation, ou changer de baker délégué, à tout moment). En échange, celui-ci va redistribuer à ses délégateurs une partie de ses gains issus du baking, proportionnellement à leur participation.

La LPoS ne doit pas être confondue avec la DPoS, ou preuve d'enjeu déléguée (Delegated Proof of Stake), utilisée par Tron ou EOS par exemple : 

LPoS : nombre de bakers illimité (tout le monde peut participer), délégation optionnelle

DPoS : nombre de bakers fixe (création d'une sorte de "conseil d'administration"), délégation obligatoire

**Tezos est une blockchain de troisième génération**

La première génération de blockchain est Bitcoin et les blockchains similaires, qui se contentent de gérer principalement des transactions de transfert de tokens, avec éventuellement des possibilités de scriptage assez simples.

Ethereum et ses semblables représentent la deuxième génération. Elle se démarque de la première par l'ajout des smart contracts et la possibilité de réaliser des applications complètes, entièrement décentralisées.

La troisième génération, dont Tezos fait partie, apporte une gouvernance on-chain. C'est-à-dire qu'elle intègre nativement le mécanisme d'évolution du protocole. Pour apporter une modification, un réseau de test va permettre de tester une proposition d'évolution avant que le mainnet ne l'intègre automatiquement, si les membres du réseau votent pour. On évite ainsi le douloureux mécanisme de hard fork des générations précédentes.

**But alors you are French ?**

Proposée par Arthur et Kathleen Breitman, Tezos est issue de la recherche française. Elle est écrite en OCaml. Ses équipes travaillent en étroite collaboration avec les créateurs de ce langage.

Pourquoi OCaml ? Tout simplement parce que c'est un langage fonctionnel, qui cherche la sécurité en se basant sur la validation formelle, une technique qui permet de valider mathématiquement un code avant son exécution. En gros, une fois validé et compilé, le code ne pourra pas planter à l'exécution.

Tezos a été certifiée par [l'ANSSI](https://www.ssi.gouv.fr/) pour son respect du protocole [eIDAS](https://www.ssi.gouv.fr/entreprise/reglementation/confiance-numerique/le-reglement-eidas/). Elle peut être utilisée dans des projets sensibles concernant les intérêts français.

Le langage d'écriture des smart contracts est le Michelson. C'est un langage à pile d'exécution, Turing complet, qui permet une vérification formelle des smart contracts à la compilation. Cela évite de nombreuses erreurs lors de l'exécution qu'on retrouve souvent dans les smart contracts des blockchains de deuxième génération.

Pour le clin d'œil, Michelson est un scientifique qui a démontré au 19ème siècle, que l'ether (substance supposée permettre de véhiculer la lumière, dans les théories de l'époque) n'existait pas.

De nombreuses entreprises et organisations françaises sont impliquées dans le développement de Tezos et de son écosystème, telles que [Nomadic Labs](https://www.nomadic-labs.com/) et l'[INRIA](https://www.inria.fr/fr).

## Fonctionnement

Tezos fonctionne en **cycles**. Un cycle est une unité temporelle équivalente à la durée nécessaire pour créer 4096 blocs. Avec un rythme d'environ 1 bloc par minute, 1 cycle dure donc environ 2 jours, 20 heures et 15 minutes.

### Processus de baking

Tezos élit des **bakers**, aléatoirement, parmi la liste de tous les nœuds qui se sont déclarés comme _délégué_, proportionnellement à la somme de XTZ qu'il possède (un baker est un délégué, un utilisateur qui délègue ses XTZ est un délégateur. A noter qu'un baker n'a pas obligatoirement besoin de délégateurs pour fonctionner, il peut se la jouer solo, mais il a moins de chances d'être sélectionné pour le baking). Le baker ainsi sélectionné va pouvoir créer le prochain bloc à ajouter à la chaîne et le communiquer au réseau. Il va recevoir un certain nombre de XTZ en récompense.
Plusieurs bakers sont élu pour créer un bloc, avec une liste de priorités. Le plus prioritaire va essayer de créer un bloc. S'il n'y parvient pas dans le délai imparti, la main passera au suivant. Un bloc généré par le baker n'ayant pas la priorité sera tout simplement invalide et refusé par le réseau.

Tezos repose aussi sur les **endorsers**, des bakers qui vont pouvoir approuver le bloc nouvellement créé, moyennent, là aussi, récompense. Ensuite, chaque autre membre du réseau va devoir valider le bloc sur sa propre version de la chaîne.

Le protocole va élire les bakers et les endorsers au début de chaque cycle, pour tous les blocs du cycle. Pour chaque bloc, le protocole établi une liste de 64 bakers, par priorité, et attribue 32 slots d'endorsement à différents bakers. Un baker peut se voir attribuer plusieurs slots. Si un endorser n'est pas en mesure de remplir son slot (parce qu'il est down à ce moment là par exemple), le slot correspondant restera vide.
Au plus un baker est "riche", au plus il aura de chance de se trouver en bonne place pour le baking et d'avoir beaucoup de slots d'endorsement.

Pour créer un bloc ou l'approuver, **un baker va devoir geler une partie de ses tokens**, qui ne lui seront rendu disponibles que 5 cycles plus tard.

On trouve aussi les **accusers**. Ces membres du réseau surveillent qu'un baker ne crée pas deux blocs concurrents en même temps ou ne soutienne pas deux fois un bloc. Dans le cas où une accusation est correcte, l'accuser qui l'a émise récupère une partie des fonds qui ont été gelés par le baker ou l'endorser. L'autre partie est brûlée.

Toute tentative de fraude d'un baker est donc immédiatement sanctionnée par un coup au portefeuille !

(Pour rappel, brûler une cryptomonnaie revient à en détruire une quantité donnée. C'est une action irréversible, qui ne doit pas être effectuée à la légère. Elle peut être effectuée dans le cadre du protocole lui-même dans certain cas, ou par un utilisateur, volontairement ou par erreur, en envoyant des fonds à une adresse n'appartenant à personne.)

### Processus d'évolution

L'évolution du processus se fait en 5 étapes qui durent 5 cycles chacune. La durée initiale était de 8 cycles, jusqu'à la version Edo, qui a été déployée mi février 2021.

Premièrement, le **proposal**, pendant laquelle les évolutions seront soumises à la communauté. Les développeurs vont soumettre des propositions, tout en mettant à disposition le code de celles-ci. Les membres du réseau vont pouvoir les tester et voter pour la proposition qu'ils préfèrent.

Ensuite, l'**exploration vote**. Les bakers vont voter afin de déterminer si la proposition qui a obtenu le plus de suffrages à l'étape précédente doit être, ou non, testée de façon plus approfondie. 

Puis le **testing**. Si la proposition est plébiscitée, un testnet qui l'embarque sera déployé. Tout le monde peut ainsi tester son fonctionnement.

Puis vient le **promote vote**. C'est le sprint final. Après la période de test, les bakers vont pouvoir voter pour activer définitivement la proposition sur la chaîne principale. Si elle est acceptée, elle sera automatiquement injectée.

Enfin, la période d'**adoption**, ajoutée par le protocole Edo en février 2021. Rien de spécial ne se passe pendant cette période, elle sert surtout de période tampon pour permettre aux membres du réseau de se mettre à jour.

La promotion d'une nouvelle fonctionnalité prend donc 25 cycles, soit environ 2 mois et 10 jours. Le développeur a la possibilité d'inclure dans le code de sa proposition le montant de la récompense qu'il recevra si elle est déployée. Il peut mettre le montant qu'il veut, mais ce montant sera inspecté par les bakers et influera sur la décision finale. Cela encourage donc à ne pas être trop gourmand.

## Composants

- **tezos-node** : c'est le cœur de la blockchain, il gère le protocole.
- **tezos-client** : il permet d'interagir avec ```tezos-node```.
- **tezos-admin-client** : un outil d'administration pour le ```tezos-node```
- **tezos-baker** : le baker, il permet de participer au consensus en créant de nouveaux blocs.
- **tezos-endorser** : l'endorser, il permet de participer au consensus en validant les blocs créés par d'autres bakers.
- **tezos-accuser** : l'accusateur

Le baker, l'endorser et l'accuser ne sont pas obligatoires si on cherche simplement à faire tourner un nœud pour accéder aux données de la blockchain ou envoyer des transactions.

## Installation

### Point d'attention

A l'heure où cet article est rédigé, le protocole Edo vient tout juste d'être publié.

Nous croiserons les termes suivants :
- **Carthage** : version 6 du protocole, son réseau Carthagenet a été supprimé mi décembre 2020
- **Deplhi** : version 7 du protocole, son réseau Delphinet est encore en activité mais elle n'est plus active sur le mainnet.
- **Edo** : version 8 du protocole, qui vient d'être activée sur le mainnet. Elle se décompose en 2 sous versions, PtEdoTez qui a été supprimée et remplacée par PtEdo2Zk. Attention à ne bien manipuler que PtEdo2Zk. Toute mention à PtEdoTez dans des exécutables ou des logs signifierait que ce n'est pas la bonne version qui tourne. La synchronisation ne sera pas bonne et le nœud ne pourra pas être exploité.

### Via apt

Sur Ubuntu, il est facile d'installer Tezos via le gestionnaire de paquets :
```
sudo add-apt-repository ppa:serokell/tezos && sudo apt-get update
sudo apt-get install tezos-client
sudo apt-get install tezos-node
sudo apt-get install tezos-admin-client
sudo apt-get install tezos-baker-008-ptedo2zk
sudo apt-get install tezos-endorser-008-ptedo2zk
sudo apt-get install tezos-accuser-008-ptedo2zk
```

Les correctifs sont moins mis à jour via cette solution. Pour travailler sur un testnet récent, donc sujet à des bugs potentiels et des correctifs, l'installation via les sources sera probablement une meilleure solution.

### Depuis les sources

Tezos étant développé en OCaml, nous devons passer par Opam, le package manager OCaml, pour l'installer via les sources :

```shell
# install opam
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)
opam init --bare

# switch to right compiler version
opam switch create for_tezos 4.09.1
eval $(opam env)

# install dependencies
opam install depext
opam depext tezos


# install all binaries
opam install tezos
```
Les binaires se trouveront dans ```~/.opam/for_tezos/bin``` :

```
tezos-accuser-007-PsDELPH1
tezos-accuser-008-PtEdo2Zk
tezos-admin-client
tezos-baker-007-PsDELPH1
tezos-accuser-008-PtEdo2Zk
tezos-client
tezos-endorser-007-PsDELPH1
tezos-accuser-008-PtEdo2Zk
tezos-node
```

On trouve un seul ```tezos-node```. L'exécutable évolue au fil du temps pour prendre en charge les nouveaux testnets et se débarrasser des anciens. Par exemple, ici avec ```tezos-node``` v8.2, nous pouvons nous connecter au mainnet, à Delphinet et à Edonet. Le testnet précédent, Carthagenet, a été supprimé et n'est plus utilisable.

Nous pouvons aussi voir que les accuser, baker et endorser sont, quant à eux, spécifique à une version du protocole. Le build nous en a construit pour Delphinet et Edonet.

Un seul ```tezos-node``` pour les gouverner tous, mais des binaires dépendants du protocole pour contribuer à la sécurisation du réseau.

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
  "network": "edonet"
}
```

[Vérifiez bien quel est le testnet du moment](https://tezos.gitlab.io/introduction/test_networks.html). Si vous utilisez un testnet abandonné car l'évolution qu'il contient a déjà été intégrée au mainnet, vous risquez d'être le seul nœud connecté, vous ne pourrez pas faire grand-chose.
Ici, nous nous connectons sur Edonet.

Dorénavant, en étant connecté sur un testnet, le résultat de toutes nos commandes via ```tezos-client``` seront précédés d'un avertissement indiquant que nous ne sommes pas sur le mainnet.

## Création de l'identité et des comptes

Afin de pouvoir faire partie sur réseau Tezos, il faut que notre nœud puisse être identifié. Il faut générer une identité :

```
tezos-node identity generate
```

Ca prendra un peu de temps pour générer les clés. Un fichier ```identity.json``` sera ensuite généré dans le répertoire ```~/.tezos-node```. Il contiendra nos clés publiques et privées. À conserver soigneusement et en sécurité !


## Lancement du nœud local

Pour lancer le nœud Tezos local, on utilise la commande suivante :

```
tezos-node run --rpc-addr 127.0.0.1:8732 --data-dir ~/.tezos-node --network edonet
```

On précise le paramètre ```--rpc-addr url:port``` pour activer l'interface RPC qui permettra de communiquer avec le nœud.
Par défaut, elle se lance sur le port 8732, il n'est donc pas obligatoire de le préciser.

Il est possible de définir le répertoire où seront stockées les données avec ```--data-dir``` (par défaut, dans ```.tezos-node```) et de préciser sur quel réseau se connecter avec ```--network``` (si nous ne l'avons pas précisé dans ```config.json```, et par défaut, ```mainnet```).

De façon générale, il existe un certain nombre d'options pour le lancement d'un nœud (réseau de connexion, type de nœud : complet, léger ou archive ...) qui peuvent être soit définie par les paramètres en ligne de commande soit dans le fichier ```config.json```. Elles sont disponibles avec ```tezos-node --help```.

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

L'intégralité des commandes RPC générales est [disponible sur le site de Tezos](https://tezos.gitlab.io/shell/rpc.html#rpc-index-shell)


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

Vérifions que nous avons bien nos comptes :

```
> tezos-client list known contracts
alex: tz1.....
bob: tz1......
```

Les deux alias doivent s'afficher, ainsi que leurs adresses.

Pour la suite, nous pourrons utiliser indifféremment les adresses tz1 ou leurs alias.


Comme nous sommes sur le testnet, nous pouvons les alimenter avec des ꜩ obtenus via le faucet : https://faucet.tzalpha.net/. Un certain nombre de comptes de tests sont pré-créés et initialisés sur chaque réseau de test. Le faucet permet d'en obtenir un, sous forme d'un fichier json qui contient la définition de ce compte. Les comptes obtenus ainsi sont utilisables sur n'importe quel testnet.

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
Et voilà, nous sommes riches ! Bob semble avoir eu plus de chance qu'Alex. Le faucet distribue des sommes aléatoires.
(Petite précision : n'essayez pas de trafiquer le fichier json pour avoir encore plus de ꜩ, ça ne fonctionnera pas :) ).

Nous allons tester un premier transfert de 1 ꜩ d'Alex vers Bob :
```
tezos-client transfer 1 from alex to bob --dry-run
```

L'option ```--dry-run``` permet de simuler la transaction sans l'envoyer sur le réseau, pour la tester. Nous obtenons alors la description de tout ce qui changera grâce cette transaction : les changements de balances, les frais, le gaz utilisé, les adresses impactées ...

Après vérification, nous allons lancer la transaction pour de bon cette fois, en enlevant le ```--dry-run``` : 
```
tezos-client transfer 1 from alex to bob
```
Là encore, il faut attendre un petit moment que le réseau ne valide la transaction.

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

Echec, une erreur s'affiche :
``The operation will burn ꜩ0.06425 which is higher than the configured burn cap (ꜩ0).
Use '--burn-cap 0.06425' to emit this operation.``

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

Nous pouvons inspecter nos transactions sur l'explorateur de blocks [TzStats Edonet](https://edo.tzstats.com/) (ou sur n'importe quel autre explorateur).

## Baking et délégation

### Le baker

Pour devenir baker, la première condition est de détenir 8000 ꜩ. Avec le faucet, il est facile de réunir cette somme sur le testnet. Sur le mainnet, pas le choix, il faut passer à la caisse.

Si nous souhaitons qu'Alex devienne baker, nous devons lui transférer quelques milliers de ꜩ depuis le compte de Bob pour qu'il atteigne les 8000 ꜩ. Nous sommes maintenant experts dans cette manipulation :

```
tezos-client transfer 5000 from bob to alex
```

Puis pour vérifier :

``` 
> tezos-client get balance for alex
11488.564958 ꜩ
```
Et hop, une bonne chose de faite.

Ensuite, nous devons enregistrer le compte d'Alex en tant que baker délégué :

``` 
tezos-client register key alex as delegate
```

Une fois enregistré, il faut un peu de patience. Notre baker ne sera autorisé qu'après 7 cycles, soit un peu moins de 3 semaines.

...

3 semaines plus tard ...

...

Heureusement, nous sommes sur un testnet. Et sur les testnets, le nombre de blocs par cycles n'est que de 2048 au lieu de 4096 et qu'un bloc est créé toutes les 30 secondes au lieu de toutes les minutes. Ce qui donne des cycles d'environ 17 heures. 7 cycles ne vont durer que 5 jours.
...

Donc, 5 jours plus tard ...

...

Nous devons apparaître dans la [liste des bakers d'Edonet](https://edo.tzstats.com/bakers).

Nous avons installé le baker précédemment. Il s'agit d'un exécutable qui va s'appuyer sur le nœud local pour créer des blocs, et il va le faire pour le compte d'un utilisateur.

Pour le lancer, pour le compte d'Alex :
```
tezos-baker-007-PsDELPH1 run with local node ~/.tezos-node alex
```

Tant que le message ```No slot found at level xxxxxx (max_priority = 64)``` s'affiche, c'est que notre baker n'a obtenu encore le droit de créer de bloc.

### Déléguer

Si nous ne pouvons pas ou ne voulons pas exploiter un baker, nous pouvons déléguer nos ꜩ à un baker de notre choix.

Pour notre exemple, sur Edonet, nous pouvons trouver la [liste des bakers](https://edo.tzstats.com/bakers), comme vu précédemment.
Une liste des bakers est disponible pour le mainnet sur [MyTezosBaker](https://mytezosbaker.com/).

Le choix d'un baker à qui déléguer nos ꜩ se fait sur plusieurs critères. D'abord, la confiance que nous lui accordons pour se comporter convenablement sur le réseau, c'est-à-dire ne pas être hors service trop souvent, ne pas chercher à contourner les règles au risque d'être repéré par un accuser ...

On peut aussi regarder le taux de rentabilité qu'il propose, de quel pays il vient, quelle organisation le soutient ... Bref, le choix n'est pas uniquement technique mais bien en ensemble de critères qui peuvent être propres à chacun.

Une fois notre baker choisi, let's delegate !



Déléguer son compte à un baker se fait en deux étapes. D'abord, nous devons révéler notre clé publique :
```
tezos-client reveal key for carl
```

Ensuite, la délégation : 

```
tezos-client set delegate for carl to <adresse tz1 du baker choisi>
```

Chaque étape coûte quelques ꜩ. Nous pouvons omettre la révélation. Dans ce cas, elle sera effectuée automatiquement lors de la délégation.

Et voilà, nous avons délégué le compte de Carl à un baker. Il faudra attendre la fin du cycle pour que notre délégation soit prise en compte. Puis, à chaque cycle où notre baker sera sélectionné pour créer ou soutenir un block, nous recevrons une partie de la récompense. 

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

Si nous avions connecté notre nœud à Delphinet, nous aurions pu anticiper la venue d'Edonet. Nous allons donc créer un second nœud qui sera connecté lui aussi à Edonet, mais qui pourrait très bien être connecté au prochain testnet, dès qu'il sera connu. Nous aurons donc deux instances qui vont fonctionner en parallèle.

Créons un répertoire qui contiendra tous les éléments de notre second nœud Edonet :
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

Et finalement, nous pouvons le lancer, avec un port RPC différent que celui qui tourne déjà sur Edonet :
```
tezos-node run --rpc-addr 127.0.0.1:8733 --data-dir ~/tezos-edonet
```

Le jour où Edonet sera arrêté, nous pourrons supprimer le contenu du répertoire ```.tezos-node``` dans lequel nous avions laissé, par défaut, les données de notre nœud.

## Conclusion

Nous savons maintenant :
- Comment fonctionne Tezos
- L'installer, depuis les sources ou un dépôt
- Lancer le nœud local
- Créer des comptes 
- Effectuer des opérations simples comme transférer des ꜩ ou vérifier les balances
- Participer au fonctionnement réseau avec un baker ou un délégateur
- Gérer des répertoires différents ou par défaut pour plusieurs nœuds
- Connecter un framework JS à notre nœud local

Au prochain épisode, nous verrons comment [écrire des smart contracts et développer des DApp pour Tezos](smartcontracts.md).