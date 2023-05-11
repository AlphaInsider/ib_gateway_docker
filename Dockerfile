FROM ubuntu:20.04

ARG IBC_SOURCE=https://github.com/IbcAlpha/IBC/releases/download/3.16.2/IBCLinux-3.16.2.zip

# install dependencies
RUN apt-get update -y
RUN apt-get install --no-install-recommends --yes \
    curl \
    ca-certificates \
    unzip \
    dos2unix \
    xvfb \
    libxslt-dev \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libgtk2.0-bin \
    socat \
    x11vnc

# set working directory
WORKDIR /tmp/setup

# install IB Gateway
COPY ./assets/ibgateway-*.sh ./ibgateway-standalone-linux-x64.sh
RUN chmod a+x ./ibgateway-standalone-linux-x64.sh
RUN ./ibgateway-standalone-linux-x64.sh -q -dir /root/Jts/ibgateway/main
COPY ./config/ibgateway/jts.ini /root/Jts/jts.ini

# install IBC
RUN curl -sSL ${IBC_SOURCE} --output IBCLinux.zip
RUN mkdir /root/ibc
RUN unzip ./IBCLinux.zip -d /root/ibc
RUN chmod -R u+x /root/ibc/*.sh
RUN chmod -R u+x /root/ibc/scripts/*.sh
COPY ./config/ibc/config.ini /root/ibc/config.ini

# copy scripts
COPY ./scripts /root/scripts
RUN find /root/scripts -name "*.sh" -type f -exec dos2unix {} \;
RUN chmod a+x /root/scripts/*.sh

# cleanup
RUN rm -r /tmp/setup

# set working directory
WORKDIR /root

# IBC env vars
ENV TWS_PATH /root/Jts
ENV IBC_PATH /root/ibc
ENV IBC_INI /root/ibc/config.ini
ENV TWOFA_TIMEOUT_ACTION exit

# run script
CMD ["/root/scripts/run.sh"]