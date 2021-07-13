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

sudo apt-get install -y fierce dnsenum cargo golang subjack sqlmap

echo -e "${RED}[+]${BLUE} Copiando ejecutables ${RESET}"

sudo cp recon.sh /usr/bin/
sudo cp get-geodata.sh /usr/bin/
sudo cp spoofcheck.sh /usr/bin/
sudo cp grep.sh /usr/bin/
sudo cp infoga.sh /usr/bin/
sudo cp Sublist3r.sh /usr/bin/
sudo cp ctfr.sh /usr/bin/
sudo cp subfinder /usr/bin/
sudo cp pymeta.sh /usr/bin/
mkdir /usr/share/wordlists
sudo cp hosts.txt /usr/share/wordlists/hosts.txt
echo "xyz" > /usr/share/fierce/hosts.txt # erase host list

sudo chmod a+x /usr/bin/recon.sh
sudo chmod a+x /usr/bin/subfinder #64bits
sudo chmod a+x /usr/bin/grep.sh
sudo chmod a+x /usr/bin/ctfr.sh
sudo chmod a+x /usr/bin/spoofcheck.sh 
sudo chmod a+x /usr/bin/infoga.sh 
sudo chmod a+x /usr/bin/Sublist3r.sh
sudo chmod a+x /usr/bin/pymeta.sh 
sudo chmod a+x /usr/bin/get-geodata.sh

kernel=`uname -a`
if [[ $kernel == *"aarch64"* ]]; then #rasberry	
	sudo cp findomain-aarch64 /usr/bin/findomain
	sudo cp amass-arm64 /usr/bin/amass 
else
	sudo cp findomain-amd64 /usr/bin/findomain		
	sudo cp amass-amd64 /usr/bin/amass 
fi

if [[ $kernel == *"Nethunter"* ]]; then #rasberry	
	which findomain >/dev/null
	if [ $? -eq 1 ]
	then
		cargo install findomain
		mv ~/.cargo/bin/findomain /usr/bin/findomain
	fi		
fi


sudo chmod a+x /usr/bin/findomain

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

echo -e "${RED}[+]${BLUE} Instalando S3scanner ${RESET}"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo pip3 install s3scanner 


echo -e "${RED}[+]${BLUE} Instalando google search ${RESET}"
git clone https://github.com/DanielTorres1/googlesearch
cd googlesearch 
bash instalar.sh
cd ..


echo -e "${RED}[+]${BLUE} Instalando pymeta ${RESET}"
cd pymeta 
bash setup.sh
cd  ..
sudo cp -R pymeta /usr/share/

echo -e "${RED}[+]${BLUE} Instalando Sublist3r ${RESET}"
sudo cp -R Sublist3r /usr/share/
cd Sublist3r
sudo pip install -r requirements.txt
cd ..

echo -e "${RED}[+]${BLUE} Instalando subjack ${RESET}"
go get github.com/haccer/subjack
ln -s ~/go/bin/subjack /usr/bin/subjack


echo -e "${RED}[+]${BLUE} Instalando spoofcheck ${RESET}"
sudo cp -R spoofcheck /usr/share/
sudo cp hosts.txt /usr/share/wordlists/hosts.txt


echo -e "${RED}[+]${BLUE} Instalando gsan ${RESET}"
sudo pip3 install --user gsan 
ln -s ~/.local/bin/gsan /usr/bin/gsan

echo -e "${RED}[+]${BLUE} Instalando Links_Crawler.py ${RESET}"
pip3 install nyawc 
cp Links_Crawler.py /usr/bin/Links_Crawler.py 
cp httprobe /usr/bin/httprobe
chmod a+x /usr/bin/httprobe
chmod a+ /usr/bin/Links_Crawler.py
                                                                                                                                            


echo -e "${RED}[+]${BLUE} Instalando dalfox ${RESET}"
cd dalfox
sudo go install
sudo go build
sudo ln -s ~/go/bin/dalfox /usr/bin/dalfox
cd ..

cd spoofcheck
sudo pip install -r requirements.txt
cd ..

