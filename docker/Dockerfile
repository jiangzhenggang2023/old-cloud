FROM alpine:3.18
RUN apk --no-cache add \
    sudo \
    dnsmasq \
    nmap \
    nmap-scripts

ARG username=iotedge
ARG user_dir=/home/$username

RUN addgroup -S sudo && adduser -u 1000 -S $username -G sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Workaround for sudo error: https://gitlab.alpinelinux.org/alpine/aports/issues/11122
RUN echo 'Set disable_coredump false' >> /etc/sudo.conf

ADD entrypoint.sh $user_dir
ADD dnsmasq.template $user_dir/dnsmasq.template

USER $username
RUN mkdir $user_dir/dnsmasq.d
RUN mkdir $user_dir/tftp
WORKDIR $user_dir

# DNS Service Port
EXPOSE 53 53/UDP
# DHCP Service Port
EXPOSE 67 57/UDP
# TFTP Service Port
EXPOSE 69 69/UDP

ENTRYPOINT ["/bin/sh","entrypoint.sh"]
