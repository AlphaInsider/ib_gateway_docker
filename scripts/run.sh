#!/bin/sh

export DISPLAY=:1

rm -f /tmp/.X1-lock
Xvfb :1 -ac -screen 0 1024x768x16 &

if [ -n "$VNC_SERVER_PASSWORD" ]; then
  echo "Starting VNC server"
  /root/scripts/run_x11_vnc.sh &
fi

/root/scripts/fork_ports_delayed.sh &

/root/ibc/scripts/ibcstart.sh "main" -g \
     "--tws-path=${TWS_PATH}" \
     "--ibc-path=${IBC_PATH}" \
     "--ibc-ini=${IBC_INI}" \
     "--user=${TWS_USERID}" \
     "--pw=${TWS_PASSWORD}" \
     "--mode=${TRADING_MODE:-paper}" \
     "--on2fatimeout=${TWOFA_TIMEOUT_ACTION}"
