#!/bin/bash

# ASCII art banner
echo "
@  
@         @#*#@  @@          
@    @@  @----%  @           @@           
@ @#----=----%   @          @@            
@%---------=@    @         @@
%---------*@    @@        @@ 
%-------=@      @        @   
%------#@       @       @@   
%----*+@ @@@    
%--=*+% @%%%@     @@@        
%-*++*@#===*+#++++#%*#@     @@@      #-=@ 
%#++#==+=--*+++++++++%%@            +---* 
@+**@@@@=#+=+++++++++#%*@          +-----@
@=+@@@@..=+++++*+++++++++@        *------@
@-*@@@@@%++#%%%#*##++++++++%     %-------@
@=-%@@@@#+%%%%%%%%**+++*+-+*@  @%--------@
@#+=-==-=*@%%%%%%%%*++*+---*% %*=-------* 
%#%#+=++++%%%%%%%%%*=+..@@=+@*+*-------=  
@*****=#%+*#%%%%@@**@=-#@@%*++*-------+@  
@-*%#==%****##++++=@@@@@@@%*+*-----++*@   
@#==#===+*****#%++-%@@@@@#=**-----%       
@++#=*#+=*===*#+.*+=====--#+------%       
@+=-===*+*++=++#**#**++=+%****#%@ @@      
@-=*==---=+==+*@*%#+*#*+++++#@@*+%#@      
@=#+------=-*%#**##++++++++++#++++#@      
@==------=+*+++++++++++++++++++++#+*@@@   
@-------++++++++++++++++++++++++*++##@    
@------=++++++++++++++++++*++++****@      
@-----=++++%@     @%+++++++%++++#++##@    
@----=++++@     #++#         
@---=++++@        @*@        
@-=+++++@       
@++++++@    ___            ___                           _                  
@+++++@    / __| _  _  ___|_ _| _ _   ___ _ __  ___  __ | |_  ___  _ _ 
@+++%      \__ \| || |(_-< | | | ' \ (_-<| '_ \/ -_)/ _||  _|/ _ \| '_|
@@@        |___/ \_, |/__/|___||_||_|/__/| .__/\___|\__| \__|\___/|_|
@                |__/                    |_| By 403rbidden                        
"

# Print colored messages
# ANSI color codes
printColoredMessage() {
  echo -e "\e[$1m$2\e[0m"
}

# ============================================
# Dracula Theme palette
# ============================================

DRACULA_BACKGROUND="38;2;40;42;54"
DRACULA_CURRENT_LINE="38;2;68;71;90"
DRACULA_FOREGROUND="38;2;248;248;242"
DRACULA_COMMENT="38;2;98;114;164"
DRACULA_CYAN="38;2;139;233;253"
DRACULA_GREEN="38;2;80;250;123"
DRACULA_ORANGE="38;2;255;184;108"
DRACULA_PINK="38;2;255;121;198"
DRACULA_PURPLE="38;2;189;147;249"
DRACULA_RED="38;2;255;85;85"
DRACULA_YELLOW="38;2;241;250;140"

set -u
set -o pipefail

printColoredMessage "$DRACULA_ORANGE" "This script requires privileged permissions to be executed."
printColoredMessage "$DRACULA_ORANGE" "Administrative privileges will be requested when required.\n"

read -r -p "Are you sure you want to continue? (y/n): " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [ "$response" != "y" ] && [ "$response" != "yes" ]; then
    printColoredMessage "$DRACULA_RED" "\nThe operation has been cancelled."
    exit 0
fi

if ! command -v sudo >/dev/null 2>&1; then
    printColoredMessage "$DRACULA_RED" "\n[ERROR] sudo is not installed."
    exit 1
fi

printColoredMessage "$DRACULA_PURPLE" "\n[*] Validating administrative privileges..."

if ! sudo -v; then
    printColoredMessage "$DRACULA_RED" "\n[ERROR] Administrative privileges could not be obtained."
    exit 1
fi

pathErrorFolder="$HOME/Documents/SysInspector_Error"
mkdir -p "$pathErrorFolder"

errorFile="$pathErrorFolder/SysInspector_$(date +"%d%m%Y_%H%M%S").log"
touch "$errorFile"

logMessage() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$errorFile"
}

successMessage() {
    printColoredMessage "$DRACULA_GREEN" "[OK] $1"
    logMessage "SUCCESS: $1"
}

errorMessage() {
    local command="$1"
    local exitCode="$2"
    local currentUser

    currentUser=$(whoami)

    {
        echo
        echo "User encountering the error: $currentUser"
        echo "Command: $command"
        echo "Exit code: $exitCode"
    } >> "$errorFile"

    printColoredMessage "$DRACULA_RED" "\n[ERROR] Errors occurred during execution."
    printColoredMessage "$DRACULA_RED" "Command: $command"
    printColoredMessage "$DRACULA_RED" "Exit code: $exitCode"
    printColoredMessage "$DRACULA_YELLOW" "Please check the error log in:"
    printColoredMessage "$DRACULA_CYAN" "$errorFile"

    exit "$exitCode"
}

runCommand() {
    local description="$1"
    shift

    printColoredMessage "$DRACULA_PURPLE" "\n[*] $description"
    logMessage "START: $description"
    logMessage "COMMAND: $*"

    "$@" 2>&1 | tee -a "$errorFile"
    local exitCode=${PIPESTATUS[0]}

    if [ "$exitCode" -ne 0 ]; then
        errorMessage "$*" "$exitCode"
    fi

    successMessage "$description"
}

printColoredMessage "$DRACULA_YELLOW" "\nWARNING!"
printColoredMessage "$DRACULA_COMMENT" "APT package operations can modify the system."
printColoredMessage "$DRACULA_COMMENT" "All command output will be displayed and stored in the execution log."

printColoredMessage "$DRACULA_CYAN" "\nInitializing system information verification:"

printColoredMessage "$DRACULA_PURPLE" "\n[*] Checking kernel version:"
uname -r | tee -a "$errorFile"

printColoredMessage "$DRACULA_PURPLE" "\n[*] Checking system information:"
if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a 2>/dev/null | tee -a "$errorFile"
else
    cat /etc/os-release | tee -a "$errorFile"
fi

printColoredMessage "$DRACULA_PURPLE" "\n[*] Checking system architecture:"
uname -m | tee -a "$errorFile"

runCommand "Updating package repositories" sudo apt-get update

printColoredMessage "$DRACULA_PURPLE" "\n[*] Listing upgradeable packages:"
apt list --upgradeable 2>/dev/null | tee -a "$errorFile"

runCommand "Configuring pending packages" sudo dpkg --configure -a
runCommand "Checking package dependencies" sudo apt-get check
runCommand "Performing full system upgrade" sudo apt-get full-upgrade -y
runCommand "Removing unused packages" sudo apt-get autoremove -y
runCommand "Cleaning package cache" sudo apt-get autoclean
runCommand "Performing final package integrity check" sudo apt-get check

printColoredMessage "$DRACULA_GREEN" "\n================================================="
printColoredMessage "$DRACULA_GREEN" " SysInspector completed successfully."
printColoredMessage "$DRACULA_GREEN" "================================================="

printColoredMessage "$DRACULA_CYAN" "\nExecution log:"
printColoredMessage "$DRACULA_FOREGROUND" "$errorFile"

logMessage "SysInspector completed successfully."

exit 0

