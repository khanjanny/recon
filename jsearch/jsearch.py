import sys
import argparse
import os
from requests_module import requests_module


__AUTHOR__ = "v4lak"

try:
    from bs4 import BeautifulSoup
    import requests
    
except ImportError as e:
    print("[+] install requirements. pip3 install -r requirements.txt")
    print(f"{e}")
    sys.exit(1)


def main():

    filename = sys.argv[0]
    parse = argparse.ArgumentParser(description="Usage: {} -u <URL> -o output".format(filename))
    parse.add_argument('-u', "--url", type=str, required=True, help="[+] URL to craw")
    parse.add_argument('-n', "--name", type=str, required=True, help="[+] Name of company ex: \n python3 jsearch.py -u https://google.com -n google")
    menu = parse.parse_args()

    if len(sys.argv[1:]) == 0:
        print(parse.print_help())

    jsearch = requests_module.CoreRequests(menu.url, menu.name)
    jsearch.get_content_html()


if __name__ == "__main__":
    main()
