#! /bin/sh -e

# Show help information.
# Snarkjs exits with a code of 99 when printing help for some reason, so we need to ignore the exit code.
set +e
snarkjs --help
set -e

# Run a small mock trusted setup for bn128
mkdir /tmp/snarkjs_bn128

# Initialize powers of tau file
snarkjs powersoftau new bn128 10 /tmp/snarkjs_bn128/initial.ptau 

# Multiply old powers of tau by private random input (toxic waste)
snarkjs powersoftau contribute /tmp/snarkjs_bn128/initial.ptau /tmp/snarkjs_bn128/second.ptau -e="input"

# Test export and import utilities for distributed ceremonies
snarkjs powersoftau export challenge /tmp/snarkjs_bn128/second.ptau /tmp/snarkjs_bn128/challenge
snarkjs powersoftau challenge contribute bn128 /tmp/snarkjs_bn128/challenge /tmp/snarkjs_bn128/response -e="input"
snarkjs powersoftau import response /tmp/snarkjs_bn128/second.ptau /tmp/snarkjs_bn128/response /tmp/snarkjs_bn128/third.ptau -n="External Input"

# Shift one more time by public source of randomness
snarkjs powersoftau beacon /tmp/snarkjs_bn128/third.ptau /tmp/snarkjs_bn128/second_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="beacon"

# Convert raw powers of tau to Lagrange poly evaluations
snarkjs powersoftau prepare phase2 /tmp/snarkjs_bn128/second_beacon.ptau /tmp/snarkjs_bn128/final.ptau

# Verify contents of powers of tau file via transcript checks
snarkjs powersoftau verify /tmp/snarkjs_bn128/final.ptau

# Testing all save and load utilities
snarkjs powersoftau truncate /tmp/snarkjs_bn128/final.ptau
snarkjs powersoftau convert /tmp/snarkjs_bn128/final.ptau /tmp/snarkjs_bn128/converted.ptau
snarkjs powersoftau export json /tmp/snarkjs_bn128/final.ptau /tmp/snarkjs_bn128/final_ptau.json

# get rid of all ptau files
rm -rf /tmp/snarkjs_bn128/

# Run a mock trusted setup for a different curve: bls12-381
mkdir /tmp/snarkjs_bls12_381

# Initialize powers of tau file
snarkjs powersoftau new bls12-381 8 /tmp/snarkjs_bls12_381/initial.ptau 

# Multiply old powers of tau by private random input (toxic waste)
snarkjs powersoftau contribute /tmp/snarkjs_bls12_381/initial.ptau /tmp/snarkjs_bls12_381/second.ptau -e="input"

# Test export and import utilities for distributed ceremonies
snarkjs powersoftau export challenge /tmp/snarkjs_bls12_381/second.ptau /tmp/snarkjs_bls12_381/challenge
snarkjs powersoftau challenge contribute bls12-381 /tmp/snarkjs_bls12_381/challenge /tmp/snarkjs_bls12_381/response -e="some random text"
snarkjs powersoftau import response /tmp/snarkjs_bls12_381/second.ptau /tmp/snarkjs_bls12_381/response /tmp/snarkjs_bls12_381/third.ptau -n="External Input"

# Shift one more time by public source of randomness
snarkjs powersoftau beacon /tmp/snarkjs_bls12_381/third.ptau /tmp/snarkjs_bls12_381/second_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="beacon"

# Convert raw powers of tau to Lagrange poly evaluations
snarkjs powersoftau prepare phase2 /tmp/snarkjs_bls12_381/second_beacon.ptau /tmp/snarkjs_bls12_381/final.ptau

# Verify contents of powers of tau file via transcript checks
snarkjs powersoftau verify /tmp/snarkjs_bls12_381/final.ptau

# Testing all save and load utilities
snarkjs powersoftau truncate /tmp/snarkjs_bls12_381/final.ptau
snarkjs powersoftau convert /tmp/snarkjs_bls12_381/final.ptau /tmp/snarkjs_bls12_381/converted.ptau
snarkjs powersoftau export json /tmp/snarkjs_bls12_381/final.ptau /tmp/snarkjs_bls12_381/final_ptau.json

# get rid of all ptau files
rm -rf /tmp/snarkjs_bls12_381/


# Testing R1CS Read Utilities
# All of these utilities require a precompiled circom circuit
mkdir /tmp/snarkjs_r1cs

# Print R1CS file metadata (number of constraints, inputs, etc.)
snarkjs r1cs info circom_files/circuit.r1cs

# List all of the constraints in the circuit
snarkjs r1cs print circom_files/circuit.r1cs circom_files/circuit.sym

# Transpile R1CS format into a human-readable JSON file
snarkjs r1cs export json circom_files/circuit.r1cs /tmp/snarkjs_r1cs/output.json

# get rid of all r1cs files
rm -rf /tmp/snarkjs_r1cs