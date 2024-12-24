#!/bin/sh


usage() {
    cat >&2 <<EOF
Purpose:
Provide DNS/DHCP/FTP function.

Usage:
$(basename "$0")

ex:
./entrypoint.sh -i eno1
./entrypoint.sh -d
./entrypoint.sh -d -f

Options:
    -O:             only save tftp function
    -r:             remote fm server address(server name or ip address)
    -R:             the dhcp range(eg: 1.1.1.1,1.1.1.255)
    -g:             the gateway address
    -b:             the broadcast address
    -i:             the interface need to be bind
    -n:             the domain name for tinkbell server
    -d:             enable DNS function
    -D:             DNS server address
    -f:             enable ftp function
    -h:             help (optional)
EOF
}

while getopts 'i:r:R:g:b:n:D:Odfh' flag; do
  case "${flag}" in
    O) export ONLY_TFTP="only" ;;
    r) export REMOTE_PXE_SERVER="$(echo ${OPTARG} | tr -d ' ')" ;;
    R) export DHCP_RANGE="$(echo ${OPTARG} | tr -d ' ')" ;;
    g) export NETWORK_GATEWAY_IP="$(echo ${OPTARG} | tr -d ' ')" ;;
    b) export NETWORK_BROADCAST_IP="$(echo ${OPTARG} | tr -d ' ')" ;;
    i) export INTERFACE_BINDING="$(echo ${OPTARG} | tr -d ' ')" ;;
    n) export ORCH_SERVER_DOMAIN="$(echo ${OPTARG} | tr -d ' ')" ;;
    D) export DNS_ADDRESS="$(echo ${OPTARG} | tr -d ' ')" ;;
    d) export DNS_PORT=53 ;;
    f) export FTP_PORT=69 ;;
    h) HELP='true' ;;
    *) HELP='true' ;;
  esac
done

if [ $HELP ]; then
    usage
    exit 1
fi


main() {
    # download EFI file
    ip=$(cat /home/iotedge/tftp/.ip)
    wget http://${ip}:8080/signed_ipxe.efi -O /home/iotedge/tftp/signed_ipxe.efi


    DNS_PORT
    TFTP_COMMENT
    INTERFACE_COMMENT
    DHCP_COMMENT
    DNS_PORT
    FTP_PORT
    DHCP_RANGE
    ORCH_SERVER_DOMAIN



    if [ ! -z $ONLY_TFTP ];then
        export TFTP_COMMENT=""
        export DNS_PORT=0
        export INTERFACE_COMMENT="# "
        export DHCP_COMMENT="# "
        sed -e "s/{{DNS_PORT}}/$DNS_PORT/g; \
        s/{{TFTP_COMMENT}}/$TFTP_COMMENT/g ; \
        s/{{INTERFACE_COMMENT}}/$INTERFACE_COMMENT/g ; \
        s/{{DHCP_COMMENT}}/$DHCP_COMMENT/g ; " dnsmasq.template > dnsmasq.conf
    else
        if [ -z $DNS_PORT ];then
            export DNS_PORT=0
        else
            export DNS_COMMENT=""
        fi

        if [ -z $FTP_PORT ];then
            export TFTP_COMMENT="# "
        else
            export TFTP_COMMENT=""
        fi

        export DHCP_COMMENT=""
        export INTERFACE_COMMENT=""

        NETWORK_DHCP_RANGE="$DHCP_RANGE,6h"
        # NETWORK_DNS_PRIMARY=$()
        # NETWORK_DNS_SECONDARY=$()

        sed -e "s/{{DNS_PORT}}/$DNS_PORT/g ; \
        s/{{TFTP_COMMENT}}/$TFTP_COMMENT/g ; \
        s/{{INTERFACE_COMMENT}}/$INTERFACE_COMMENT/g ; \
        s/{{DHCP_COMMENT}}/$DHCP_COMMENT/g ; \

        s/{{INTERFACE_BINDING}}/$INTERFACE_BINDING/g ; \
        s/{{DHCP_RANGE}}/$NETWORK_DHCP_RANGE/g ; \
        s/{{NETWORK_GATEWAY_IP}}/$NETWORK_GATEWAY_IP/g ; \
        s/{{NETWORK_DNS_ADDRESS}}/$DNS_ADDRESS/g ; \
        s/{{NETWORK_BROADCAST_IP}}/$NETWORK_BROADCAST_IP/g ; \
        s/{{REMOTE_PXE_SERVER}}/,,$REMOTE_PXE_SERVER/g ; \

        s/{{ORCH_SERVER_DOMAIN}}/$ORCH_SERVER_DOMAIN/g ; " dnsmasq.template > dnsmasq.conf
    fi

    sudo dnsmasq --conf-file=/home/iotedge/dnsmasq.conf \
                --conf-dir=/home/iotedge/dnsmasq.d \
                -d \
                --log-dhcp \
                --log-queries=extra
}

main
