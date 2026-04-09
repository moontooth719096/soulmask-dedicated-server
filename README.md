# Soulmask dedicated server image

這個資料夾提供一個可直接 build 的 Docker image，用來跑 Soulmask dedicated server。

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
  -e SOULMASK_SERVER_NAME="Soulmask Server" \
  -e SOULMASK_MAX_PLAYERS=50 \
  -e SOULMASK_PASSWORD="" \
  -e SOULMASK_ADMIN_PASSWORD="" \
  -e SOULMASK_PVP=false \
  -e SOULMASK_LEVEL_NAME=Level01_Main \
  -v soulmask-data:/data/WS/Saved \
  soulmask-dedicated-server:latest
```

## 環境變數

| 變數 | 預設值 | 用途 |
| --- | --- | --- |
| `SOULMASK_SERVER_NAME` | `Soulmask-Server` | 伺服器名稱，會顯示在遊戲或查詢結果中。 |
| `SOULMASK_MAX_PLAYERS` | `50` | 最大玩家數量。 |
| `SOULMASK_PASSWORD` | 空字串 | 玩家進伺服器時使用的密碼。留空代表不設密碼。 |
| `SOULMASK_ADMIN_PASSWORD` | 空字串 | 管理員密碼，用於管理指令或後台控制。 |
| `SOULMASK_PVP` | `false` | `true` 代表 PvP，`false` 代表 PvE。 |
| `SOULMASK_LEVEL_NAME` | `Level01_Main` | 伺服器啟動時載入的地圖或關卡名稱。 |
| `SOULMASK_PORT` | `8777` | 遊戲主連線埠。 |
| `SOULMASK_QUERY_PORT` | `27015` | Steam 查詢埠，用於伺服器列表與狀態查詢。 |
| `SOULMASK_BACKUP_INTERVAL` | `900` | 備份間隔，單位通常為秒。 |
| `SOULMASK_SAVING_INTERVAL` | `600` | 存檔間隔，單位通常為秒。 |

> 補充：AppID 已固定為 Linux 版 `3017300`，不需要另外設定。

## Port 說明

| Port | 協定 | 用途 |
| --- | --- | --- |
| `8777` | TCP / UDP | 玩家實際連線進遊戲的主埠。 |
| `27015` | TCP / UDP | 伺服器查詢埠，給 Steam / server browser 使用。 |
| `18888` | TCP | 管理埠，可用來做伺服器控制與關閉保存相關操作。 |

## 持久化

| Volume 路徑 | 容器內路徑 | 用途 |
| --- | --- | --- |
| `soulmask-data` | `/data/WS/Saved` | 持久化伺服器資料、設定與存檔，包含 `Config` 內容。 |

容器只需要把 `/data/WS/Saved` 掛出來，因為存檔與 `Config` 都在這個資料夾底下。也就是說，重新建容器不會把世界檔和設定洗掉。

## 備註

這份 image 預設會先下載並安裝 Soulmask dedicated server，再啟動對應的 server launcher。若官方更新了啟動腳本名稱，只需要調整 [docker-entrypoint.sh](docker-entrypoint.sh) 的 launcher 搜尋條件即可。