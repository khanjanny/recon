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
import json

Lines = sys.stdin.readlines()
for line in Lines:
    result = json.loads(line)
    path = result['path']
    stringsFound = result['stringsFound']
    print(f' File {path} : Strings found: {stringsFound}')
    #print(json.dumps(result, indent=4))    
    #sys.exit("OK")

