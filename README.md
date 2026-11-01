# docker-aliases

My Docker shortcuts, installable with one command.

| Command | Does |
|---------|------|
| `dc`    | `docker compose` |
| `dup`   | `docker compose up -d` |
| `dls`   | Readable `docker ps`: project, name, status (+ health), uptime, IP, ports, restarts |

```
PROJECT  NAME        STATUS               UPTIME  IP          PORTS               RESTARTS
blog     blog-db-1   running (unhealthy)  1h 6m   172.18.0.2  5432->5432          3
blog     blog-web-1  running (healthy)    2d 7h   172.18.0.3  8080->80,8443->443  0
```

`dls` passes options through to `docker ps`, so `dls -a` also shows stopped containers.

## Install

```bash
wget -qO- https://raw.githubusercontent.com/Martinski-Github/docker-aliases/main/install.sh | bash
```

or with curl:

```bash
curl -fsSL https://raw.githubusercontent.com/Martinski-Github/docker-aliases/main/install.sh | bash
```

Then open a new terminal (or `source ~/.docker-aliases.sh`). Run the same command again to update.

It installs for the current user only, no sudo needed:

- `~/.docker-aliases.sh` - the aliases, sourced from `~/.bashrc` (and `~/.zshrc` if you have one)
- `~/.local/bin/dls`

## Uninstall

```bash
wget -qO- https://raw.githubusercontent.com/Martinski-Github/docker-aliases/main/install.sh | bash -s -- --uninstall
```
