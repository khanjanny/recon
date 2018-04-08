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

RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

echo -e "${RED}[+]${BLUE} Instando de repositorio .. ${RESET}"

sudo apt-get install fierce 

echo -e "${RED}[+]${BLUE} Copiando ejecutables ${RESET}"

sudo cp recon.sh /usr/bin/
sudo cp get-geodata.sh /usr/bin/
sudo cp spoofcheck.sh /usr/bin/
sudo cp infoga.sh /usr/bin/
sudo cp ctfr.sh /usr/bin/
sudo cp hosts.txt usr/share/wordlists/hosts.txt
echo "xyz" > /usr/share/fierce/hosts.txt # erase host list

sudo chmod a+x /usr/bin/recon.sh
sudo chmod a+x /usr/bin/ctfr.sh
sudo chmod a+x /usr/bin/spoofcheck.sh 
sudo chmod a+x /usr/bin/infoga.sh 
sudo chmod a+x /usr/bin/get-geodata.sh

echo -e "${RED}[+]${BLUE} Instalando librerias de python ${RESET}"
sudo pip install xlrd
sudo pip install emailprotectionslib
sudo pip install tldextract
echo ""


echo -e "${RED}[+]${BLUE} Instalando GeoIP ${RESET}"
git clone https://github.com/DanielTorres1/geoIP
cd geoIP
bash instalar.sh
echo ""
cd ../

echo -e "${RED}[+]${BLUE} Instalando Infoga ${RESET}"
sudo cp -R Infoga /usr/share/

echo -e "${RED}[+]${BLUE} Instalando ctfr ${RESET}"
sudo cp -R ctfr /usr/share/
cd ctfr
sudo pip install -r requirements.txt
cd ..


echo -e "${RED}[+]${BLUE} Instalando spoofcheck ${RESET}"
sudo cp -R spoofcheck /usr/share/
sudo cp hosts.txt /usr/share/wordlists/hosts.txt

cd spoofcheck
sudo pip install -r requirements.txt
cd ..
