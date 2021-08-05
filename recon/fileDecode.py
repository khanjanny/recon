#!/usr/bin/python3
from urllib.parse import unquote
import argparse


parser = argparse.ArgumentParser()
parser.add_argument("--file", "-f", help="Archivo")
parser.parse_args()
args = parser.parse_args()

fileEncoded = open(args.file)
content = fileEncoded.read()
fileEncoded.close()


decodedContent = unquote(content)
fileEncoded = open(args.file,"w")
fileEncoded.write(decodedContent)
fileEncoded.close()

#print (decodedContent)
