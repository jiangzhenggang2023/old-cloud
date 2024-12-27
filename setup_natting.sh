if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run with sudo or as root."
    exit 1
fi
 
if [ $# -ne 2 ]; then
        echo -e "\nERROR: Wrong number of aguments"
        echo -e "\nUsage:\n\t$0 <WAN_if_name> <LAN_subnet>"
        echo -e "\nExample:\n\t$0 enp0s25 192.168.160.0/25\n\n"
        exit 1
fi
 
if ! dpkg -s "iptables-persistent" >/dev/null 2>&1; then
    echo "Installing iptables-persistent ..."
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
    apt install -y iptables-persistent
fi
 
if ! systemctl is-enabled netfilter-persistent >/dev/null 2>&1; then
    echo "Enabling netfilter-persistent service on system ..."
    systemctl enable netfilter-persistent
fi
 
echo "Enabling forwarding..."
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -i "$1" -d "$2" -j ACCEPT
iptables -A FORWARD -o "$1" -s "$2" -j ACCEPT
 
echo "Setting up Masquarading..."
iptables -t nat -A POSTROUTING -s "$2" ! -d "$2" -o "$1" -j MASQUERADE
 
echo "Saving forwarding rules ..."
touch /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-sysctl.conf
 
echo "Saving iptable rules ..."
iptables-save > /etc/iptables/rules.v4
 
echo "==================================="
ip r
echo "==================================="
 
exit 0
