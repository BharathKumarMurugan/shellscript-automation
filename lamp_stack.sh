#!/bin/bash
#
# Automate E-Commerce Application Deployment
# AUTHOR: Bharath Kumar
#
# LAMP STACK COMPONENTS
# -------------------------
# Operating System  : CentOS
# Apache Web server : Apache httpd
# Database          : MariaDB
# Scripting Language: PHP
# -------------------------
# Database Name     : ecomdb
# Database Username : bharath
# Database Password : ecompassword
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
#   service name    .eg: firewalld, mariadb
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

#######################################
# Check for the given Port Number configration in firewall.
# Globals:
#   firewalld_port
# Arguments:
#   port number     .eg: 80, 3306
#######################################
function is_firewalld_port_configured() {
    firewalld_port=$(sudo firewall-cmd --list-all --zone=public | grep ports)

    if [[ $firewalld_port = *$1* ]]; then
        print_color "green" "Port $1 is configured"
    else
        print_color "red" "Port $1 is not configured"
        exit 1
    fi
}

#######################################
# Check for the given item in the webpage.
# Arguments:
#   output of curl, item name       .eg: Laptop, Drone, VR
#######################################
function check_webpage_for_item() {
    if [[ $1 = *$2* ]]; then
        print_color "green" "Item $2 is present in the webpage"
    else
        print_color "green" "Item $2 is not present in the webpage"
    fi
}

# ------------ Deploy and Configure Database ------------
# Configuring FirewallD
print_color "green" "Installing FirewallD..."
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld
sleep 5

check_service_active firewalld

# Installing MariabDB
print_color "green" "Installing MariaDB..."
sudo yum install -y mariadb-server
sudo service mariadb start
sudo systemctl enable mariadb
sleep 5

check_service_active mariadb

# Configuring DB port to firewall
print_color "green" "Configuring DB port..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_port_configured 3306

# Creating a DB USER
print_color "green" "Creating a DB USER..."
cat >configure-db.sql <<-EOF
CREATE DATABASE IF NOT EXISTS ecomdb;
CREATE USER 'bharath'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'bharath'@'localhost';
FLUSH PRIVILEGES;
EOF

sudo mysql <configure-db.sql

# Adding data to the Database
print_color "green" "Adding data to DB..."
cat >db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

sudo mysql <db-load-script.sql

mysql_db_result=$(sudo mysql -e "use ecomdb; SELECT * FROM products;")

if [[ $mysql_db_result = *Laptop* ]]; then
    print_color "green" "Inventory data is loaded"
else
    print_color "red" "Inventory data is not loaded"
fi

# ------------ Deploy and Configure Web ------------
# Installing httpd
sudo yum install -y httpd php php-mysql
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_port_configured 80

# Configuring httpd -> pointing to the right index file
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start httpd service
sudo service httpd start
sudo systemctl enable httpd

check_service_active httpd

# Clone the repository
sudo yum install -y git
sudo git clone https://github.com/BharathKumarMurugan/sample-php-ecomm-app.git /var/www/html/

# Update index.php file that connects to the database
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

echo "All set."

web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch; do
    check_webpage_for_item "$web_page" $item
done
