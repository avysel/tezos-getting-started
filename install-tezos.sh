#!/bin/bash

# check rust compiler version
rustup set profile minimal
rustup toolchain install 1.39.0
rustup default 1.39.0
source $HOME/.cargo/env

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

# go to generated binaries and create first identity, to be able to bootstrap the node
cd ~/.opam/for_tezos/bin
./tezos-node identity generate
