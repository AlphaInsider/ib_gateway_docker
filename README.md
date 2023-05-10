<!-- PROJECT LOGO -->
<div align="center">
  <a href="https://alphainsider.com/">
    <img src="images/logo.png" alt="Logo">
  </a>
</div>

## Introduction
An easy low maintenance way of running Interactive Brokers Gateway in docker.

It includes:
- [IB Gateway Application](https://www.interactivebrokers.com/en/index.php?f=16457)
- [IBC Application](https://github.com/IbcAlpha/IBC) -
to control the IB Gateway Application (simulates user input).
- [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) -
a X11 virtual framebuffer to run IB Gateway Application without graphics hardware.
- [x11vnc](https://wiki.archlinux.org/title/x11vnc) -
a VNC server that allows to interact with the IB Gateway user interface (optional, for development / maintenance purpose).
- [socat](https://linux.die.net/man/1/socat) a tool to accept TCP connection from non-localhost and relay it to IB Gateway from localhost (IB Gateway restricts connections to 127.0.0.1 by default).

## Getting Started

### 1. Create a `docker-compose.yml` file
```yaml
version: '3.4'

services:
  ib_gateway:
    image: alphainsider/ib_gateway
    restart: always
    environment:
      TWS_USERID: ${TWS_USERID}
      TWS_PASSWORD: ${TWS_PASSWORD}
      TRADING_MODE: ${TRADING_MODE:-paper}
      VNC_SERVER_PASSWORD: ${VNC_SERVER_PASSWORD:-}
    ports:
      - '127.0.0.1:4001:4001'
      - '127.0.0.1:4002:4002'
      - '127.0.0.1:5900:5900'
```

### 2. Create a `.env` file in the same directory, or set the following environment variables globally:

| Variable            | Description                                | Default                |
| ------------------- | ------------------------------------------ | -----------------------|
| TWS_USERID          | The TWS user name.                         |                        |
| TWS_PASSWORD        | The TWS password.                          |                        |
| TRADING_MODE        | `live` or `paper`                          | paper                  |
| VNC_SERVER_PASSWORD | VNC server password. If not defined, no VNC server will be started. | not defined (VNC disabled) |

Example `.env` file:
```
TWS_USERID=username
TWS_PASSWORD=password
TRADING_MODE=paper
VNC_SERVER_PASSWORD=password
```

### 3. Run
```shell
$ docker compose up
```

After image is downloaded, container is started + 30s, the following ports will be available:

| Port | Description                                                |
| ---- | ---------------------------------------------------------- |
| 4001 | TWS API port for live accounts.                            |
| 4002 | TWS API port for paper accounts.                           |
| 5900 | When VNC_SERVER_PASSWORD was defined, the VNC server port. |

**Note:** Ports are only exposed on the user's host (127.0.0.1) and are not accessible outside the user's machine.

### 4. To Stop
Press `Ctrl`+`c` on your keyboard, or if you're running it in the background, run:
```shell
$ docker compose down
```

## Config

You can configure IB Gateway and IBC through their respective config files.

| App        | File       | Container Location   | Default                                                                                           |
|------------|------------|----------------------|---------------------------------------------------------------------------------------------------|
| IB Gateway | jts.ini    | /root/Jts/jts.ini    | [jts.ini](https://github.com/AlphaInsider/ib_gateway_docker/blob/master/config/ibgateway/jts.ini) |
| IBC        | config.ini | /root/ibc/config.ini | [config.ini](https://github.com/AlphaInsider/ib_gateway_docker/blob/master/config/ibc/config.ini) |   

To start the container with any changes you've made, put the updated files in your project's root directory and update `docker-compose.yml` with volumes mapping them in.

Example:
```yaml
version: '3.4'

services:
  ib_gateway:
    image: alphainsider/ib_gateway
    restart: always
    environment:
      TWS_USERID: ${TWS_USERID}
      TWS_PASSWORD: ${TWS_PASSWORD}
      TRADING_MODE: ${TRADING_MODE:-paper}
      VNC_SERVER_PASSWORD: ${VNC_SERVER_PASSWORD:-}
    ports:
      - '127.0.0.1:4001:4001'
      - '127.0.0.1:4002:4002'
      - '127.0.0.1:5900:5900'
    volumes:
      - ./jts.ini:/root/Jts/jts.ini
      - ./config.ini:/root/ibc/config.ini
```
## VNC IB Gateway
If you need to debug or change settings manually inside IB Gateway, you can use vnc to interact with IB Gateway GUI directly.

Steps:  
- Make sure a password is set for *VNC_SERVER_PASSWORD* in `.env`
- Spin everything up
```shell
$ docker compose up
```
- Wait 30 seconds
- Connect to the VNC server with the following details

| Setting     | Value                        |
|-------------|------------------------------|
| Server      | 127.0.0.1                    |
| Username    | admin                        |   
| Password    | (password you set in `.env`) |

**Note:** If you're still having issues connecting, try playing with the color depth settings.  
Remmina on Linux required color depth set to *16 bpp*.

## License

This project is licensed under the terms of the MIT license.  
The full license text is available in [LICENSE](https://github.com/AlphaInsider/ib_gateway_docker/blob/master/LICENSE).

The MIT License is a short and simple permissive license with conditions
only requiring preservation of copyright and license notices. Licensed works,
modifications, and larger works may be distributed under different terms 
and without source code.