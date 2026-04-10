#!/bin/bash
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

launcher=""
while IFS= read -r candidate; do
    launcher="$candidate"
    break
done < <(find "$install_dir" -maxdepth 4 -type f \( -name 'StartServer.sh' -o -name 'startserver.sh' -o -name 'SoulmaskServer.sh' \) | sort)

if [ -z "$launcher" ]; then
    echo "Could not find a Soulmask server launcher under ${install_dir}." >&2
    exit 1
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
level_name="${SOULMASK_LEVEL_NAME:-Level01_Main}"
pvp_flag="-pvp"

if [ "${SOULMASK_PVP:-false}" = "false" ]; then
    pvp_flag="-pve"
fi

launch_args=(
    "${level_name}"
    "-SteamServerName=${server_name}"
    "-MaxPlayers=${max_players}"
    "-PSW=${password}"
    "-adminpsw=${admin_password}"
    "${pvp_flag}"
)

exec bash "$launcher" "${launch_args[@]}" "$@"