#!/bin/bash

THREADS="30"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

#https://ipinfo.io/186.121.242.109

#https://github.com/Ice3man543/subfinder
#https://github.com/daudmalik06/ReconCat
#https://github.com/mobrine-mob/M0B-tool-v2
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
mkdir searchengine
touch searchengine/googlehacking.txt
mkdir archivos
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
fierce -dns $DOMAIN -threads 3 > fierce.txt 

egrep -i "SOA" fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then # Si se hizo volcado de zona	
	echo -e "$OKRED Volcado de zona !! $RESET"		
else	
	echo -e "\t[+] Iniciando dnsenum (bruteforce DNS ) .."
	dnsenum $DOMAIN --nocolor -f /usr/share/wordlists/hosts.txt > dnsenum.txt &
fi

echo -e "\t[+] Iniciando CTFR ( Certificate Transparency logs) .."
ctfr.sh -d $DOMAIN > ctfr.txt
cd ../



##################### Email, subdominios #################

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


##################### search engines #################
echo -e "$OKBLUE+ -- --=############ Google hacking ... #########$RESET"
google.pl -t "site:github.com intext:$DOMAIN" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN intitle:index.of" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN filetype:sql" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN \"access denied for user\"" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN intitle:\"curriculum vitae\"" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN passwords|contrasenas|login|contrasena filetype:txt" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN inurl:intranet" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN inurl:\":8080\" -intext:8080" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:$DOMAIN filetype:asmx OR filetype:svc OR inurl:wsdl" -o searchengine/googlehacking.txt -p 1 
google.pl -t "site:$DOMAIN inurl:(_vti_bin|api|webservice)" -o searchengine/googlehacking.txt -p 1 

google.pl -t "site:trello.com passwords|contrasenas|login|contrasena intext:\"$DOMAIN\"" -o searchengine/googlehacking.txt -p 1
google.pl -t "site:pastebin.com intext:"*@$DOMAIN"" -o searchengine/googlehacking.txt -p 1

echo -e "$OKBLUE+ -- --=############ Recopilando URL indexadas ... #########$RESET" 
google.pl -t "site:$DOMAIN" -o searchengine/google.txt

echo -e "$OKBLUE+ -- --=############ Recopilando Metadatos ... #########$RESET" 
pymeta.sh -d $DOMAIN -dir `pwd`"/archivos/" -csv -out `pwd`"/reporte/metada.csv"
cat reporte/metada.csv | cut -d "," -f4 | sort | uniq > reporte/usuarios-metadata.txt

#################

echo -e "$OKBLUE+ -- --=############ Probando si se puede spoofear el dominio #########$RESET"

spoofcheck.sh $DOMAIN > reporte/dns-spoof.txt


echo -e "$OKBLUE+ -- --=############ Recopilando informacion ... #########$RESET"

######## DNS ###

####### wait to finish########
  while true; do
	dnsenum_instances=$((`ps aux | grep dnsenum | wc -l` - 1)) 
  if [ "$dnsenum_instances" -gt 0 ]
	then
		echo "Todavia hay escaneos de dnsenum activos ($dnsenum_instances)"  
		sleep 30
	else
		break		  		 
	fi				
  done
##############################
	  
cd dns
# fierce
egrep -i "SOA" fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then # Si se hizo volcado de zona	
	#echo -e "$OKRED Volcado de zona !! $RESET"	
	grep "IN     A" fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	grep "CNAME" fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
else	
	echo -e "\t[+] Iniciando dnsenum (bruteforce DNS ) .."
	#dnsenum	
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
cat searchengine/google.txt | cut -d "/" -f 3 | cut -d ":" -f1 | sort | uniq >> dns/subdominios.txt

cd dns
sed -i "s/$DOMAIN./$DOMAIN/g" subdominios.txt
sed -i "s/:/,/g" subdominios.txt
#filtrar dominios
grep $DOMAIN subdominios.txt | egrep -v '\--|Testing|Trying|DNS|\*' | sort | uniq -i > subdominios2.txt

for line in `cat subdominios2.txt`;
do 		
	#Si ya tiene ip identificada
	if [[ ${line} == *","* ]];then
			echo $line >> subdominios3.txt
	else
		#descubrir a que ip resuelve
		hostline=`host $line | grep -v alias`	
		total_ips=$(echo $hostline | grep -o address | wc -l)					
		
		#Si tiene mas de una IP
		if [ $total_ips -gt 1 ];
		then								
			ip=`echo $hostline| grep address|  cut -d " " -f4`
			#echo "ip $ip"
			echo "$ip,$line" >> subdominios3.txt
			
			ip2=`echo $hostline| grep address|  cut -d " " -f8`
			#echo "ip2 $ip2"
			echo "$ip2,$line" >> subdominios3.txt
		else
			#Si tiene una ip
			ip=`echo $hostline| grep address| cut -d " " -f4`			
			if [ -n "$ip" ]; then
				echo "$ip,$line" >> subdominios3.txt
			fi
			
		fi 															
	fi		
done

sort subdominios3.txt | uniq -i > subdominios4.txt
cd ..

echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"
while read line           
do           
    ip=$(echo  $line | cut -d "," -f1)
    subdominio=$(echo  $line | cut -d "," -f2)    
    echo "Obteniendo datos del subdominio: $subdominio"
    geodata=$(geoip.pl $ip)
    echo "$DOMAIN,$line,$geodata" >> reporte/subdominios.csv
done <dns/subdominios4.txt 


#rm correo/theharvester-google.txt
#rm correo/bing.txt

######################################################
