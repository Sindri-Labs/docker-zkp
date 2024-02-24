# Sindri Docker Images

## Development

### Building Images

Build all images:

```bash
docker compose build
```

### Running Command Containers

This will execute the command container with a bind mount of `images/circom/` at `/sindri/` (which is also the current working directory) in the container:

```bash
# Replace "circom" with the appropriate command.
docker compose run circom

# With extr arguments to pass to the command:
docker compose run circom [arg1] [arg2] ...
```

### Running an Interactive Shell in a Command Container

It can be useful when debugging to drop into an interactive shell.
Because the command containers do not run as Docker Compose services, you need to use `docker compose run` with the `--entrypoint` argument:

```bash
# Replace "circom" with the appropriate command.
docker compose run --entrypoint /bin/bash circom
```
