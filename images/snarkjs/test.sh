#! /bin/sh -e

# Show help information.
# Snarkjs exits with a code of 99 when printing help for some reason, so we need to ignore the exit code.
set +e
snarkjs --help
set -e


mkdir /tmp/snarkjs/

# R1CS Read Utilities
# All of these utilities require a precompiled circom circuit
mkdir /tmp/snarkjs/r1cs

# Print R1CS file metadata (number of constraints, inputs, etc.)
snarkjs r1cs info circom_files/circuit.r1cs

# Print binary file metadata
snarkjs file info circom_files/circuit.r1cs 

# List all of the constraints in the circuit
snarkjs r1cs print circom_files/circuit.r1cs circom_files/circuit.sym

# Transpile R1CS format into a human-readable JSON file
snarkjs r1cs export json circom_files/circuit.r1cs /tmp/snarkjs/r1cs/output.json

# Witness Utilities
mkdir /tmp/snarkjs/wtns

# Use Snarkjs CLI witness generator
snarkjs wtns calculate circom_files/circuit.wasm  circom_files/input.json /tmp/snarkjs/wtns/witness.wtns

# Use Snarkjs CLI witness generator in debug mode
snarkjs wtns debug circom_files/circuit.wasm  circom_files/input.json /tmp/snarkjs/wtns/witness.wtns circom_files/circuit.sym

# Turn witness file into human-readable JSON
snarkjs wtns export json /tmp/snarkjs/wtns/witness.wtns /tmp/snarkjs/wtns/witness.json

# Validate a witness file against a circuit's R1CS file
snarkjs wtns check circom_files/circuit.r1cs circom_files/witness.wtns


