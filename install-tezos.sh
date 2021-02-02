#!/bin/bash

# install opam
sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh
opam init --bare

# switch to right compiler version
opam switch create for_tezos 4.09.1
eval $(opam env)

# install dependencies
opam install depext
opam depext tezos


# install all binaries
opam install tezos

# binaries are built in ~/.opam/for_tezos/bin/
