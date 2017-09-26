#!/bin/bash

THREADS="30"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

function print_ascii_art {
cat << "EOF"

		https://github.com/DanielTorres1

EOF
}


print_ascii_art


while getopts ":d:f:" OPTIONS
do
            case $OPTIONS in
            d)     DOMAIN=$OPTARG;;
            f)     FILE=$OPTARG;;
            ?)     printf "Opcion Invalida: -$OPTARG\n" $0
                          exit 2;;
           esac
done

DOMAIN=${DOMAIN:=NULL}
FILE=${FILE:=NULL}

##################
#  ~~~ Menu ~~~  #
##################

if [ $DOMAIN = NULL ] ; then

echo " USO: get-data.sh -d [dominio] -f [file]"
echo ""
exit
fi
######################


echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"
while read ip           
do               
    echo "Obteniendo datos de la ip: $ip"
    geodata=$(geoip.pl $ip)
    echo "$DOMAIN,$ip,,$geodata" >> geodata.csv
done <$FILE
