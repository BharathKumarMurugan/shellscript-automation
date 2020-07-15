#!/bin/bash
#
# Automate E-Commerce Application Deployment

function print_color(){
    case $1 in
        "green") COLOR="\033[0;32m"
            ;;
        "red") COLOR="\033[0;31m"
            ;;
        "*") COLOR="\033[0m"
            break
    esac
    NC="\033[0m"
    echo -e "${COLOR} $2 ${NC}"
}

# ------------ Deploy and Configure Database ------------
# Configuring FirewallD 
print_color "green" "Installing FirewallD..."
sudo yum install -y firewalld
sudo service firewalld start
sudo systemctl enable firewalld

# Installing MariabDB
print_color "green" "Installing MariaDB..."
sudo yum install -y mariadb-server
sudo service mariadb start
sudo systemctl enable mariadb

# Configuring DB port
print_color "green" "Configuring DB port..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

# Creating a DB USER
print_color "green" "Creating a DB USER..."
mysql <<-EOF
MariaDB > CREATE DATABASE ecomdb;
MariaDB > CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;
EOF

# Adding data to the Database
print_color "green" "Adding data to DB..."
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

mysql < db-load-script.sql


# ------------ Deploy and Configure Web ------------
# Installing httpd
sudo yum install -y httpd php php-mysql
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

# Configuring httpd -> pointing to the right index file
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start httpd service
sudo service httpd start
sudo systemctl enable httpd

# Clone the repository
sudo yum install -y git
git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

# Update index.php file that connects to the database
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

echo "All set."