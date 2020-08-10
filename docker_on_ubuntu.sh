#!/bin/bash
#
# Installing Docker CE on Ubuntu Linux
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

#######################################
# Check whether the given service status.
# Globals:
#   is_service_active
# Arguments:
#   service name    .eg: firewalld, docker
#######################################
function check_service_active() {
    is_service_active=$(systemctl is-active $1)

    if [ $is_service_active = "active" ]; then
        print_color "green" "$1 service is active"
    else
        print_color "red" "$1 service is not active"
        exit 1
    fi
}

# Remove old version of docker if already installed
print_color "green" "Removing Old docker version..."
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update the apt-get repository
print_color "green" "Updating apt-get repository..."
sudo apt-get update -y

# Install required dependencies/packages for docker
print_color "green" "Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add docker GPG key
print_color "green" "Adding Docker GPG Key..."
check_gpg_key=$(curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -)

if [ $check_gpg_key != "OK" ]; then
	echo $(hostname -I | cut -d\ -f1) $(hostname) | sudo tee -a /etc/hosts
fi

# Print Docker FingerPrint
sleep 2
docker_fingerprint=$(sudo apt-key fingerprint 0EBFCD88 | grep "0EBF CD88")
print_color "green" "$docker_fingerprint"	

# Setup stable repository
print_color "green" "Setup Stable repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the apt-get repositoy
print_color "green" "Removing Old docker version..."
sudo apt-get update -y

# Install Docker CE (latest version)
print_color "green" "Installing Latest Docker Version..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

check_service_active docker

# Add the current user to Docker Group
print_color "green" "Creating a Docker group..."
sudo groupadd docker
print_color "green" "Adding current user to Docker group..."
sudo usermod -aG docker $USER

# Hello World - Docker container
print_color "green" "Executing Hello World Docker container"
docker run hello-world

print_color "green" "########################################################"
print_color "green" "## Installation Completed. Please Restart the machine ##"
print_color "green" "########################################################"
