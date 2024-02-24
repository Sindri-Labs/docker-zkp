#! /bin/sh -e

# Show help information.
circomspect --help

# Analyze circuit and write results to a Sarif file.
circomspect -l INFO -v --allow CS0003 --allow CS0004 --allow CS0005 --allow CS0010 --allow P1004 -s analysis.sarif circuit.circom
