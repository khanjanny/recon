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

#https://github.com/daudmalik06/ReconCat
#https://github.com/mobrine-mob/M0B-tool-v2
#https://github.com/GerbenJavado/LinkFinder
#https://github.com/franccesco/getaltname
#https://github.com/twelvesec/gasmask

# Cloud
#https://github.com/MindPointGroup/cloudfrunt
#https://github.com/glen-mac/goGetBucket
#https://github.com/yehgdotnet/S3Scanner

#WEB
#https://github.com/MrSqar-Ye/BadMod
#https://www.kitploit.com/2018/04/jcs-joomla_vulnerability-component.html
#https://github.com/steverobbins/magescan
#https://github.com/fgeek/pyfiscan
#https://github.com/vortexau/mooscan
#https://github.com/retirejs/retire.js/
#https://github.com/UltimateHackers/XSStrike
#https://whatcms.org/Content-Management-Systems
#https://github.com/m4ll0k/WPSeku
#https://github.com/Jamalc0m/wphunter
#https://github.com/m4ll0k/WAScan


# mobile app
#https://github.com/UltimateHackers/Diggy
#https://github.com/Security-Onion-Solutions/security-onion

#Vuln app
#https://github.com/logicalhacking/DVHMA

#other
#https://github.com/m4ll0k/iCloudBrutter
#https://github.com/Moham3dRiahi/XBruteForcer
#https://github.com/hc0d3r/sudohulk
#https://github.com/floriankunushevci/aragog
#https://github.com/mthbernardes/ipChecker
#https://www.kitploit.com/2018/02/roxysploit-penetration-testing-suite.html
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
	


while getopts ":d:n:" OPTIONS
do
            case $OPTIONS in
            d)     DOMINIO=$OPTARG;;
            n)     NOMBRE=$OPTARG;;            
            ?)     printf "Opcion Invalida: -$OPTARG\n" $0
                          exit 2;;
           esac
done

DOMINIO=${DOMINIO:=NULL}
NOMBRE=${NOMBRE:=NULL}

#echo "NOMBRE ENTIDAD $NOMBRE"

##################
#  ~~~ Menu ~~~  #
##################

if [ -z "$DOMINIO" ]; then
echo " USO: recon.sh -d [dominio] -n [nombre de la entidad en linkedin] -c [UNA palabra para filtrar resultados]"
echo ""
exit
fi
######################

mkdir $DOMINIO
cd $DOMINIO

mkdir .arp
mkdir .escaneos
mkdir .datos
mkdir .nmap
mkdir .nmap_1000p
mkdir .nmap_banners
mkdir .banners
mkdir .banners2
mkdir .enumeracion
mkdir .enumeracion2 
mkdir .vulnerabilidades
mkdir .vulnerabilidades2 
mkdir .masscan
mkdir reportes
mkdir servicios
mkdir .tmp
mkdir -p logs/cracking
mkdir -p logs/enumeracion
mkdir -p logs/vulnerabilidades

mkdir webClone
mkdir importarMaltego
mkdir -p archivos	
touch .enumeracion/"$DOMINIO"_google_googlehacking.txt
cp /usr/share/lanscanner/.resultados.db .
echo -e "$OKORANGE+ -- --=############ Usando servidor DNS  ... #########$RESET"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
grep nameserver /etc/resolv.conf
echo -e "$OKORANGE+ -- --=############ ############## #########$RESET"
echo ""



####################  DNS test ########################
echo -e "$OKBLUE+ -- --=############ Reconocimiento DNS  ... #########$RESET"


echo -e "\t[+] Iniciando dnsrecon (DNS info) .."
dnsrecon -d $DOMINIO --lifetime 60  > logs/enumeracion/dnsrecon.txt &

echo -e "\t[+] Iniciando fierce (Volcado de zona) .."
fierce -dns $DOMINIO -threads 3 > logs/enumeracion/fierce.txt 

egrep -iq "SOA" logs/enumeracion/fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then # Si se hizo volcado de zona	
	echo -e "$OKRED \t  [!] Volcado de zona detectado !! $RESET"		
else	
	echo -e "\t[+] Iniciando dnsenum (bruteforce DNS ) .."
	dnsenum $DOMINIO --nocolor -f /usr/share/wordlists/hosts.txt --noreverse --threads 3 > logs/enumeracion/dnsenum.txt 2>/dev/null &
fi

echo -e "\t[+] Iniciando CTFR ( Certificate Transparency logs) .."
ctfr.sh -d $DOMINIO > logs/enumeracion/ctfr.txt 2>/dev/null

echo -e "\t[+] Iniciando Sublist3r ( Baidu, Yahoo, Google, Bing, Ask, Netcraft, DNSdumpster, Virustotal, ThreatCrowd, SSL Certificates, PassiveDNS) .."
Sublist3r.sh -d $DOMINIO -o `pwd`/logs/enumeracion/Sublist3r.txt


