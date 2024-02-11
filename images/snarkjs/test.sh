#! /bin/sh -e

# Show help information.
# Snarkjs exits with a code of 99 when printing help for some reason, so we need to ignore the exit code.
set +e
snarkjs --help
set -e

# Run a small mock trusted setup for bn128 and bls12-381
for curve in BN254 BLS12-381; do
    mkdir /tmp/snarkjs_$curve

    # Initialize powers of tau file
    snarkjs powersoftau new $curve 12 /tmp/snarkjs_$curve/initial.ptau 

    # Multiply old powers of tau by private random input (toxic waste)
    snarkjs powersoftau contribute /tmp/snarkjs_$curve/initial.ptau /tmp/snarkjs_$curve/second.ptau -e="input"

    # Test export and import utilities for distributed ceremonies
    snarkjs powersoftau export challenge /tmp/snarkjs_$curve/second.ptau /tmp/snarkjs_$curve/challenge
    snarkjs powersoftau challenge contribute $curve /tmp/snarkjs_$curve/challenge /tmp/snarkjs_$curve/response -e="input"
    snarkjs powersoftau import response /tmp/snarkjs_$curve/second.ptau /tmp/snarkjs_$curve/response /tmp/snarkjs_$curve/third.ptau -n="External Input"

    # Shift one more time by public source of randomness
    snarkjs powersoftau beacon /tmp/snarkjs_$curve/third.ptau /tmp/snarkjs_$curve/second_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="beacon"

    # Convert raw powers of tau to Lagrange poly evaluations
    snarkjs powersoftau prepare phase2 /tmp/snarkjs_$curve/second_beacon.ptau /tmp/snarkjs_$curve/final.ptau

    # Verify contents of powers of tau file via transcript checks
    snarkjs powersoftau verify /tmp/snarkjs_$curve/final.ptau

    # Testing all save and load utilities
    snarkjs powersoftau truncate /tmp/snarkjs_$curve/final.ptau
    snarkjs powersoftau convert /tmp/snarkjs_$curve/final.ptau /tmp/snarkjs_$curve/converted.ptau
    snarkjs powersoftau export json /tmp/snarkjs_$curve/final.ptau /tmp/snarkjs_$curve/final_ptau.json


    # Test Groth16 Backend (Requiring Phase 2)
    # snarkjs groth16 setup circuit.r1cs pot14_final.ptau circuit_0000.zkey


    # Test Plonk and Fflonk Backends (No Phase 2 required)
    for backend in plonk fflonk; do
        mkdir /tmp/snarkjs_$curve/$backend/
        snarkjs $backend setup circom_files/circuit.r1cs /tmp/snarkjs_$curve/final.ptau /tmp/snarkjs_$curve/$backend/circuit.zkey

        # end-to-end proof (no preconstructed witness)
        snarkjs $backend fullprove circom_files/input.json circom_files/circuit.wasm /tmp/snarkjs_$curve/$backend/circuit.zkey /tmp/snarkjs_$curve/$backend/proof.json /tmp/snarkjs_$curve/$backend/public.json

    done

    # get rid of all ptau files
    rm -rf /tmp/snarkjs_$curve/
done

# UTILITIES BELOW ARE INDEPENDENT OF BACKEND AND PROVING CURVE

# R1CS Read Utilities
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


# Witness Utilities
mkdir /tmp/snarkjs_wtns

# Use Snarkjs CLI witness generator
snarkjs wtns calculate circom_files/circuit.wasm  circom_files/input.json /tmp/snarkjs_wtns/witness.wtns

# Use Snarkjs CLI witness generator in debug mode
snarkjs wtns debug circom_files/circuit.wasm  circom_files/input.json /tmp/snarkjs_wtns/witness.wtns circom_files/circuit.sym

# Turn witness file into human-readable JSON
snarkjs wtns export json /tmp/snarkjs_wtns/witness.wtns /tmp/snarkjs_wtns/witness.json

# Validate a witness file against a circuit's R1CS file
# FIGURE OUT WHY THIS ISNT WORKING
# snarkjs wtns check circom_files/circuit.r1cs /tmp/snarkjs_wtns/witness.wtns


# get rid of all wtns files
rm -rf /tmp/snarkjs_wtns


