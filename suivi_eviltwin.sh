#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

mainn(){
while true; do
    clear
    echo -e "${GREEN}[+] Capturation des connexions en temps réel ...${NC}"
    ip neigh | grep -i "REACHABLE" | awk -v cyan="$CYAN" -v red="$RED" -v nc="$NC" '{printf " Connexion : [IP sur le réseau] " cyan "%-15s" nc " [Adresse MAC] " red "%s" nc "\n", $1,$5}'
    sleep 1
done
}

close(){
    clear
}

trap close EXIT
mainn
