#! /bin/sh -e

# Compile the circuit.
circom -o /tmp/

# Output the constraints in r1cs format.
circom --r1cs -o /tmp/

# Output the witness in sym format.
circom --sym -o /tmp/

# Compile the circuit to wasm.
circom --wasm -o /tmp/

# Output the constraints in json format.
circom --json -o /tmp/

# Compile the circuit to wat.
circom --wat -o /tmp/

# Compile the circuit to c.
circom -c -o /tmp/

# Compile the circuit to c with no simplification applied.
circom -c --O0 -o /tmp/

# Compile the circuit to c with only signal to signal and signal to constant simplification.
circom -c --O1 -o /tmp/

# Compile the circuit to c with full constraint simplification.
circom -c --O2 -o /tmp/

# Show logs during compilation.
circom --verbose -o /tmp/

# Do an additional check over the constraints produced.
circom --inspect -o /tmp/

# Applies the old version of the heuristics when performing linear simplification.
circom --use_old_simplification_heuristics -o /tmp/

# Outputs the substitution applied in the simplification phase in json format.
circom --simplification_substitution -o /tmp/

# Print help information.
circom --help

# Print version information.
circom --version

# Test compiling with each supported curve.
for curve in bn128 bls12381 goldilocks grumpkin pallas vesta secq256r1; do
    circom -p $curve -o /tmp/
done
