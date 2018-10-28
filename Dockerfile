# Suricata
#
# VERSION               2.0
FROM ubuntu:latest
MAINTAINER Peter Manev <pmanev@oisf.net>

# Metadata
LABEL organization=oisf
LABEL program=suricata

# Specify container username e.g. training, demo
ENV VIRTUSER suricata
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get install -yq man-db software-properties-common vim nano screen tmux \
 htop tcpdump tshark wget gdb linux-tools-generic git-core \
 dnsutils net-tools iputils-ping curl jq python python-scapy ethtool coccinelle \
 build-essential make autoconf automake libtool clang flex bison \
 pkg-config wireshark-common g++-multilib python-yaml jq clang-tools \
 --no-install-recommends
 
RUN apt-get update && apt-get install -yq libpcap-dev libcap-ng-dev libnetfilter-queue-dev \
 libpcre3-dev libpcre3 libpcre3-dbg \
 libnet1-dev libyaml-0-2 libyaml-dev zlib1g-dev \
 libmagic-dev libnss3-dev libnspr4-dev libjansson-dev \
 libgeoip-dev libluajit-5.1-dev libluajit-5.1-2 libluajit-5.1-common \
 libhiredis-dev libprelude-dev libnetfilter-log-dev \
 valgrind libdevel-gdb-perl libcapture-tiny-perl \
 libevent-dev liblzma-dev liblz4-dev libhyperscan-dev libhyperscan4 \
 --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
 
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH=/root/.cargo/bin:$PATH

RUN mkdir -p /opt/suricata-git/ && cd /opt/suricata-git/ && git clone  https://github.com/OISF/suricata.git && \
  cd suricata && \
  git clone https://github.com/OISF/libhtp.git -b 0.5.x &&  \
  ./autogen.sh &&  \
  ./configure \
  --prefix=/opt/suricata-git/ --sysconfdir=/opt/suricata-git/etc --localstatedir=/opt/suricata-git/var   \
  --enable-hiredis --enable-nfqueue \
  --with-libnss-libraries=/usr/lib --with-libnss-includes=/usr/include/nss/ \
  --with-libnspr-libraries=/usr/lib --with-libnspr-includes=/usr/include/nspr \
  --enable-geoip --enable-luajit  && \
  make clean &&  make -j3 && \
  make install && \
  ldconfig

RUN mkdir -p /opt/suricata-git-profiling/ && cd /opt/suricata-git-profiling/ && git clone  https://github.com/OISF/suricata.git && \
  cd suricata && \
  git clone https://github.com/OISF/libhtp.git -b 0.5.x &&  \
  ./autogen.sh &&  \
  ./configure \
  --prefix=/opt/suricata-git-profiling/ --sysconfdir=/opt/suricata-git-profiling/etc --localstatedir=/opt/suricata-git-profiling/var   \
  --enable-hiredis --enable-nfqueue --enable-profiling --enable-profiling-locks \
  --with-libnss-libraries=/usr/lib --with-libnss-includes=/usr/include/nss/ \
  --with-libnspr-libraries=/usr/lib --with-libnspr-includes=/usr/include/nspr \
  --enable-geoip --enable-luajit  && \
  make clean &&  make -j3 && \
  make install && \
  ldconfig

# Configure Suricata
RUN add-apt-repository ppa:oisf/suricata-stable
RUN apt-get update -qq

#RUN apt-get update && apt-get -yd install suricata
RUN apt-get update && apt-get -y install suricata
COPY suricata.8.gz /usr/share/man/man8/

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# User configuration
RUN adduser --disabled-password --gecos "" $VIRTUSER

# Passwords
RUN echo "$VIRTUSER:$VIRTUSER" | chpasswd
RUN echo "root:suricata" | chpasswd

# Sudo
RUN usermod -aG sudo $VIRTUSER

# Environment
WORKDIR /home/$VIRTUSER
USER $VIRTUSER
