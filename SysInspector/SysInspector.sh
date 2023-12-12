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

# Function to print colored messages with ANSI color codes
printColoredMessage() {
  echo -e "\e[$1m$2\e[0m"
}

# Print a warning message about script execution permissions
printColoredMessage "33" "This script requires privileged permissions to be executed."
printColoredMessage "33" "Please, run it with execute permissions or as a user with administrative privileges.\n"

# Ask for user confirmation before proceeding
read -p "Are you sure you want to continue? (y/n): " response

# Set up a case-insensitive comparison
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

# Check if the response is affirmative
if [ "$response" != "y" ]; then
    printColoredMessage "31" "\nThe operation has been cancelled."
    exit 1
fi

# Folder where the system error reports will be stored
pathErrorFolder=~/Documents/SysInspector_Error

# Check if the error report folder exists; if not, create it
mkdir -p "$pathErrorFolder"

# Generate an error report file based on the current date and time
errorFile="$pathErrorFolder/SysInspector_Error_$(date +"%d%m%Y_%H%M%S")"

# Create an empty error report file
touch "$errorFile"

# Initialize system information verification
printColoredMessage "32" "\nInitializing system information verification:"

# Update the package list
sudo apt update

# Display a warning about the instability of apt CLI interface
printColoredMessage "33" "\nWARNING!"
printColoredMessage "33" "Apt does not have a stable CLI interface."
printColoredMessage "33" "You must use this script with caution."

# Check kernel version
printColoredMessage "32" "\nChecking the kernel version:"
uname -r

# Check system information
printColoredMessage "32" "\nChecking the system information:"
lsb_release -a

# Perform system upgrade
printColoredMessage "32" "\nPerforming the system upgrade:"
sudo apt upgrade -y

# Perform system autoremove
printColoredMessage "32" "\nPerforming the system autoremove:"
sudo apt autoremove -y

# List upgradeable packages
printColoredMessage "32" "\nListing the upgradeable packages:"
apt list --upgradeable

# Perform distribution upgrade
printColoredMessage "32" "\nPerforming the distribution upgrade:"
sudo apt dist-upgrade -y

# Perform system autoremove after distribution upgrade
printColoredMessage "32" "\nPerforming the system autoremove after distribution upgrade:"
sudo apt autoremove -y

# Check if there were any errors during the execution
if [ -s "$errorFile" ]; then
  # Display an error message if there are errors
  printColoredMessage "31" "\nErrors occurred during the execution."
  printColoredMessage "31" "Please, check the error log in $errorFile"
else
  # Display a success message if there are no errors
  printColoredMessage "34" "\nThe system update and optimization has been completed successfully!"
  # Remove the empty error file
  rm -f "$errorFile"

  # Check if the error folder is empty and remove it
  if [ -z "$(ls -A "$pathErrorFolder")" ]; then
    rmdir "$pathErrorFolder"
  fi
fi
