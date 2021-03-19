# Smart contracts, 2ème partie


Même opération avec les paramètres d'entrée :

```
ligo compile-parameter --syntax reasonligo SimpleHello.ligo main 'UpdateName("toto")'
> (Right "toto")
```