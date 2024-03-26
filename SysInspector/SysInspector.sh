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

# Warning message about script execution permissions
printColoredMessage "33" "This script requires privileged permissions to be executed."
printColoredMessage "33" "Please run it with execute permissions or as a user with administrative privileges.\n"

# Ask confirmation before proceeding
read -p "Are you sure you want to continue? (y/n): " response

# Set up a case-insensitive comparison
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

# Check if the response is affirmative
if [ "$response" != "y" ]; then
    printColoredMessage "31" "\nThe operation has been cancelled."
    exit 1
fi

# Folder where the error reports will be stored
pathErrorFolder=~/Documents/SysInspector_Error

# If the error report folder does not exist, create it
mkdir -p "$pathErrorFolder"

# Generate an error report file with the current date and time
errorFile="$pathErrorFolder/SysInspector_Error_$(date +"%d%m%Y_%H%M%S")"

# Create an empty error report file
touch "$errorFile"

# Display a warning about the instability of the apt CLI interface
printColoredMessage "33" "\nWARNING!"
printColoredMessage "33" "Apt does not have a stable CLI interface."
printColoredMessage "33" "You must use this script with caution."

# Initialize system information verification
printColoredMessage "32" "\nInitializing system information verification:"

# Function for success message
successMessage() {
  # Show a success message if there are no errors
  # Exit code == 0
  printColoredMessage "34" "\nThe task has been completed."
  # Remove the empty error file
  rm -f "$errorFile"
}

# Function for error message
errorMessage() {
  # Get the current user
  currentUser=$(whoami)
  
  # Add the user information to the error file
  echo -e "\nUser encountering the error: $currentUser" >> "$errorFile"
  
  # Show an error message during the execution
  # Exit code != 0
  printColoredMessage "31" "\nErrors occurred during the execution."
  # Show the location of the error file
  printColoredMessage "31" "Please check the error log in $errorFile"
  # Exit code == 1
  exit 1
}

# Update the package list
# Redirect errors to the file
if sudo apt update 2>> "$errorFile"; then
  successMessage
else
  errorMessage
fi

# Check kernel version
printColoredMessage "32" "\nChecking the kernel version:"
uname -r

# Check system information
printColoredMessage "32" "\nChecking the system information:"
lsb_release -a

# Perform system upgrade
printColoredMessage "32" "\nPerforming the system upgrade:"
sudo apt upgrade -y
if sudo apt update 2>> "$errorFile"; then
  successMessage
else
  errorMessage
fi

# Perform system autoremove
printColoredMessage "32" "\nPerforming the system cleanup:"
sudo apt autoremove -y
if sudo apt update 2>> "$errorFile"; then
  successMessage
else
  errorMessage
fi

# List upgradeable packages
printColoredMessage "32" "\nListing upgradeable packages:"
if apt list --upgradeable 2>> "$errorFile"; then
  successMessage
else
  errorMessage
fi

# Perform distribution upgrade
printColoredMessage "32" "\nPerforming distribution upgrade:"
if sudo apt dist-upgrade -y 2>> "$errorFile"; then
  successMessage
else
  errorMessage
fi

# Perform system autoremove after distribution upgrade
printColoredMessage "32" "\nPerforming system cleanup after distribution upgrade:"
if sudo apt autoremove -y 2>> "$errorFile"; then
  successMessage
  printColoredMessage "34" "\nGREAT!"
  printColoredMessage "34" "The system update and optimization have been completed successfully."
else
  errorMessage
fi

# Check if the error folder is empty and remove it
if [ -z "$(ls -A "$pathErrorFolder")" ]; then
  rmdir "$pathErrorFolder"
fi
