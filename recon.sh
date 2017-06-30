#!/bin/bash

THREADS="30"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

function print_ascii_art {
cat << "EOF"
 _______  _______  _______  _______  _       
(  ____ )(  ____ \(  ____ \(  ___  )( (    /|
| (    )|| (    \/| (    \/| (   ) ||  \  ( |
| (____)|| (__    | |      | |   | ||   \ | |
|     __)|  __)   | |      | |   | || (\ \) |
| (\ (   | (      | |      | |   | || | \   |
| ) \ \__| (____/\| (____/\| (___) || )  \  |
|/   \__/(_______/(_______/(_______)|/    )_)                                             

		daniel.torres@owasp.org
		https://github.com/DanielTorres1

EOF
}


print_ascii_art


while getopts ":d:" OPTIONS
do
            case $OPTIONS in
            d)     DOMAIN=$OPTARG;;
            #o)     OUTPUT=$OPTARG;;
            ?)     printf "Opcion Invalida: -$OPTARG\n" $0
                          exit 2;;
           esac
done

DOMAIN=${DOMAIN:=NULL}

##################
#  ~~~ Menu ~~~  #
##################

if [ $DOMAIN = NULL ] ; then

echo " USO: recon.sh -d [dominio]"
echo ""
exit
fi
######################

mkdir $DOMAIN
cd $DOMAIN

mkdir dns
mkdir mail
mkdir report

####################  DNS test ########################
echo -e "$OKBLUE+ -- --=############ Reconocimiento DNS  ... #########$RESET"

cd dns
echo -e "\t[+] Iniciando dnsrecon .."
dnsrecon -d $DOMAIN --lifetime 60 > dnsrecon.txt &

echo -e "\t[+] Iniciando fierce .."
fierce -dns $DOMAIN -threads 3 > fierce.txt &

echo -e "\t[+] Iniciando dnsenum .."
dnsenum $DOMAIN --nocolor > dnsenum.txt &
cd ../



##################### Emails, subdomains #################

echo -e "$OKBLUE+ -- --=############ Obteniendo  correos,subdominios, etc ... #########$RESET"
echo -e "\t[+] Iniciando whois .."
whois $DOMAIN > report/whois.txt

echo -e "\t[+] Iniciando theharvester .."
echo -e "\t\t[+] Buscando correos en google .."
theharvester -d $DOMAIN -b google > mail/theharvester-google.txt 2>/dev/null
echo -e "\t\t[+] Buscando correos en bing .."
theharvester -d $DOMAIN -b bing > mail/theharvester-bing.txt 2>/dev/null
echo -e "\t\t[+] Buscando personal en linkedin .."
theharvester -d $DOMAIN -b linkedin > report/linkedin.txt 2>/dev/null


echo -e "\t[+] Iniciando infoga .."

infoga.sh -t $DOMAIN -s all > mail/infoga2.txt 2>/dev/null
sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" mail/infoga2.txt > mail/infoga.txt
rm mail/infoga2.txt 

#################

echo -e "$OKBLUE+ -- --=############ Probando si se puede spoofear el dominio #########$RESET"

spoofcheck.sh $DOMAIN > report/dns-spoof.txt


############### check if the fierce is active
while true; do
		nmap_instances=`ps aux | grep perl | wc -l`
			if [ "$nmap_instances" -gt 1 ]
		then
			echo "Enemeracion DNS aun activa"  
			sleep 30
		else
			break		  		 
		fi				
done


echo -e "$OKBLUE+ -- --=############ Recopilando informacion ... #########$RESET"

#dns
cd dns
grep $DOMAIN dnsenum.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdomains.txt
echo "Terminando Fierce .."
sleep 50
grep --color=never "\.$DOMAIN" fierce.txt | awk '{print $1,$2}' | tr ' ' ','  >> subdomains.txt
cd ..

#mails
cat mail/theharvester-google.txt | grep --color=never @ | grep -v edge-security >>mail/all-mails.txt
cat mail/theharvester-bing.txt | grep --color=never @ | grep -v edge-security >>mail/all-mails.txt
cat mail/infoga.txt | grep --color=never "Email:" | cut -d " " -f3 >>mail/all-mails.txt

lines=`wc -l mail/all-mails.txt | cut -d " " -f1`
perl -E "say \"$DOMAIN\n\" x $lines" > mail/domain.txt # file with the domain (n times)
sed -i '$ d' mail/domain.txt # delete last line
paste -d ',' mail/domain.txt mail/all-mails.txt > report/mails1.csv 

cat report/mails1.csv | sort | uniq > report/mails.csv 
rm report/mails1.csv


#subdomains
cat mail/theharvester-google.txt | grep --color=never $DOMAIN | grep -v @ >> dns/subdomains.txt
cat mail/theharvester-bing.txt| grep --color=never $DOMAIN | grep -v @ >> dns/subdomains.txt
cat dns/subdomains.txt | sort | uniq -i > dns/subdomains2.txt 
cp dns/subdomains2.txt subdomains.txt

sed -i "s/$DOMAIN./$DOMAIN/g" subdomains.txt
sed -i "s/:/,/g" subdomains.txt
sort subdomains.txt | uniq > subdomains2.txt
cat subdomains2.txt  | egrep -v '\--|Testing|Trying|DNS' > subdomains3.txt


echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"
while read line           
do           
    subdomain=$(echo  $line | cut -d "," -f2)
    echo "Obteniendo datos del subdominio: $subdomain"
    geodata=$(geoip.pl $subdomain)
    echo "$DOMAIN,$line,$geodata" >> report/subdomains.csv
done <subdomains3.txt 


rm subdomains.txt
rm subdomains2.txt
rm subdomains3.txt	

#rm mail/theharvester-google.txt
#rm mail/bing.txt

#echo "Iniciando dmitry ... "
#dmitry -wnspb $DOMAIN -o mail/resultado_dmitry

######################################################
