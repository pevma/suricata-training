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
 htop tcpdump tshark wget gdb linux-tools-generic git-core unzip \
 dnsutils net-tools iputils-ping curl jq python3 python3-scapy ethtool \
 build-essential make autoconf automake libtool clang flex bison \
 pkg-config wireshark-common g++-multilib python3-yaml jq clang-tools \
 python3-distutils-extra libmaxminddb-dev \
 --no-install-recommends
 
RUN apt-get update && apt-get install -yq libpcap-dev libcap-ng-dev libnetfilter-queue-dev \
 libpcre3-dev libpcre3 libpcre3-dbg \
 libnet1-dev libyaml-0-2 libyaml-dev zlib1g-dev \
 libmagic-dev libnss3-dev libnspr4-dev libjansson-dev \
 libgeoip-dev libluajit-5.1-dev libluajit-5.1-2 libluajit-5.1-common \
 lua5.3 libhiredis-dev libprelude-dev libnetfilter-log-dev \
 valgrind libdevel-gdb-perl libcapture-tiny-perl \
 libevent-dev liblzma-dev liblz4-dev libhyperscan-dev libhyperscan5 \
 rustc cargo \
 --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
 
#RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
#ENV PATH=/root/.cargo/bin:$PATH

RUN cargo install -f cbindgen --root /usr/
ENV PATH=/root/.cargo/bin:$PATH

RUN mkdir -p /opt/suricata-git/ && cd /opt/suricata-git/ && git clone  https://github.com/OISF/suricata.git && \
  cd suricata && \
  git clone https://github.com/OISF/libhtp.git -b 0.5.x &&  \
  git clone https://github.com/OISF/suricata-update.git suricataupdate-git && \
  mv suricataupdate-git/* suricata-update/ && \
  ./autogen.sh &&  \
  ./configure \
  --prefix=/opt/suricata-git/ --sysconfdir=/opt/suricata-git/etc --localstatedir=/opt/suricata-git/var   \
  --enable-hiredis --enable-nfqueue \
  --enable-geoip --enable-luajit  && \
  make clean &&  make -j3 && \
  make install-full && \
  ldconfig

RUN mkdir -p /opt/suricata-git-profiling/ && cd /opt/suricata-git-profiling/ && git clone  https://github.com/OISF/suricata.git && \
  cd suricata && \
  git clone https://github.com/OISF/libhtp.git -b 0.5.x &&  \
  git clone https://github.com/OISF/suricata-update.git suricataupdate-git && \
  mv suricataupdate-git/* suricata-update/ && \
  ./autogen.sh &&  \
  ./configure \
  --prefix=/opt/suricata-git-profiling/ --sysconfdir=/opt/suricata-git-profiling/etc --localstatedir=/opt/suricata-git-profiling/var   \
  --enable-hiredis --enable-nfqueue --enable-profiling --enable-profiling-locks \
  --enable-geoip --enable-luajit  && \
  make clean &&  make -j3 && \
  make install-full && \
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
RUN echo ":set nu" >> /etc/vim/vimrc
RUN echo "set linenumbers" >> /etc/nanorc

# Passwords
RUN echo "$VIRTUSER:$VIRTUSER" | chpasswd
RUN echo "root:suricata" | chpasswd

# Sudo
RUN usermod -aG sudo $VIRTUSER

# Environment
WORKDIR /home/$VIRTUSER
USER $VIRTUSER
