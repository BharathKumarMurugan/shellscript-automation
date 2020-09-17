#!/bin/bash
#
# Installing Python3 on Ubuntu Linux
# AUTHOR: Bharath Kumar
#
# -------------------------
# Operating System  : Ubuntu
# -------------------------

#######################################
# Prints colored text in the terminal.
# Globals:
#   COLOR
# Arguments:
#   COLOR       .eg: green, red
#######################################
function print_color() {
    case $1 in
    "green")
        COLOR="\033[0;32m"
        ;;
    "red")
        COLOR="\033[0;31m"
        ;;
    "*")
        COLOR="\033[0m"
        break
        ;;
    esac
    NC="\033[0m"
    echo -e "${COLOR} $2 ${NC}"
}


# Get user input for Python verison
read -p "Enter desired Python version (Ex: 3.8, 3.7) : " pyversion

print_color "green" "We are in the process of installing Python $pyversion verison, please wait..."

# Updating apt-get repository & Refreshing lists
print_color "green" "Updating apt-get repository & Refreshing lists..."
sudo apt-get update -y

# Installing Supporting software
print_color "green" "Installing Supporting software..."
sudo apt install -y software-properties-common

# Add Deadsnakes PPA
print_color "green" "Adding Deadsnakes PPA..."
sudo add-apt-repository ppa:deadsnakes/ppa

# Updating apt-get repository & Refreshing lists
print_color "green" "Updating apt-get repository & Refreshing lists..."
sudo apt-get update -y

# Installing Python
print_color "green" "Installing Python $pyversion verison..."
sudo apt install python$pyversion