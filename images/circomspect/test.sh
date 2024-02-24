#! /bin/sh -e

# Analyze circuit.
circomspect -l INFO -v --allow CS0004 circuit.circom

# Show help information.
circomspect --help

# Test analysis with each supported curve.
for curve in BN254 BLS12_381 GOLDILOCKS; do
    circomspect -c $curve --allow CS0004 circuit.circom
done

# Output analysis results to a Sarif file.
circomspect -s analysis.sarif circuit.circom
