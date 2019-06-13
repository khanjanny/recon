#!/bin/bash
# TAREAS 
# mover todos los docs, excels a archivos
# sacar metadatos con exiftool 
THREADS="30"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'

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
#https://github.com/m4ll0k/WAScan


##https://github.com/peterpt/eternal_check
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

function insert_data () {
	find .vulnerabilidades -size  0 -print0 |xargs -0 rm 2>/dev/null # delete empty files
	find .enumeracion -size  0 -print0 |xargs -0 rm 2>/dev/null # delete empty files
	insert-data.py
	mv .enumeracion/* .enumeracion2 2>/dev/null
	mv .vulnerabilidades/* .vulnerabilidades2 2>/dev/null		 	
	}
	


while getopts ":d:" OPTIONS
do
            case $OPTIONS in
            d)     DOMAIN=$OPTARG;;                                   
            ?)     printf "Opcion Invalida: -$OPTARG\n" $0
                          exit 2;;
           esac
done

#DOMAIN=${DOMAIN:=NULL}
#PORT=${PORT:=NULL}
#MYPATH=${MYPATH:=NULL}

##################
#  ~~~ Menu ~~~  #
##################

if [ -z "$DOMAIN" ]; then
echo " USO: recon.sh -d [dominio]"
echo ""
exit
fi
######################

mkdir $DOMAIN
cd $DOMAIN

mkdir .arp
mkdir .escaneos
mkdir .datos
mkdir .nmap
mkdir .nmap_1000p
mkdir .nmap_banners
mkdir .enumeracion
mkdir .vulnerabilidades
mkdir .enumeracion2 
mkdir .vulnerabilidades2 
mkdir .masscan
mkdir reportes
mkdir .servicios
mkdir .tmp
mkdir -p logs/cracking
mkdir -p logs/enumeracion
mkdir -p logs/vulnerabilidades

mkdir webClone
mkdir importarMaltego
mkdir -p archivos	
touch .enumeracion/web-googlehacking.txt
cp /usr/share/lanscanner/resultados.db .
echo -e "$OKORANGE+ -- --=############ Usando servidor DNS  ... #########$RESET"
grep nameserver /etc/resolv.conf
echo -e "$OKORANGE+ -- --=############ ############## #########$RESET"
echo ""



####################  DNS test ########################
echo -e "$OKBLUE+ -- --=############ Reconocimiento DNS  ... #########$RESET"


echo -e "\t[+] Iniciando dnsrecon (DNS info) .."
dnsrecon -d $DOMAIN --lifetime 60  > logs/enumeracion/dnsrecon.txt &

echo -e "\t[+] Iniciando fierce (Volcado de zona) .."
fierce -dns $DOMAIN -threads 3 > logs/enumeracion/fierce.txt 

egrep -iq "SOA" logs/enumeracion/fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then # Si se hizo volcado de zona	
	echo -e "$OKRED \t  [!] Volcado de zona detectado !! $RESET"		
else	
	echo -e "\t[+] Iniciando dnsenum (bruteforce DNS ) .."
	dnsenum $DOMAIN --nocolor -f /usr/share/wordlists/hosts.txt --noreverse --threads 3 > logs/enumeracion/dnsenum.txt &
fi

echo -e "\t[+] Iniciando CTFR ( Certificate Transparency logs) .."
ctfr.sh -d $DOMAIN > logs/enumeracion/ctfr.txt


##################### Email, subdominios #################

echo -e "$OKBLUE+ -- --=############ Obteniendo  correos,subdominios, etc ... #########$RESET"
echo -e "\t[+] Iniciando whois .."
whois $DOMAIN > .enumeracion/$DOMAIN-dns-whois.txt

echo -e "\t[+] Iniciando theharvester .."
echo -e "\t\t[+] Buscando correos en google .."
theharvester -d $DOMAIN -b google > logs/enumeracion/theharvester-google.txt 2>/dev/null
echo -e "\t\t[+] Buscando correos en bing .."
theharvester -d $DOMAIN -b bing > logs/enumeracion/theharvester-bing.txt 2>/dev/null


echo -e "\t[+] Iniciando infoga .."

infoga.sh -t $DOMAIN -s all > logs/enumeracion/infoga2.txt 2>/dev/null
sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" logs/enumeracion/infoga2.txt > logs/enumeracion/infoga.txt
rm logs/enumeracion/infoga2.txt 

#################

######### DNS spoof ########

echo -e "$OKBLUE+ -- --=############ Probando si se puede spoofear el dominio... #########$RESET"

spoofcheck.sh $DOMAIN > logs/vulnerabilidades/dns-spoof.txt
egrep -iq "Spoofing possible" logs/vulnerabilidades/dns-spoof.txt
greprc=$?
if [[ $greprc -eq 0 ]] ; then			
	cp logs/vulnerabilidades/dns-spoof.txt .vulnerabilidades/$DOMAIN-dns-spoof.txt		
fi
echo -e "$OKBLUE+ -- --=############ Recopilando informacion ... #########$RESET"
insert_data
######## ###



##################### search engines #################

#openvpn /etc/openvpn/ibvpn/ibVPN_UK_Gosport.ovpn > /dev/null &
#sleep 10
#echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo -e "$OKBLUE+ -- --=############ Google hacking ... #########$RESET"

google.pl -t "site:$DOMAIN inurl:add" -o logs/vulnerabilidades/$DOMAIN-web-googlehacking0.txt -p 1 -l logs/vulnerabilidades/web-googlehacking0.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/web-googlehacking0.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN inurl:add" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/$DOMAIN-web-googlehacking0.txt # delete empty lines	
cat logs/vulnerabilidades/$DOMAIN-web-googlehacking0.txt >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
echo "" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;


google.pl -t "site:$DOMAIN inurl:edit" -o logs/vulnerabilidades/$DOMAIN-web-googlehacking1.txt -p 1 -l logs/vulnerabilidades/web-googlehacking1.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/web-googlehacking1.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN inurl:edit" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/$DOMAIN-web-googlehacking1.txt # delete empty lines	
cat logs/vulnerabilidades/$DOMAIN-web-googlehacking1.txt >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
echo "" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:github.com intext:$DOMAIN" -o logs/enumeracion/$DOMAIN-web-googlehacking.txt -p 1 -l logs/enumeracion/web-googlehacking.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com intext:$DOMAIN" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	          
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN intitle:index.of" -o logs/vulnerabilidades/$DOMAIN-web-googlehacking2.txt -p 1 -l logs/vulnerabilidades/web-googlehacking2.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/web-googlehacking2.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN intitle:index.of" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/$DOMAIN-web-googlehacking2.txt # delete empty lines	
cat logs/vulnerabilidades/$DOMAIN-web-googlehacking2.txt >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
echo "" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN filetype:sql" -o logs/vulnerabilidades/$DOMAIN-web-googlehacking3.txt -p 1 -l logs/vulnerabilidades/web-googlehacking3.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/web-googlehacking3.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN filetype:sql" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/$DOMAIN-web-googlehacking3.txt # delete empty lines	
cat logs/vulnerabilidades/$DOMAIN-web-googlehacking3.txt >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
echo "" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN \"access denied for user\"" -o logs/enumeracion/$DOMAIN-web-googlehacking4.txt -p 1 -l logs/enumeracion/web-googlehacking4.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking4.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN \"access denied for user\"" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking4.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking4.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

#killall openvpn
#openvpn /etc/openvpn/ibvpn/ibVPN_UK_London_2.ovpn > /dev/null &
#sleep 10
#echo "nameserver 8.8.8.8" > /etc/resolv.conf
sleep 10;

google.pl -t "site:$DOMAIN intitle:\"curriculum vitae\"" -o logs/enumeracion/$DOMAIN-web-googlehacking5.txt -p 1 -l logs/enumeracion/web-googlehacking5.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking5.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN intitle:\"curriculum vitae\"" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking5.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking5.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt		
fi

sleep 10;

google.pl -t "site:$DOMAIN passwords|contrasenas|login|contrasena filetype:txt" -o logs/vulnerabilidades/$DOMAIN-web-googlehacking6.txt -p 1 -l logs/vulnerabilidades/web-googlehacking6.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/web-googlehacking6.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN passwords|contrasenas|login|contrasena filetype:txt" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/$DOMAIN-web-googlehacking6.txt # delete empty lines	
cat logs/vulnerabilidades/$DOMAIN-web-googlehacking6.txt >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
echo "" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN inurl:intranet" -o logs/enumeracion/$DOMAIN-web-googlehacking7.txt -p 1 -l logs/enumeracion/web-googlehacking7.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking7.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN inurl:intranet" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking7.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking7.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN inurl:\":8080\" -intext:8080" -o logs/enumeracion/$DOMAIN-web-googlehacking8.txt -p 1 -l logs/enumeracion/web-googlehacking8.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking8.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN inurl:\":8080\" -intext:8080" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking8.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking8.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN filetype:asmx OR filetype:svc OR inurl:wsdl" -o logs/enumeracion/$DOMAIN-web-googlehacking9.txt -p 1 -l logs/enumeracion/web-googlehacking9.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking9.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com intext:$DOMAIN" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking9.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking9.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN inurl:(_vti_bin|api|webservice)" -o logs/enumeracion/$DOMAIN-web-googlehacking10.txt -p 1 -l logs/enumeracion/web-googlehacking10.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking10.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN inurl:(_vti_bin|api|webservice)" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking10.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking10.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:trello.com passwords|contrasenas|login|contrasena intext:\"$DOMAIN\"" -o logs/vulnerabilidades/$DOMAIN-web-googlehacking11.txt -p 1 -l logs/vulnerabilidades/web-googlehacking11.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/web-googlehacking11.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:trello.com passwords|contrasenas|login|contrasena intext:\"$DOMAIN\"" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/$DOMAIN-web-googlehacking11.txt # delete empty lines	
cat logs/vulnerabilidades/$DOMAIN-web-googlehacking11.txt >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
echo "" >> .vulnerabilidades/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:pastebin.com intext:"*@$DOMAIN"" -o logs/enumeracion/$DOMAIN-web-googlehacking12.txt -p 1 -l logs/enumeracion/web-googlehacking12.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking12.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com intext:$DOMAIN" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking12.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking12.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN \"Undefined index\" " -o logs/enumeracion/$DOMAIN-web-googlehacking13.txt -p 1 -l logs/enumeracion/web-googlehacking13.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking13.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN \"Undefined index\" " >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking13.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking13.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMAIN inurl:storage" -o logs/enumeracion/$DOMAIN-web-googlehacking14.txt -p 1 -l logs/enumeracion/web-googlehacking14.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/web-googlehacking14.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMAIN inurl:storage" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/$DOMAIN-web-googlehacking14.txt # delete empty lines	
cat logs/enumeracion/$DOMAIN-web-googlehacking14.txt >> .enumeracion/$DOMAIN-web-googlehacking.txt	
echo "" >> .enumeracion/$DOMAIN-web-googlehacking.txt	
fi


insert_data
sleep 90


echo -e "$OKBLUE+ -- --=############ Recopilando Metadatos ... #########$RESET" 
pymeta.sh -d $DOMAIN -dir `pwd`"/archivos/" -csv -out `pwd`"/reportes/metada.csv" 2>/dev/null
cat reportes/metada.csv | cut -d "," -f4 | sort | uniq > .enumeracion/$DOMAIN-metadata-pymeta.txt
insert_data
sleep 90

echo -e "$OKBLUE+ -- --=############ Recopilando URL indexadas ... #########$RESET" 

google.pl -t "site:$DOMAIN" -o logs/enumeracion/$DOMAIN-web-indexado2.txt -l logs/enumeracion/$DOMAIN-google.html 
echo "Ejecutando: sort logs/enumeracion/$DOMAIN-web-indexado2.txt | uniq | egrep -v"
sort logs/enumeracion/$DOMAIN-web-indexado2.txt | uniq | egrep -v "pdf|doc" > .enumeracion/$DOMAIN-web-indexado.txt
insert_data

	
####### wait to finish ########
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
	  
######## extraer correos ###########
cat logs/enumeracion/theharvester-google.txt | grep --color=never @ | grep -v edge-security >> .enumeracion/$DOMAIN-correos.txt
cat logs/enumeracion/theharvester-bing.txt | grep --color=never @ | grep -v edge-security >> .enumeracion/$DOMAIN-correos.txt
cat logs/enumeracion/infoga.txt | grep --color=never "correo:" | cut -d " " -f3 >> .enumeracion/$DOMAIN-correos.txt

# dar formato para importar a maltego
lines=`wc -l .enumeracion/$DOMAIN-correos.txt | cut -d " " -f1`
perl -E "say \"$DOMAIN\n\" x $lines" > domain.txt # file with the domain (n times)
sed -i '$ d' domain.txt # delete last line
paste -d ',' domain.txt .enumeracion/$DOMAIN-correos.txt > importarMaltego/correos1.csv 
cat importarMaltego/correos1.csv  | sort | uniq > importarMaltego/correos.csv 
rm importarMaltego/correos1.csv domain.txt
#####################################
	  
######## extraer subdominios ###########
# fierce
egrep -qi "SOA" logs/enumeracion/fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then # Si se hizo volcado de zona	
	#echo -e "$OKRED Volcado de zona !! $RESET"	
	grep "IN     A" logs/enumeracion/fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	grep "IN	A" logs/enumeracion/fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt	
	grep "CNAME" logs/enumeracion/fierce.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	cp logs/enumeracion/fierce.txt  .vulnerabilidades/$DOMAIN-dns-transferenciaDNS.txt
else	
#	echo -e "\t[+] Iniciando dnsenum (bruteforce DNS ) .."
	#dnsenum	
	grep "IN    A" logs/enumeracion/dnsenum.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt	
	grep "CNAME" logs/enumeracion/dnsenum.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt

fi

# ctfr
cat logs/enumeracion/ctfr.txt >> subdominios.txt

# theharvester y google
cat logs/enumeracion/theharvester-google.txt | grep --color=never $DOMAIN | grep -v @ >> subdominios.txt
cat logs/enumeracion/theharvester-bing.txt| grep --color=never $DOMAIN | grep -v @ >> subdominios.txt
cat logs/enumeracion/google.txt 2>/dev/null | cut -d "/" -f 3 | cut -d ":" -f1 | sort | uniq >> subdominios.txt

# URL indexadas
cat .enumeracion2/$DOMAIN-web-indexado.txt | cut -d "/" -f 3 | grep --color=never $DOMAIN | sort | uniq >> subdominios.txt
############################################

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
rm subdominios.txt subdominios2.txt subdominios3.txt

echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"
while read line           
do           
    ip=$(echo  $line | cut -d "," -f1)
    subdominio=$(echo  $line | cut -d "," -f2)    
    echo "Obteniendo datos del subdominio: $subdominio"
    geodata=$(geoip.pl $ip)
    echo "$DOMAIN,$line,$geodata" >> importarMaltego/subdominios.csv
    echo "$line,$geodata" >> .enumeracion/$DOMAIN-subdominios.txt
    perl -i -pe 's/[^[:ascii:]]//g' .enumeracion/$DOMAIN-subdominios.txt #remover caracteres especiales
    
done <subdominios4.txt 

#rm subdominios4.txt 

insert_data
rm subdominios4.txt  cookies.txt 2>/dev/null
######################################################

ln -s .enumeracion2/$DOMAIN-subdominios.txt subdominios.txt
