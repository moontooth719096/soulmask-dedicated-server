#!/usr/bin/env bash
set -euo pipefail

install_dir="${SOULMASK_DIR:-/opt/soulmask}"
data_dir="${SOULMASK_DATA_DIR:-/data}"
app_id="${SOULMASK_APP_ID:-3017300}"
saved_dir="${data_dir}/WS/Saved"
config_root="${saved_dir}/Config"

echo "Updating Soulmask server files for AppID ${app_id}..."
/opt/steamcmd/steamcmd.sh +force_install_dir "$install_dir" +login anonymous +app_update "$app_id" validate +quit

mkdir -p "${install_dir}/WS"
mkdir -p "$saved_dir" "$config_root/LinuxServer" "$config_root/WindowsServer"

if [ -e "${install_dir}/WS/Saved" ] && [ ! -L "${install_dir}/WS/Saved" ]; then
    rm -rf "${install_dir}/WS/Saved"
fi

ln -sfn "$saved_dir" "${install_dir}/WS/Saved"

level_name="${SOULMASK_LEVEL_NAME:-Level01_Main}"
launcher=""
while IFS= read -r candidate; do
    launcher="$candidate"
    break
done < <(find "$install_dir" -maxdepth 4 -type f \( -name 'WSServer.sh' -o -name 'StartServer.sh' -o -name 'startserver.sh' -o -name 'SoulmaskServer.sh' \) | sort)

if [ -z "$launcher" ]; then
    echo "Could not find a Soulmask server launcher under ${install_dir}." >&2
    exit 1
fi

launcher_name="$(basename "$launcher")"
if [ "$launcher_name" = "StartServer.sh" ] && [ "$level_name" != "Level01_Main" ]; then
    dlc_launcher="$(dirname "$launcher")/StartServerDLC.sh"
    cp "$launcher" "$dlc_launcher"
    if grep -q 'Level01_Main -server' "$dlc_launcher"; then
        sed -i "0,/Level01_Main -server/s//${level_name} -server/" "$dlc_launcher"
    else
        sed -i "0,/Level01_Main/s//${level_name}/" "$dlc_launcher"
    fi
    chmod +x "$dlc_launcher"
    launcher="$dlc_launcher"
fi

if [ ! -f "${config_root}/LinuxServer/Engine.ini" ]; then
    cat > "${config_root}/LinuxServer/Engine.ini" <<EOF
[URL]
Port=${SOULMASK_PORT:-8777}

[OnlineSubsystemSteam]
GameServerQueryPort=${SOULMASK_QUERY_PORT:-27015}

[Dedicated.Settings]
SteamServerName=${SOULMASK_SERVER_NAME:-Soulmask-Server}
MaxPlayers=${SOULMASK_MAX_PLAYERS:-50}
pvp=${SOULMASK_PVP:-true}
backup=${SOULMASK_BACKUP_INTERVAL:-900}
saving=${SOULMASK_SAVING_INTERVAL:-600}
EOF
fi

if [ ! -f "${config_root}/WindowsServer/Engine.ini" ]; then
    cp "${config_root}/LinuxServer/Engine.ini" "${config_root}/WindowsServer/Engine.ini"
fi

server_name="${SOULMASK_SERVER_NAME:-Soulmask-Server}"
max_players="${SOULMASK_MAX_PLAYERS:-50}"
password="${SOULMASK_PASSWORD:-}"
admin_password="${SOULMASK_ADMIN_PASSWORD:-}"
rcon_password="${SOULMASK_RCON_PASSWORD:-}"
rcon_port="${SOULMASK_RCON_PORT:-19000}"
rcon_addr="${SOULMASK_RCON_ADDR:-0.0.0.0}"
pvp_flag="-pvp"

if [ "${SOULMASK_PVP:-false}" = "false" ]; then
    pvp_flag="-pve"
fi

launch_args=(
    "-SteamServerName=${server_name}"
    "-MaxPlayers=${max_players}"
    "-PSW=${password}"
    "-adminpsw=${admin_password}"
    "${pvp_flag}"
)

if [ -n "$rcon_password" ]; then
    launch_args+=(
        "-rconpsw=${rcon_password}"
        "-rconport=${rcon_port}"
        "-rconaddr=${rcon_addr}"
    )
fi

exec bash "$launcher" "${launch_args[@]}" "$@"