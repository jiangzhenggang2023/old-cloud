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
    -i:             the interface need to be bind
    -s:             the min ip address for dhcp range
    -e:             the man ip address for dhcp range
    -a:             the address of localhost for commuticating with work node
    -n:             the domain name for tinkbell server
    -d:             enable DNS function
    -f:             enable ftp function
    -h:             help (optional)
EOF
}

while getopts 'i:s:e:a:n:dfh' flag; do
  case "${flag}" in
    i) export INTERFACE_BINDING="${OPTARG}" ;;
    s) export DHCP_MIN="${OPTARG}" ;;
    e) export DHCP_MAX="${OPTARG}" ;;
    a) export NETWORK_GATEWAY_IP="${OPTARG}" ;;
    n) export ORCH_SERVER_DOMAIN="${OPTARG}" ;;
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

    if [ -z $DNS_PORT ];then
        export DNS_PORT=0
        export DNS_COMMENT="# "
    else
        export DNS_COMMENT=""
    fi

    if [ -z $FTP_PORT ];then
        export TFTP_COMMENT="# "
    else
        export TFTP_COMMENT=""
    fi

    sed -e "s/{{DNS_PORT}}/$DNS_PORT/g; \
    s/{{TFTP_COMMENT}}/$TFTP_COMMENT/g ; \
    s/{{DNS_COMMENT}}/$DNS_COMMENT/g ; \
    s/{{INTERFACE_BINDING}}/$INTERFACE_BINDING/g ; \
    s/{{DHCP_MIN}}/$DHCP_MIN/g ; \
    s/{{DHCP_MAX}}/$DHCP_MAX/g ; \
    s/{{NETWORK_GATEWAY_IP}}/$NETWORK_GATEWAY_IP/g ; \
    s/{{ORCH_SERVER_DOMAIN}}/$ORCH_SERVER_DOMAIN/g ; " dnsmasq.template > dnsmasq.conf

    sudo dnsmasq --conf-file=/home/iotedge/dnsmasq.conf \
                --conf-dir=/home/iotedge/dnsmasq.d \
                -d \
                --log-dhcp \
                --log-queries=extra
}

main
