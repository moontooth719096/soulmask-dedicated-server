# Soulmask Dedicated Server Image

This folder contains a Docker image for running the Soulmask dedicated server.

## Build

```bash
docker build -t soulmask-dedicated-server:latest .
```

## Run

```bash
docker run -d \
  --name soulmask-dedicated-server \
  -p 8777:8777/tcp \
  -p 8777:8777/udp \
  -p 27015:27015/tcp \
  -p 27015:27015/udp \
  -p 18888:18888/tcp \
  -p 19000:19000/tcp \
  -e SOULMASK_SERVER_NAME="Soulmask Server" \
  -e SOULMASK_MAX_PLAYERS=50 \
  -e SOULMASK_PASSWORD="" \
  -e SOULMASK_ADMIN_PASSWORD="" \
  -e SOULMASK_PVP=false \
  -e SOULMASK_LEVEL_NAME=Level01_Main \
  -e SOULMASK_RCON_PASSWORD="" \
  -e SOULMASK_RCON_PORT=19000 \
  -v soulmask-data:/data/WS/Saved \
  soulmask-dedicated-server:latest
```

## Environment Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `SOULMASK_SERVER_NAME` | `Soulmask-Server` | Server name shown in-game and in server listings. |
| `SOULMASK_MAX_PLAYERS` | `50` | Maximum number of players allowed on the server. |
| `SOULMASK_PASSWORD` | empty string | Player password for joining the server. Leave empty for no password. |
| `SOULMASK_ADMIN_PASSWORD` | empty string | Administrator password for server management commands. |
| `SOULMASK_PVP` | `false` | `true` enables PvP, `false` enables PvE. |
| `SOULMASK_LEVEL_NAME` | `Level01_Main` | Level or map name loaded when the server starts. `DLC_Level01_Main` can also be used for the DLC map. |
| `SOULMASK_PORT` | `8777` | Main gameplay connection port. |
| `SOULMASK_QUERY_PORT` | `27015` | Steam query port used by server browsers and status queries. |
| `SOULMASK_RCON_PASSWORD` | empty string | RCON password. Leave empty to disable RCON. |
| `SOULMASK_RCON_PORT` | `19000` | RCON connection port. |
| `SOULMASK_RCON_ADDR` | empty string | RCON bind address. Leave it blank to use the server's default bind behavior; fill in an IP only when you need a specific interface. |
| `SOULMASK_BACKUP_INTERVAL` | `900` | Backup interval, usually in seconds. |
| `SOULMASK_SAVING_INTERVAL` | `600` | Save interval, usually in seconds. |

> Note: The AppID is fixed to the Linux dedicated server version `3017300`, so you do not need to configure it manually. `SOULMASK_LEVEL_NAME` can use either `Level01_Main` or `DLC_Level01_Main` depending on the server version.

## Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| `8777` | TCP / UDP | Main gameplay connection port for players. |
| `27015` | TCP / UDP | Steam query port used for server listing and status checks. |
| `18888` | TCP | Management port used for server control and save/close operations. |
| `19000` | TCP | RCON connection port used when RCON is enabled. |

> Note: Per the guide, RCON requires `-rconpsw` and can optionally use a bind address and TCP port. This image automatically adds `-rconpsw` and `-rconport` once you set `SOULMASK_RCON_PASSWORD`, and only adds `-rconaddr` when `SOULMASK_RCON_ADDR` is provided.

## Persistence

| Volume | Container Path | Purpose |
| --- | --- | --- |
| `soulmask-data` | `/data/WS/Saved` | Persists server data, settings, save files, and `Config` contents. |

You only need to mount `/data/WS/Saved` because both save files and `Config` live inside that directory. Recreating the container will not wipe the world data or server settings.

To enable RCON, set `SOULMASK_RCON_PASSWORD` and make sure `19000/tcp` is open. If you change `SOULMASK_RCON_PORT`, update the port mapping accordingly.

## GameXishu Editor

If you want to edit `GameXishu.json`, open [GameXishuEditor.html](https://moontooth719096.github.io/soulmask-dedicated-server/GameXishuEditor.html) directly:

1. You can load the built-in default without importing any file first.
2. You can also import your own `GameXishu.json`.
3. Pick Casual / Easy / Normal / Hard / Master, and the editor will apply the matching Defaults per Difficulty to the loaded data.
4. Edit the fields you want to change, and the editor will show the reference range and difficulty presets.
5. Use "Save As" to download a new JSON file.

If your browser blocks reading the bundled default file from the same folder, use "Import and load" instead.

This editor is fully client-side and does not need a backend service.

## Notes

This image downloads and installs the Soulmask dedicated server first, then launches the server entry script. If the official launcher name changes, update the launcher search rules in [docker-entrypoint.sh](docker-entrypoint.sh).
