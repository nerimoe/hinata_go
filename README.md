# HINATA Go
配合 HINATA AimeIO 让你的手机变成刷卡器，并可以与 HINATA 读卡器等设备协同使用。

## Usage
**以下配置均已 HINATA 公共刷卡服务器 ( aime-ws.neri.moe ) 为例，请确保你的网络环境可以正常访问 Cloudflare 的服务**
1. 首先在你的游戏部署 [HINATA AimeIO](https://hinata.neri.moe/game-setting/sega/hinata-client/) ，然后配置远程刷卡服务器，使用文本直接编辑或使用 HINATA Client 图形化编辑均可：
    ```ini
    [aime]
    enable=1

    [aimeio]
    path=hinata.dll
    serverUrl=wss://aime-ws.neri.moe/REPLACEME
    ```
    ![alt text](readme_assets/image.png)

    **将REPLACEME替换为你自定义的一串英文字符串，并确保够唯一，否则可能会和他人重复**
2. 在 [Release](https://github.com/nerimoe/hinata_go/releases) 内下载最新版本的 HINATA Go，安装并打开
3. 在软件内添加一个 Instance，名称自定义，URL 则配置为 `https://aime-ws.neri.moe/REPLACEME`，如图所示：![alt text](readme_assets/image-1.png)

4. 打开游戏开始玩？！