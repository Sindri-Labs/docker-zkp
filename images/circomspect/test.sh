#! /bin/sh -e

# Analyze circuit.
circomspect -l INFO -v --allow CS0003 --allow CS0004 --allow CS0005 --allow CS0010 --allow P1004 circuit.circom

# Show help information.
circomspect --help

# Output analysis results to a Sarif file.
circomspect -s analysis.sarif circuit.circom