# Run a small mock trusted setup for bn128 and bls12-381
for curve in BN254 BLS12-381; do
    mkdir /tmp/snarkjs/$curve

    # Initialize powers of tau file
    snarkjs powersoftau new $curve 14 /tmp/snarkjs/$curve/initial.ptau 

    # Multiply old powers of tau by private random input (toxic waste)
    snarkjs powersoftau contribute /tmp/snarkjs/$curve/initial.ptau /tmp/snarkjs/$curve/second.ptau -e="input"

    # Test export and import utilities for distributed ceremonies
    snarkjs powersoftau export challenge /tmp/snarkjs/$curve/second.ptau /tmp/snarkjs/$curve/challenge
    snarkjs powersoftau challenge contribute $curve /tmp/snarkjs/$curve/challenge /tmp/snarkjs/$curve/response -e="input"
    snarkjs powersoftau import response /tmp/snarkjs/$curve/second.ptau /tmp/snarkjs/$curve/response /tmp/snarkjs/$curve/third.ptau

    # Shift one more time by public source of randomness
    snarkjs powersoftau beacon /tmp/snarkjs/$curve/third.ptau /tmp/snarkjs/$curve/second_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10

    # Convert raw powers of tau to Lagrange poly evaluations
    snarkjs powersoftau prepare phase2 /tmp/snarkjs/$curve/second_beacon.ptau /tmp/snarkjs/$curve/final.ptau

    # Verify contents of powers of tau file via transcript checks
    snarkjs powersoftau verify /tmp/snarkjs/$curve/final.ptau

    # Testing all save and load utilities
    snarkjs powersoftau truncate /tmp/snarkjs/$curve/final.ptau
    snarkjs powersoftau convert /tmp/snarkjs/$curve/final.ptau /tmp/snarkjs/$curve/converted.ptau
    snarkjs powersoftau export json /tmp/snarkjs/$curve/final.ptau /tmp/snarkjs/$curve/final_ptau.json

    # bls12-128 proving not supported by snarkjs
    if [ "$curve" = "BN254" ]
    then

        # Test Groth16 Backend (Requiring Phase 2) and ZKEY utils
        mkdir /tmp/snarkjs/BN254/groth16/

        # Initialize circuit specific key
        snarkjs groth16 setup circom_files/circuit.r1cs /tmp/snarkjs/BN254/final.ptau /tmp/snarkjs/BN254/groth16/circuit_1.zkey

        # TESTING ZKEY UTILITIES
        snarkjs zkey contribute /tmp/snarkjs/BN254/groth16/circuit_1.zkey /tmp/snarkjs/BN254/groth16/circuit_2.zkey -e="input"

        # External Ceremony Contributions
        snarkjs zkey export bellman /tmp/snarkjs/BN254/groth16/circuit_2.zkey  /tmp/snarkjs/BN254/groth16/challenge_phase2_3
        snarkjs zkey bellman contribute bn128 /tmp/snarkjs/BN254/groth16/challenge_phase2_3 /tmp/snarkjs/BN254/groth16/response_phase2_3 -e="input"
        snarkjs zkey import bellman /tmp/snarkjs/BN254/groth16/circuit_2.zkey /tmp/snarkjs/BN254/groth16/response_phase2_3 /tmp/snarkjs/BN254/groth16/circuit_3.zkey

        # Verify the zkey matches the initial trusted setup and circuit
        snarkjs zkey verify circom_files/circuit.r1cs /tmp/snarkjs/BN254/final.ptau /tmp/snarkjs/BN254/groth16/circuit_3.zkey

        # Apply public source of randomness
        snarkjs zkey beacon /tmp/snarkjs/BN254/groth16/circuit_3.zkey /tmp/snarkjs/BN254/groth16/final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10

        # Save a JSONified version of the circuit zkey file
        snarkjs zkey export json /tmp/snarkjs/BN254/groth16/final.zkey /tmp/snarkjs/BN254/groth16/finalzkey.json

        # Save a copy of the verification key
        snarkjs zkey export verificationkey /tmp/snarkjs/BN254/groth16/final.zkey /tmp/snarkjs/BN254/groth16/verification_key.json

        # End-to-end proof (no preconstructed witness)
        snarkjs groth16 fullprove circom_files/input.json circom_files/circuit.wasm /tmp/snarkjs/BN254/groth16/final.zkey /tmp/snarkjs/BN254/groth16/proofA.json /tmp/snarkjs/BN254/groth16/publicA.json

        # Verify the proof
        snarkjs groth16 verify /tmp/snarkjs/BN254/groth16/verification_key.json /tmp/snarkjs/BN254/groth16/publicA.json /tmp/snarkjs/BN254/groth16/proofA.json

        # Create a proof from a serialized witness
        snarkjs groth16 prove /tmp/snarkjs/BN254/groth16/final.zkey circom_files/witness.wtns /tmp/snarkjs/BN254/groth16/proofB.json /tmp/snarkjs/BN254/groth16/publicB.json

        # Verify that proof
        snarkjs groth16 verify /tmp/snarkjs/BN254/groth16/verification_key.json /tmp/snarkjs/BN254/groth16/publicB.json /tmp/snarkjs/BN254/groth16/proofB.json

        # Test zkey smart contract utilities
        snarkjs zkey export solidityverifier /tmp/snarkjs/BN254/groth16/final.zkey /tmp/snarkjs/BN254/groth16/verifier.sol
        snarkjs zkey export soliditycalldata /tmp/snarkjs/BN254/groth16/publicB.json /tmp/snarkjs/BN254/groth16/proofB.json

        # Test Plonk and Fflonk Backends (No Phase 2 required)
        for backend in plonk fflonk; do

                echo "Proving with $backend"

                mkdir /tmp/snarkjs/$curve/$backend/

                # Generate the proving key from powers of tau file
                snarkjs $backend setup circom_files/circuit.r1cs /tmp/snarkjs/$curve/final.ptau /tmp/snarkjs/$curve/$backend/circuit.zkey

                # Save a copy of the verification key
                snarkjs zkey export verificationkey /tmp/snarkjs/$curve/$backend/circuit.zkey /tmp/snarkjs/$curve/$backend/verification_key.json

                # End-to-end proof (no preconstructed witness)
                snarkjs $backend fullprove circom_files/input.json circom_files/circuit.wasm /tmp/snarkjs/$curve/$backend/circuit.zkey /tmp/snarkjs/$curve/$backend/proofA.json /tmp/snarkjs/$curve/$backend/publicA.json

                # Verify the proof
                snarkjs $backend verify /tmp/snarkjs/$curve/$backend/verification_key.json /tmp/snarkjs/$curve/$backend/publicA.json /tmp/snarkjs/$curve/$backend/proofA.json

                # Create a proof from a serialized witness
                snarkjs $backend prove /tmp/snarkjs/$curve/$backend/circuit.zkey circom_files/witness.wtns /tmp/snarkjs/$curve/$backend/proofB.json /tmp/snarkjs/$curve/$backend/publicB.json

                # Verify that proof
                snarkjs $backend verify /tmp/snarkjs/$curve/$backend/verification_key.json /tmp/snarkjs/$curve/$backend/publicB.json /tmp/snarkjs/$curve/$backend/proofB.json
        done
    fi

done

# get rid of all testing files
rm -rf /tmp/snarkjs/