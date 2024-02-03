#! /bin/sh -e

# Show help information.
# Snarkjs exits with a code of 99 when printing help for some reason, so we need to ignore the exit code.
set +e
snarkjs --help
set -e
