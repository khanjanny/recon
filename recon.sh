#!/bin/bash

THREADS="30"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

#https://github.com/Ice3man543/subfinder
#https://github.com/daudmalik06/ReconCat
#https://github.com/mobrine-mob/M0B-tool-v2
#https://github.com/m8r0wn/pymeta
#https://github.com/GerbenJavado/LinkFinder
#https://github.com/Ice3man543/SubOver
#https://github.com/franccesco/getaltname
#https://github.com/twelvesec/gasmask

# Cloud
#https://github.com/MindPointGroup/cloudfrunt
#https://github.com/glen-mac/goGetBucket
#https://github.com/yehgdotnet/S3Scanner

#WEB
#https://github.com/drego85/JoomlaScan
#https://github.com/MrSqar-Ye/BadMod
#https://www.kitploit.com/2018/04/jcs-joomla-vulnerability-component.html
#https://github.com/steverobbins/magescan
#https://github.com/fgeek/pyfiscan
#https://github.com/vortexau/mooscan
#https://github.com/vortexau/mooscan
#https://github.com/retirejs/retire.js/
#https://github.com/UltimateHackers/XSStrike
#https://whatcms.org/Content-Management-Systems
#https://github.com/m4ll0k/WPSeku
#https://github.com/Jamalc0m/wphunter
#https://github.com/rezasp/joomscan
#https://github.com/m4ll0k/WAScan


#https://www.kitploit.com/2018/04/pymeta-search-web-for-files-on-domain.html
#https://github.com/peterpt/eternal_check
#https://www.kitploit.com/2018/04/nix-auditor-nix-audit-made-easier-rhel.html

# mobile app
#https://github.com/UltimateHackers/Diggy
#https://github.com/Security-Onion-Solutions/security-onion

#Vuln app
#https://github.com/vegabird/xvna  vuln site
#https://github.com/logicalhacking/DVHMA

#other
#https://github.com/m4ll0k/iCloudBrutter
#https://github.com/Moham3dRiahi/XBruteForcer
#https://github.com/hc0d3r/sudohulk
#https://github.com/floriankunushevci/aragog
#https://github.com/mthbernardes/ipChecker
#https://www.kitploit.com/2018/02/roxysploit-penetration-testing-suite.html
#https://github.com/1N3/IntruderPayloads/tree/master/FuzzLists
#https://www.kitploit.com/2018/02/meterpreter-paranoid-mode-meterpreter.html
#https://www.kitploit.com/2018/02/grouper-powershell-script-for-helping.html
#https://github.com/B16f00t/whapa

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
mkdir correo
mkdir reporte

echo -e "$OKORANGE+ -- --=############ Usando servidor DNS  ... #########$RESET"
grep nameserver /etc/resolv.conf
echo ""
####################  DNS test ########################
echo -e "$OKBLUE+ -- --=############ Reconocimiento DNS  ... #########$RESET"

cd dns
echo -e "\t[+] Iniciando dnsrecon (DNS info) .."
dnsrecon -d $DOMAIN --lifetime 60  > dnsrecon.txt &

echo -e "\t[+] Iniciando fierce (Volcado de zona) .."
fierce -dns $DOMAIN -threads 3 > fierce.txt &

echo -e "\t[+] Iniciando CTFR ( Certificate Transparency logs) .."
ctfr.sh -d $DOMAIN > ctfr.txt
cd ../



##################### Ecorreos, subdominios #################

echo -e "$OKBLUE+ -- --=############ Obteniendo  correos,subdominios, etc ... #########$RESET"
echo -e "\t[+] Iniciando whois .."
whois $DOMAIN > reporte/whois.txt

echo -e "\t[+] Iniciando theharvester .."
echo -e "\t\t[+] Buscando correos en google .."
theharvester -d $DOMAIN -b google > correo/theharvester-google.txt 2>/dev/null
echo -e "\t\t[+] Buscando correos en bing .."
theharvester -d $DOMAIN -b bing > correo/theharvester-bing.txt 2>/dev/null


echo -e "\t[+] Iniciando infoga .."

infoga.sh -t $DOMAIN -s all > correo/infoga2.txt 2>/dev/null
sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" correo/infoga2.txt > correo/infoga.txt
rm correo/infoga2.txt 


#################

echo -e "$OKBLUE+ -- --=############ Probando si se puede spoofear el dominio #########$RESET"

spoofcheck.sh $DOMAIN > reporte/dns-spoof.txt


echo -e "$OKBLUE+ -- --=############ Recopilando informacion ... #########$RESET"

######## DNS ###
cd dns

# fierce
egrep -i "SOA" fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then # Si se hizo volcado de zona	
	echo -e "$OKRED Volcado de zona !! $RESET"	
	grep "IN     A" fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	grep "CNAME" fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
else	
	echo -e "\t[+] Iniciando dnsenum (bruteforce DNS ) .."
	#dnsenum
	dnsenum $DOMAIN --nocolor -f /usr/share/wordlists/hosts.txt > dnsenum.txt 	
	grep "IN    A" dnsenum.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	grep "CNAME" dnsenum.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	
	
fi


# ctfr
cat ctfr.txt >> subdominios.txt
		
cd ..

#correos
cat correo/theharvester-google.txt | grep --color=never @ | grep -v edge-security >>correo/all-correos.txt
cat correo/theharvester-bing.txt | grep --color=never @ | grep -v edge-security >>correo/all-correos.txt
cat correo/infoga.txt | grep --color=never "Ecorreo:" | cut -d " " -f3 >>correo/all-correos.txt

lines=`wc -l correo/all-correos.txt | cut -d " " -f1`
perl -E "say \"$DOMAIN\n\" x $lines" > correo/domain.txt # file with the domain (n times)
sed -i '$ d' correo/domain.txt # delete last line
paste -d ',' correo/domain.txt correo/all-correos.txt > reporte/correos1.csv 

cat reporte/correos1.csv | sort | uniq > reporte/correos.csv 
rm reporte/correos1.csv


#subdominios
cat correo/theharvester-google.txt | grep --color=never $DOMAIN | grep -v @ >> dns/subdominios.txt
cat correo/theharvester-bing.txt| grep --color=never $DOMAIN | grep -v @ >> dns/subdominios.txt
cat dns/subdominios.txt | sort | uniq -i > dns/subdominios2.txt 
cp dns/subdominios2.txt subdominios.txt

sed -i "s/$DOMAIN./$DOMAIN/g" subdominios.txt
sed -i "s/:/,/g" subdominios.txt
sort subdominios.txt | uniq > subdominios2.txt
cat subdominios2.txt  | egrep -v '\--|Testing|Trying|DNS' > subdominios3.txt


echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"
while read line           
do           
    subdominio=$(echo  $line | cut -d "," -f2)
    echo "Obteniendo datos del subdominio: $subdominio"
    geodata=$(geoip.pl $subdominio)
    echo "$DOMAIN,$line,$geodata" >> reporte/subdominios.csv
done <subdominios3.txt 


rm subdominios.txt
rm subdominios2.txt
rm subdominios3.txt	

#rm correo/theharvester-google.txt
#rm correo/bing.txt

######################################################