echo -e "\t[+] Iniciando findomain ( Crtsh API, CertSpotter API, facebook) .."
findomain --all-apis --target $DOMINIO > logs/enumeracion/findomain.txt

##################### Email, subdominios #################

echo -e "$OKBLUE+ -- --=############ Obteniendo  correos,subdominios, etc ... #########$RESET"
echo -e "\t[+] Iniciando whois .."
whois $DOMINIO > .enumeracion/"$DOMINIO"_dns_whois.txt

echo -e "\t[+] Iniciando theharvester .."
echo -e "\t\t[+] Buscando correos en google .."
theharvester -d $DOMINIO -b google > logs/enumeracion/theharvester_google.txt 2>/dev/null
echo -e "\t\t[+] Buscando correos en bing .."
theharvester -d $DOMINIO -b bing > logs/enumeracion/theharvester_bing.txt 2>/dev/null


echo -e "\t[+] Iniciando infoga .."

infoga.sh -t $DOMINIO -s all > logs/enumeracion/infoga2.txt 2>/dev/null
sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" logs/enumeracion/infoga2.txt > logs/enumeracion/infoga.txt
rm logs/enumeracion/infoga2.txt 

#################

######### DNS spoof ########

echo -e "$OKBLUE+ -- --=############ Probando si se puede spoofear el dominio... #########$RESET"

spoofcheck.sh $DOMINIO > logs/vulnerabilidades/"$DOMINIO"_dns_spoof.txt
egrep -iq "Spoofing possible" logs/vulnerabilidades/"$DOMINIO"_dns_spoof.txt
greprc=$?
if [[ $greprc -eq 0 ]] ; then			
	cp logs/vulnerabilidades/"$DOMINIO"_dns_spoof.txt .vulnerabilidades/"$DOMINIO"_dns_spoof.txt		
fi
echo -e "$OKBLUE+ -- --=############ Recopilando informacion ... #########$RESET"
insert_data
######## ###



##################### search engines #################
## linked in
#echo -e "$OKBLUE+ -- --=############ Obteniendo lista de empleados de linkedin ... #########$RESET" 
#linkedinFinder.pl -n "$NOMBRE"  -l logs/enumeracion/"$DOMINIO"_linkedin.csv
#grep --color=never -ai "$NOMBRE" logs/enumeracion/"$DOMINIO"_linkedin.csv  > reportes/linkedin.csv

	

echo -e "$OKBLUE+ -- --=############ Google hacking ... #########$RESET"

									#-o lista de URL													-l resultado html de l busqueda
google.pl -t "site:$DOMINIO inurl:add" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking0.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking0.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking0.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO inurl:add" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking0.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking0.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;


google.pl -t "site:$DOMINIO inurl:edit" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking1.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking1.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking1.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO inurl:edit" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking1.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking1.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:github.com intext:$DOMINIO" -o logs/enumeracion/"$DOMINIO"_google_googlehacking.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com intext:$DOMINIO" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	          
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO intitle:index.of" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking2.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking2.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking2.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO intitle:index.of" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking2.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking2.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO filetype:sql" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking3.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking3.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking3.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO filetype:sql" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking3.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking3.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO \"access denied for user\"" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking4.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking4.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking4.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO \"access denied for user\"" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking4.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking4.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO intitle:\"curriculum vitae\"" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking5.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking5.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking5.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO intitle:\"curriculum vitae\"" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking5.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking5.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt		
fi

sleep 10;

google.pl -t "site:$DOMINIO passwords|contrasenas|login|contrasena filetype:txt" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking6.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking6.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking6.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO passwords|contrasenas|login|contrasena filetype:txt" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking6.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking6.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO inurl:intranet" -o logs/enumeracion/"$DOMINIO"_google_googlehacking7.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking7.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking7.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO inurl:intranet" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking7.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking7.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO inurl:\":8080\" -intext:8080" -o logs/enumeracion/"$DOMINIO"_google_googlehacking8.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking8.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking8.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO inurl:\":8080\" -intext:8080" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking8.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking8.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO filetype:asmx OR filetype:svc OR inurl:wsdl" -o logs/enumeracion/"$DOMINIO"_google_googlehacking9.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking9.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking9.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com intext:$DOMINIO" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking9.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking9.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO inurl:(_vti_bin|api|webservice)" -o logs/enumeracion/"$DOMINIO"_google_googlehacking10.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking10.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking10.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO inurl:(_vti_bin|api|webservice)" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking10.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking10.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:trello.com passwords|contrasenas|login|contrasena intext:\"$DOMINIO\"" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:trello.com passwords|contrasenas|login|contrasena intext:\"$DOMINIO\"" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;
													   #logs/vulnerabilidades/abc.gob.bo_google_googlehacking12.txt														
