#! /bin/sh -e

# Print help information.
nargo help

# Create a Noir project in a new directory.
nargo new /tmp/noir
rm -rf /tmp/noir

# Create a Noir project in the current directory.
mkdir /tmp/noir
cd /tmp/noir
nargo init
cd -
rm -rf /tmp/noir

# Print the current backend.
set +e
nargo backend current
set -e

# Check the constraint system for errors.
nargo check

# Format the Noir files in a workspace.
set +e
nargo fmt
set -e

# Generate a Solidity verifier smart contract for the program.
nargo codegen-verifier

# Compile the program and its secret execution trace into ACIR format.
nargo compile

# Execute a circuit to calculate its return value.
nargo execute

# Create a proof for the program.
nargo prove

# Veryify whether the proof is valid.
nargo verify

# Run the tests for the program.
nargo test

# Print detailed information on a circuit.
nargo info
