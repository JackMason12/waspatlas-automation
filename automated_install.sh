port=3000 #port server will be hosted on
ip=localhost #ip server will be hosted on

base_dir="~/waspatlas_2/" #directory of website files

serv_script_dir="script/waspatlas_2_server_pl" #location of server script in base dir

db_dump_fn="wa2.sql" #name of database dump file
db_dump_dir="$base_dir$db_dump_fn" #path to the db dump file
db_sock_loc="/var/run/mysqld/mysqld.sock" #location of mysql socket
db_sock_loc_esc="\/var\/run\/mysqld\/mysqld.sock" #escaped for later command

perl_loc=$(which perl) #location of perl

perl_version="perl-5.28.0" #version of perl to install
perl_version_num="5.28.0"

perlbrew_installer="temp" #filename for perlbrew installer, gets deleted after use
perlbrew_url="https://raw.githubusercontent.com/gugod/App-perlbrew/master/perlbrew" #url for perlbrew

perl_local="perl5/perlbrew/"
src="etc/bashrc"
module_dir="perls/$perl_version/lib/$perl_version_num/"
perl_local_src="$perl_local$src" #local directory for sourcing our perl installation
perl_local_module_dir="$perl_local$module_dir"

cd ~ #make sure we are in home dir

echo "Running initial setup, please enter root password when prompted"
sudo ./initial_setup.sh

if [ -e $perlbrew_installer ] #if the perlbrew installer file already exists, remove it
then 
    rm %perlbrew_installer
fi

#download/install perlbrew and patchperl, then remove the installer, and add perlbrew to our PATH
rm $perlbrew_installer
touch $perlbrew_installer
chmod +rwx $perlbrew_installer
curl -f -Lo $perlbrew_installer $perlbrew_url
$perl_loc $perlbrew_installer self-install
$perl_loc $perlbrew_installer -f -q install-patchperl
rm $perlbrew_installer
source $perl_local_src

#make the "source" command above permanent by placing it in the bash launch 
if [ -e .bash_profile ]
then
    echo "source $perl_local_src" >> .bash_profile
elif [ -e .bash_login ]
then    
    echo "source $perl_local_src" >> .bash_login
elif [ -e .bashrc ]
then
    echo "source $perl_local_src" >> .bashrc
elif [ -e .profile ] 
then    
    echo "source $perl_local_src" >> .profile
fi



#install perl and cpanm using our new perlbrew installation
perlbrew -n install $perl_version
perlbrew switch $perl_version
perlbrew install-cpanm



#install waspatlas dependencies 1 at a time
cpanm Catalyst::Devel
cpanm Catalyst::Plugin::Redirect
cpanm Catalyst::Plugin::Session::State::Cookie
cpanm Catalyst::Plugin::Session::Store::File
cpanm Catalyst::Model::DBIC::Schema
cpanm Catalyst::View::TT
cpanm String::Random
cpanm String::Util
cpanm JSON
cpanm MooseX::NonMoose
cpanm Template::Plugin::ListUtil
cpanm DBD::mysql

$ndu = "NDU"
cp -r "$base_dir$ndu" $perl_local_module_dir

cpanm Catalyst::Engine::HTTP::Prefork --force
cpanm Catalyst::Engine::CGI --force



#Create the database and populate using the dump file
mysql -u lampuser -pchangeme -e "CREATE DATABASE wa2;"
mysql -u lampuser -pchangeme wa2 < wa2.sql
#fix the socket location
sed -i -e "s/\/db\/mysql\/mysql.sock/$db_sock_loc_esc/g" "$base_dir/lib/waspatlas_2/Model/wa2core.pm"



#launch the server script
CATALYST_ENGINE='HTTP::Prefork' "$base_dir$serv_script_dir" -h $ip -p $port
