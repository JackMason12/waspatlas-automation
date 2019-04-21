apt-get remove --purge -y build-essential
apt-get remove --purge -y curl
apt-get remove --purge -y mysql-server
apt-get remove --purge -y libmysqlclient-dev
apt-get autoremove -y
rm -R perl5
rm -R .cpanm
rm -R .mysql_history
sed -i '/source perl5\/perlbrew\/etc\/bashrc/d' ./.profile
sudo -k
