#!/bin/bash

# Function to display status messages
function status {
    echo "====================================="
    echo "$1"
    echo "====================================="
}

# Set default MySQL root password (if required)
MYSQL_ROOT_PASSWORD="your_root_password"

# Step 1: Update the package list
status "Updating package list..."
sudo apt update

# Step 2: Install required packages for web applications
status "Installing Apache, PHP, MySQL, and required modules..."
sudo apt install apache2 php php-mysqli git curl -y

# Step 3: Install MariaDB server (or MySQL)
status "Installing MariaDB..."
sudo apt install mariadb-server -y

# Start MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MySQL installation (optional)
status "Securing MySQL..."
sudo mysql_secure_installation <<EOF

y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
y
y
y
y
EOF

# Step 4: Install DVWA (Damn Vulnerable Web Application)
status "Cloning and setting up DVWA..."
sudo git clone https://github.com/digininja/DVWA.git /var/www/html/dvwa
cd /var/www/html/dvwa
sudo cp config/config.inc.php.dist config/config.inc.php
sudo chown -R www-data:www-data /var/www/html/dvwa

# Set up DVWA database
status "Setting up DVWA database..."
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE dvwa;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Step 5: Install bWAPP (Buggy Web Application)
status "Cloning and setting up bWAPP..."
sudo git clone https://github.com/samuraiwtf/bWAPP.git /var/www/html/bwapp
cd /var/www/html/bwapp
sudo mv admin/settings.php /var/www/html/bwapp/admin/settings.php
sudo chown -R www-data:www-data /var/www/html/bwapp

# Set up bWAPP database
status "Setting up bWAPP database..."
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE bwapp;
CREATE USER 'bwapp'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON bwapp.* TO 'bwapp'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Step 6: Install OWASP Juice Shop
status "Installing OWASP Juice Shop..."
sudo mkdir /var/www/html/juice-shop
cd /var/www/html/juice-shop
sudo curl -LO https://github.com/bkimminich/juice-shop/releases/download/v14.1.0/juice-shop-14.1.0_node10_linux_x64.tgz
sudo tar xzf juice-shop-14.1.0_node10_linux_x64.tgz --strip-components=1
cd juice-shop && sudo npm install --only=prod

# Set permissions
sudo chown -R www-data:www-data /var/www/html/juice-shop

# Step 7: Install Mutillidae
status "Cloning and setting up Mutillidae..."
sudo git clone https://github.com/webpwnized/mutillidae.git /var/www/html/mutillidae
cd /var/www/html/mutillidae
sudo chown -R www-data:www-data /var/www/html/mutillidae

# Set up Mutillidae database
status "Setting up Mutillidae database..."
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE mutillidae;
CREATE USER 'mutillidae'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON mutillidae.* TO 'mutillidae'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Step 8: Restart Apache to apply changes
status "Restarting Apache..."
sudo systemctl restart apache2

# Step 9: Final instructions
status "All vulnerable applications are now installed!"
echo "Access the following applications via your web browser:"
echo "  - DVWA: http://localhost/dvwa"
echo "  - bWAPP: http://localhost/bwapp"
echo "  - OWASP Juice Shop: http://localhost:3000"
echo "  - Mutillidae: http://localhost/mutillidae"
echo "Complete the setup for each application via their respective web interfaces."
