#!/bin/bash

echo -e "Building nimrun:"
nimble build

echo -e "\nRunning script examples/hello:\n"

(cd examples/;
    PATH="../bin:$PATH" ./hello
)
