#!/bin/bash

if [ ! -e bin/nimrun ]; then
    echo 1>&2 "nimrun not yet built.  Building:"
    nimble build
    echo -e "\n"
fi

echo -e "Running script examples/hello:\n"

(cd examples/;
    PATH="../bin:$PATH" ./hello
)
