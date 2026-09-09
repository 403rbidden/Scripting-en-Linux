#!/bin/bash
echo -e "\n----------------------------------------------------"
echo -e "Actualizador de wordlists y payloads de Pentesting"
echo "----------------------------------------------------"

actualizar() {
    local nombre="$1"
    local comando="$2"

    echo -e "\nActualizando ${nombre}:"
    if eval "$comando"; then
        echo "${nombre} se ha actualizado correctamente."
    else
        echo "No se ha podido actualizar ${nombre}."
    fi
}

actualizar "SecLists" "cd /usr/share/wordlists/seclists && sudo git pull"
actualizar "PayloadsAllTheThings" "cd /usr/share/wordlists/payloadsallthethings && sudo git pull"
actualizar "FuzzDB" "cd /usr/share/wordlists/fuzzdb && sudo git pull"
actualizar "subdomains.txt de Dnscan" "sudo wget -q https://raw.githubusercontent.com/rbsec/dnscan/master/subdomains.txt -O /usr/share/wordlists/dnscan/subdomains.txt"

echo -e "\n→ Proceso completado."
