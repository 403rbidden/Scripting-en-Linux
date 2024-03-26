#!/bin/bash

# -----------------------------------------------------------------------------------------
# Nessus Installation Script:
# Automates the installation and configuration of Nessus on Ubuntu and Debian systems.
# The program checks if Nessus is already installed and skips installation if it is.
# https://www.tenable.com/downloads/nessus
#
# Author: MJ Ocaña (403bidden)
# Date: 2024/03/27
# -----------------------------------------------------------------------------------------

# Print colored messages
# ANSI color codes: (31) red - (33) yellow -(34) blue

printColoredMessage() {
  echo -e "\e[$1m$2\e[0m"
}

echo -e "\n"
echo "-----------------------------------------------------------"
echo " __    _   _______   _______   _______   __   __   _______ "
echo "|  |  | | |       | |       | |       | |  | |  | |       |"
echo "|   |_| | |    ___| |  _____| |  _____| |  | |  | |  _____|"
echo "|       | |   |___  | |_____  | |_____  |  |_|  | | |_____ "
echo "|  _    | |    ___| |_____  | |_____  | |       | |_____  |"
echo "| | |   | |   |___   _____| |  _____| | |       |  _____| |"
echo "|_|  |__| |_______| |_______| |_______| |_______| |_______|"
echo -e "                   Automates the installation and ejecution"
echo "                                              By 403rbidden"
echo -e "-----------------------------------------------------------\n"

# Check if Nessus is already installed
if dpkg -l | grep -qw nessus; then
    printColoredMessage "33" "/!\ Nessus is already installed in the system.\n"
else
    echo -e "Searching for Nessus installation package...\n"

    # Finding the Nessus installation package (.deb file)
    nessus_package=$(find / -name "Nessus-*.deb" 2>/dev/null | head -n 1)

    if [[ -z "$nessus_package" ]]; then
        printColoredMessage "31" "Nessus installation package not found. Please, ensure the Nessus .deb file is downloaded.\n"
        exit 1
    else
        echo -e "Nessus installation package found: $nessus_package \n"
    fi

    echo -e "Starting Nessus installation.\n"

    # Installing Nessus from the found .deb package
    sudo dpkg -i "$nessus_package"

    # Checking if the installation was successful
    if [ $? -eq 0 ]; then
        echo -e "Nessus installation completed successfully.\n"
    else
        printColoredMessage "31" "Nessus installation failed. Please, check the errors and try again.\n"
        exit 1
    fi
fi

# Starting the Nessus service
echo -e "Starting the Nessus service...\n"
sudo /bin/systemctl start nessusd.service

# Checking if the service started correctly
if [ $? -eq 0 ]; then
    echo -e ":) Nessus service started successfully.\n"
else
    printColoredMessage "31" ":( Failed to start the Nessus service. Please, check the errors and try again.\n"
    exit 1
fi

# Fetching the hostname of the system
hostname=$(hostname)

# Final instructions for the user, using the hostname for the web address
printColoredMessage "34" "Please, to open the Nessus scanner go to ---> https://$hostname:8831/"
