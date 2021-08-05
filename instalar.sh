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


echo -e "${RED}[+]${BLUE} Instalar docker ${RESET}"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable"

echo -e "${RED}[+]${BLUE} Instando de repositorio .. ${RESET}"
sudo apt-get update
sudo apt-get install -y fierce dnsenum cargo pipenv golang subjack sqlmap libxml2-dev libxslt1-dev libssl-dev libffi-dev zlib1g-dev python3-pip apt-transport-https ca-certificates curl gnupg2 software-properties-common docker-ce docker-ce-cli containerd.io python3-dev libfuzzy-dev ssdeep
python3 -m pip install --upgrade pip
sudo pip install shodan colored


echo -e "${GREEN} [+] Copiando archivos de configuracion ${RESET}" 
mkdir /usr/share/recon-config
mkdir /usr/share/wordlists

cp config/subfinder-config.yaml ~/.config/subfinder/config.yaml
cp config/amass-config.ini /usr/share/recon-config/amass-config.ini
cp config/commonspeak-llave-google.json /usr/share/recon-config/commonspeak-llave-google.json
cp config/hosts.txt /usr/share/recon-config/hosts.txt
cp config/names.txt /usr/share/recon-config/names.txt
cp config/resolvers.txt /usr/share/recon-config/resolvers.txt
cp config/truffle-exclude.txt /usr/share/recon-config/truffle-exclude.txt
cp config/truffle-rules.json /usr/share/recon-config/truffle-rules.json



echo -e "${GREEN} [+] Instalando assetfinder ${RESET}" 
go get -u github.com/tomnomnom/assetfinder
sudo cp ~/go/bin/assetfinder /usr/bin/assetfinder 
chmod a+x /usr/bin/assetfinder
echo "export FB_APP_ID=737293516835506" >> ~/.zshrc
echo "export dcb89858c1420a79e9578b687f4b4a77" >> ~/.zshrc


echo -e "${GREEN} [+] Instalando waybackurls ${RESET}" 
go get github.com/tomnomnom/waybackurls
sudo cp ~/go/bin/waybackurls /usr/bin/waybackurls 
chmod a+x /usr/bin/waybackurls


echo -e "${GREEN} [+] Instalando githound ${RESET}" 
mkdir ~/.githound/
echo "github_username: 'hackworld1'" >> ~/.githound/config.yml
echo "github_password: 'y@pj7BDu9p0D'" >> ~/.githound/config.yml

echo -e "${GREEN} [+] Instalando massdns ${RESET}" 
cd massdns
make
cd ..

echo -e "${GREEN} [+] Instalando github-subdomains ${RESET}" 
go get -u github.com/gwen001/github-subdomains
sudo cp ~/go/bin/github-subdomains /usr/bin/github-subdomains 
chmod a+x /usr/bin/github-subdomains


echo -e "${GREEN} [+] Instalando trufflehog ${RESET}" 
docker pull dxa4481/trufflehog


echo -e "${GREEN} [+] Instalando DumpsterDiver ${RESET}" 
cd DumpsterDiver
docker build -t dumpster-diver .


echo -e "${GREEN} [+] Instalando assets-from-spf ${RESET}" 
pip2 install click ipwhois
sudo cp -R assets-from-spf /usr/share/ 

echo -e "${GREEN} [+] Instalando EyeWitness ${RESET}" 
cd EyeWitness
sudo bash setup.sh
cd ../
sudo cp -R EyeWitness /usr/share/ 


echo -e "${GREEN} [+] Instalando HTTPX ${RESET}" 
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
sudo cp ~/go/bin/httpx /usr/bin/httpx 
chmod a+x /usr/bin/httpx


echo -e "${RED}[+]${BLUE} Copiar ejecutables ${RESET}"
cp -r recon /usr/bin
chmod a+x /usr/bin/recon/*
echo export PATH="$PATH:/usr/bin/recon" >> ~/.bashrc
echo export PATH="$PATH:/usr/bin/recon" >> ~/.zshrc


echo -e "${RED}[+]${BLUE} Copiar configuracion de  subfinder ${RESET}"
mkdir -p ~/.config/subfinder/



echo -e "${RED}[+]${BLUE} Instalar GitGot ${RESET}"
cd GitGot/
pip3 install -r requirements.txt
cd ..


echo -e "${RED}[+]${BLUE} Copiando ejecutables ${RESET}"

sudo cp recon.sh /usr/bin/
sudo chmod a+x /usr/bin/recon.sh

echo -e "${RED}[+]${BLUE} Instalando librerias de python ${RESET}"
sudo pip install xlrd emailprotectionslib tldextract
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

echo -e "${RED}[+]${BLUE} Instalando bucket-namegen ${RESET}"
sudo cp -R bucket-namegen /usr/share/

echo -e "${RED}[+]${BLUE} Instalando Sublist3r ${RESET}"
sudo cp -R Sublist3r /usr/share/
cd Sublist3r
sudo pip install -r requirements.txt
cd ..

echo -e "${RED}[+]${BLUE} Instalando subjack ${RESET}"
go get github.com/haccer/subjack
ln -s ~/go/bin/subjack /usr/bin/subjack


echo -e "${RED}[+]${BLUE} Instalando spoofcheck ${RESET}"
cd  spoofcheck 
docker build -t spoofcheck . 
cd ..

echo -e "${RED}[+]${BLUE} Instalando Infoga ${RESET}"
cd  Infoga 
docker build -t Infoga . 
cd ..


echo -e "${RED}[+]${BLUE} Instalando gsan ${RESET}"
cd gsan
docker build -t gsan .
cd ..

echo -e "${RED}[+]${BLUE} Instalando BlackWidow ${RESET}"
cd BlackWidow
bash install.sh
cd ..
         
         
echo -e "${RED}[+]${BLUE} Instalando LinkFinder ${RESET}"
cd LinkFinder
pip install jsbeautifier
cd ..                                                                                                                            


echo -e "${RED}[+]${BLUE} Instalando DumpsterDiver ${RESET}"
cd DumpsterDiver
docker build -t dumpster-diver .  
cd ..   


echo -e "${RED}[+]${BLUE} Instalando dalfox ${RESET}"
cd dalfox
sudo go install
sudo go build
sudo ln -s ~/go/bin/dalfox /usr/bin/dalfox
cd ..

echo -e "${RED}[+]${BLUE} spoofcheck ${RESET}"
cd spoofcheck
sudo pip install -r requirements.txt
cd ..