google.pl -t "site:pastebin.com intext:*@$DOMINIO" -o logs/enumeracion/"$DOMINIO"_google_googlehacking12.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking12.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking12.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com intext:$DOMINIO" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking12.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking12.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO \"Undefined index\" " -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO \"Undefined index\" " >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:$DOMINIO inurl:storage" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking14.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking14.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking14.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:$DOMINIO inurl:storage" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking14.txt # delete empty lines	
cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking14.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
fi

insert_data

# mover los listados de URL identificados por google (Dejas solo los .html en la carpeta log)
mv logs/vulnerabilidades/*_google_googlehacking*.txt .vulnerabilidades2/ 2>/dev/null

sleep 90


echo -e "$OKBLUE+ -- --=############ Recopilando Metadatos ... #########$RESET" 
pymeta.sh -d $DOMINIO -dir `pwd`"/archivos/" -csv -out `pwd`"/reportes/metada.csv" 2>/dev/null
cat reportes/metada.csv | cut -d "," -f4 | sort | uniq > .enumeracion/"$DOMINIO"_metadata_pymeta.txt
insert_data
sleep 90

echo -e "$OKBLUE+ -- --=############ Recopilando URL indexadas ... #########$RESET" 

google.pl -t "site:$DOMINIO" -o logs/enumeracion/"$DOMINIO"_google_indexado2.txt -l logs/enumeracion/"$DOMINIO"_google.html 

echo -e "$OKBLUE+ -- --=############ Comprobando si google indexo páginas hackeadas ... #########$RESET" 
egrep -iq " Buy| Pharmacy | medication| cheap| porn| viagra|hacked" logs/enumeracion/"$DOMINIO"_google.html
greprc=$?
if [[ $greprc -eq 0 ]] ; then			
	echo -e "\t$OKRED[!] Redirección  a sitios de terceros detectado \n $RESET"
	echo "Vulnerable site:$DOMINIO" > .vulnerabilidades/"$DOMINIO"_google_redirect.txt 	
fi	

#echo "Ejecutando: sort logs/enumeracion/"$DOMINIO"_google_indexado2.txt | uniq | egrep -v"
sort logs/enumeracion/"$DOMINIO"_google_indexado2.txt | uniq | egrep -v "pdf|doc" > .enumeracion/"$DOMINIO"_google_indexado.txt
egrep -ia "username|usuario|password|contrase|token|sesion|session" .enumeracion/"$DOMINIO"_google_indexado.txt > .vulnerabilidades/"$DOMINIO"_google_credencialURL.txt
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
cat logs/enumeracion/theharvester_google.txt | grep --color=never @ | egrep -v "edge-security|Connection timed out" >> .enumeracion/"$DOMINIO"_correos.txt
cat logs/enumeracion/theharvester_bing.txt | grep --color=never @ | egrep -v "edge-security|Connection timed out" >> .enumeracion/"$DOMINIO"_correos.txt
cat logs/enumeracion/infoga.txt | grep --color=never "correo:" | cut -d " " -f3 >> .enumeracion/"$DOMINIO"_correos.txt

# dar formato para importar a maltego
lines=`wc -l .enumeracion/"$DOMINIO"_correos.txt | cut -d " " -f1`
perl -E "say \"$DOMINIO\n\" x $lines" > DOMINIO.txt # file with the DOMINIO (n times)
sed -i '$ d' DOMINIO.txt # delete last line
paste -d ';' DOMINIO.txt .enumeracion/"$DOMINIO"_correos.txt > importarMaltego/correos1.csv 
cat importarMaltego/correos1.csv  | sort | uniq > importarMaltego/correos.csv 
rm importarMaltego/correos1.csv DOMINIO.txt
#####################################
	  
######## extraer subdominios ###########
# fierce
egrep -qi "SOA" logs/enumeracion/fierce.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then 
	# Si se hizo volcado de zona		
	grep "IN     A" logs/enumeracion/fierce.txt | awk '{print $5,$1}' | tr ' ' ';' >> subdominios.txt
	# 200.105.172.195;soberaniaalimentaria.gob.bo.
	grep "IN	A" logs/enumeracion/fierce.txt | awk '{print $5,$1}' | tr ' ' ';' >> subdominios.txt	
	grep "CNAME" logs/enumeracion/fierce.txt | awk '{print $1}' | tr ' ' ';' >> subdominios.txt
	cp logs/enumeracion/fierce.txt  .vulnerabilidades/"$DOMINIO"_dns_transferenciaDNS.txt
else	
	#dnsenum	
	grep "IN    A" logs/enumeracion/dnsenum.txt | awk '{print $1}' >> subdominios.txt	
	grep "CNAME" logs/enumeracion/dnsenum.txt | awk '{print $1}' >> subdominios.txt

fi

# ctfr
# [-]  dialin.organojudicial.gob.bo
cat logs/enumeracion/ctfr.txt | grep --color=never $DOMINIO | grep -v TARGET | awk '{print $2}' >> subdominios.txt

# Sublist3r
#www.comibol.gob.bo
cat logs/enumeracion/Sublist3r.txt | grep --color=never $DOMINIO | cut -d ":" -f1 >> subdominios.txt

# findomain
#  --> correo.siahcomibol.gob.bo
cat logs/enumeracion/findomain.txt | egrep --color=never "\-\-|>>" |  awk '{print $2}' >> subdominios.txt



# theharvester y google
cat logs/enumeracion/theharvester_google.txt | grep --color=never $DOMINIO | egrep -v "empty|@|harvesting" | cut -d ":" -f1 >> subdominios.txt
cat logs/enumeracion/theharvester_bing.txt| grep --color=never $DOMINIO |egrep -v "empty|@|harvesting" | cut -d ":" -f1  >> subdominios.txt
cat .enumeracion2/"$DOMINIO"_google_indexado.txt | cut -d "/" -f 3 | cut -d ":" -f1 | grep --color=never $DOMINIO | sort | uniq >> subdominios.txt
############################################

sed -i "s/$DOMINIO\./$DOMINIO/g" subdominios.txt #Eliminar punto extra al final

#filtrar dominios
grep --color=never $DOMINIO subdominios.txt | egrep -iv '\--|Testing|Trying|TARGET|subDOMINIOs|DNS|\*' | sort | uniq -i > subdominios2.txt


for line in `cat subdominios2.txt`;
do 		
	#Si ya tiene ip identificada
	if [[ ${line} == *";"*  ]];then 
			line=`echo $line | tr ',' ';'` # Convertir , --> ;
			echo $line >> subdominios3.txt
	else
		#descubrir a que ip resuelve
		hostline=`host $line | egrep -v "alias|IPv6"`
		total_ips=$(echo $hostline | grep -o address | wc -l)					
		
		#Si tiene mas de una IP
		if [ $total_ips -gt 1 ];
		then								
			ip=`echo $hostline| grep address|  cut -d " " -f4`
			#echo "ip $ip"
			echo "$ip;$line" >> subdominios3.txt
			
			ip2=`echo $hostline| grep address|  cut -d " " -f8`
			#echo "ip2 $ip2"
			echo "$ip2;$line" >> subdominios3.txt
		else
			#Si tiene una ip
			ip=`echo $hostline| grep address| cut -d " " -f4`			
			if [ -n "$ip" ]; then
				echo "$ip;$line" >> subdominios3.txt
			fi
			
		fi 															
	fi		
done

sort subdominios3.txt | uniq -i > subdominios4.txt 
#rm subdominios.txt subdominios2.txt subdominios3.txt

echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"
while read line           
do           
    ip=$(echo  $line | cut -d ";" -f1)
    subdominio=$(echo  $line | cut -d ";" -f2)    
    echo "Obteniendo datos del subdominio: $subdominio"
    geodata=$(geoip.pl $ip)
    echo "$DOMINIO;$line;$geodata" >> importarMaltego/subdominios.csv
    echo "$line;$geodata" >> .enumeracion/"$DOMINIO"_subdominios.txt
    perl -i -pe 's/[^[:ascii:]]//g' .enumeracion/"$DOMINIO"_subdominios.txt #remover caracteres especiales
    
done <subdominios4.txt 

#rm subdominios4.txt 

insert_data
rm cookies.txt 2>/dev/null
######################################################

####Extraer datos para informe
##### motores de busqueda
echo "Nombre;Apellido;Correo;Cargo" > reportes/correos_motoresBusqueda.csv
for correo in `cat logs/enumeracion/theharvester_* | grep --color=never "\@" | grep -v "*"`; do	
echo "n/a;n/a;$correo;n/a" >> reportes/correos_motoresBusqueda.csv 
done
################

grep --color=never -ira "10\." logs/enumeracion/dnsenum.txt | sort | uniq >> .vulnerabilidades/"$DOMAIN"_dns_IPinterna.txt
grep --color=never -ira "192\.1" logs/enumeracion/dnsenum.txt | sort | uniq >> .vulnerabilidades/"$DOMAIN"_dns_IPinterna.txt
grep --color=never -ira "172\.1" logs/enumeracion/dnsenum.txt | sort | uniq >> .vulnerabilidades/"$DOMAIN"_dns_IPinterna.txt
insert_data
cp .enumeracion2/"$DOMINIO"_subdominios.txt reportes/subdominios.csv
