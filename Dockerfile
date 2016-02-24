# Suricata
#
# VERSION               1.0
FROM      ubuntu
MAINTAINER Jon Schipp <jonschipp@gmail.com>

# Metadata
LABEL organization=oisf
LABEL program=suricata

# Specify container username e.g. training, demo
ENV VIRTUSER suricata

# Install dependencies
RUN apt-get update -qq
RUN apt-get install -yq software-properties-common vim nano htop tcpdump tshark wget gdb linux-tools-generic oinkmaster jq python --no-install-recommends
RUN apt-get -yq install libpcre3 libpcre3-dbg libpcre3-dev \
 build-essential autoconf automake libtool libpcap-dev libnet1-dev \
 libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 \
 make libmagic-dev libjansson-dev libjansson4 pkg-config --no-install-recommends

# Configure Suricata PPA
RUN add-apt-repository ppa:oisf/suricata-stable
RUN apt-get update -qq

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