ARG ubuntu_codename=bionic

FROM ubuntu:${ubuntu_codename}

ENV DEBIAN_FRONTEND="noninteractive"
ARG ubuntu_codename=bionic

RUN echo "deb http://archive.ubuntu.com/ubuntu/ ${ubuntu_codename} main" > /etc/apt/sources.list &&\
    echo "deb http://archive.ubuntu.com/ubuntu/ ${ubuntu_codename}-updates main" >> /etc/apt/sources.list &&\
    cat /etc/apt/sources.list &&\
    apt-get update &&\
    apt-get install --yes --no-install-recommends \
    gnupg iproute2 iptables ifupdown iputils-ping make gcc cpp binutils dkms kmod &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://ppa.launchpad.net/wireguard/wireguard/ubuntu ${ubuntu_codename} main" > /etc/apt/sources.list.d/wireguard.list &&\
    echo "deb-src http://ppa.launchpad.net/wireguard/wireguard/ubuntu ${ubuntu_codename} main" >> /etc/apt/sources.list.d/wireguard.list &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E1B39B6EF6DDB96564797591AE33835F504A1A25 &&\
    apt-get update &&\
    apt-get install --yes --no-install-recommends wireguard linux-headers-$(uname -r) &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* &&\
    dkms uninstall wireguard/$(dkms status | awk -F ', ' '{ print $2 }')

COPY docker-entrypoint.sh /bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "run-server" ]