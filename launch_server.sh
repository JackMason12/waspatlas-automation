base_dir="waspatlas_2/" #directory of website files

serv_script_dir="script/waspatlas_2_server.pl" #location of server script in base dir

ip=$2

port=$3

CATALYST_ENGINE='HTTP::Prefork' "$base_dir$serv_script_dir" -h $ip -p $port
