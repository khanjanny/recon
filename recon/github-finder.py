#!/usr/bin/python3
# De una lista de URL de github las descarga en formato raw y busca ciertos patrones (passwords, correos, etc)
import pprint
import re
import json
import requests
from urllib.parse import quote
import time
import sys
import argparse

def encodeURL(url):
    url = str(quote(url)) #Codificar URL
    return url.replace("%3A" ,":")

parser = argparse.ArgumentParser()
parser.add_argument("--file" ,"-f" ,help="set file")
parser.add_argument("--domain" ,"-d" ,help="set file")

parser.parse_args()
args = parser.parse_args()

# Using readlines()
fileGithubURL = open(args.file ,'r')
Lines = fileGithubURL.readlines() 
# Strips the newline character
for line in Lines:
    tags = ""
    link=line.strip().replace("github.com" ,"raw.githubusercontent.com")    
    link=link.replace('/blob/','/')
    link=encodeURL(link)    
    newHeaders = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML ,like Gecko) Chrome/40.0.2214.85 Safari/537.36'}
    #print(f'link {link} ')
    response = requests.get(link,headers=newHeaders)
    
    #print(f'{link} : {response.status_code}')
    if "200" not in str(response.status_code):
        print(f"ERROR {link}")
    html_source = response.text    
    html_source_lowercase = html_source.lower()    
    
    if 'secret ' in html_source_lowercase or 'secret;' in html_source_lowercase:
        tags = tags + "secret"
    
    if 'key '  in html_source_lowercase or 'key;' in html_source_lowercase:
        tags = tags + " ,key"

    if 'token '  in html_source_lowercase or 'token;' in html_source_lowercase:
        tags = tags + " ,token"

    if 'password '  in html_source_lowercase or 'password;' in html_source_lowercase:
        tags = tags + " ,password"

    if 'jdbc '  in html_source_lowercase:
        tags = tags + " ,jdbc"

    if 'credencial '  in html_source_lowercase or 'credencial;' in html_source_lowercase:
        tags = tags + " ,credencial"

    if 'correo '  in html_source_lowercase or 'correo;' in html_source_lowercase:
        tags = tags + " ,correo"
    
    if '@'+args.domain in html_source_lowercase:
        tags = tags + " ,correoDominio"
        
    if tags != "":
        print(f'{line} : {tags}')
    #sys.exit("OK")
