priv_to_grant="ALL"
loc_to_grant="*.*"

apt-get install -y  build-essential
apt-get install -y curl
apt-get install -y mysql-server
apt-get install -y libmysqlclient-dev
mysql -e "GRANT $priv_to_grant PRIVILEGES ON $loc_to_grant TO 'lampuser'@'localhost' IDENTIFIED BY 'changeme';"

sudo -k
