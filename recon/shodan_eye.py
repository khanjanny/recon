#!/usr/bin/python3
# This Python file uses the following encoding:utf-8

# Author: Jolanda de Koff Bulls Eye
# GitHub: https://github.com/BullsEye0
# Website: https://hackingpassion.com
# linkedin: https://www.linkedin.com/in/jolandadekoff
# Facebook: facebook.com/jolandadekoff
# Facebook Page: https://www.facebook.com/ethical.hack.group
# Facebook Group: https://www.facebook.com/groups/hack.passion/
# YouTube: https://www.youtube.com/BullsEyeJolandadeKoff

# Shodan Eye v1.2.0 Created April - August 2019
# Shodan Eye v1.3.0 December 2019
# Copyright (c) 2019 - 2020 Jolanda de Koff.

# Your Shodan API Key can be found here: https://account.shodan.io

########################################################################

# A notice to all nerds and n00bs...
# If you will copy the developer's work it will not make you a hacker..!
# Respect all developers, we doing this because it's fun...

########################################################################


import os
import random
import shodan
import time
import sys
import argparse

# Initiate the parser
parser = argparse.ArgumentParser()
# Add long and short argument
parser.add_argument("--keyword", "-k", help="set keyword")
# Read arguments from the command line
args = parser.parse_args()
keyword = args.keyword
# Shodan Eye v1.3.0

banner1 = ("""

\033[1;31m

  ██████ ██░ ██ ▒█████ ▓█████▄ ▄▄▄      ███▄    █    ▓████▓██   ██▓█████
▒██    ▒▓██░ ██▒██▒  ██▒██▀ ██▒████▄    ██ ▀█   █    ▓█   ▀▒██  ██▓█   ▀
░ ▓██▄  ▒██▀▀██▒██░  ██░██   █▒██  ▀█▄ ▓██  ▀█ ██▒   ▒███   ▒██ ██▒███
  ▒   ██░▓█ ░██▒██   ██░▓█▄  █░██▄▄▄▄██▓██▒  ▐▌██▒   ▒▓█  ▄ ░ ▐██▓▒▓█  ▄
▒██████▒░▓█▒░██░ ████▓▒░▒████▓ ▓█   ▓██▒██░   ▓██░   ░▒████▒░ ██▒▓░▒████▒
▒ ▒▓▒ ▒ ░▒ ░░▒░░ ▒░▒░▒░ ▒▒▓  ▒ ▒▒   ▓▒█░ ▒░   ▒ ▒    ░░ ▒░ ░ ██▒▒▒░░ ▒░ ░
░ ░▒  ░ ░▒ ░▒░ ░ ░ ▒ ▒░ ░ ▒  ▒  ▒   ▒▒ ░ ░░   ░ ▒░    ░ ░  ▓██ ░▒░ ░ ░  ░
░  ░  ░  ░  ░░ ░ ░ ░ ▒  ░ ░  ░  ░   ▒     ░   ░ ░       ░  ▒ ▒ ░░    ░
      ░  ░  ░  ░   ░ ░    ░         ░  ░        ░       ░  ░ ░       ░  ░
                        ░                                  ░ ░  v1.3.0

\033[1;m
            \033[1;31mShodan Eye v1.3.0\033[0m

    ✓ The author is not responsible for any damage, misuse of the information.
    ✓ Shodan Eye shall only be used to expand knowledge and not for
      causing malicious or damaging attacks.
    ✓ Just remember, Performing any hacks without written permission is illegal ..!

            Author:  Jolanda de Koff Bulls Eye
            Github:  https://github.com/BullsEye0
            Website: https://HackingPassion.com

            \033[1;31mHi there, Shall we play a game..?\033[0m 😃
        """)

banner2 = ("""

\033[1;31m


   ▄▄▄▄▄    ▄  █ ████▄ ██▄   ██      ▄       ▄███▄ ▀▄    ▄ ▄███▄
  █     ▀▄ █   █ █   █ █  █  █ █      █      █▀   ▀  █  █  █▀   ▀
▄  ▀▀▀▀▄   ██▀▀█ █   █ █   █ █▄▄█ ██   █     ██▄▄     ▀█   ██▄▄
 ▀▄▄▄▄▀    █   █ ▀████ █  █  █  █ █ █  █     █▄   ▄▀  █    █▄   ▄▀
              █        ███▀     █ █  █ █     ▀███▀  ▄▀     ▀███▀
             ▀                 █  █   ██                       v1.3.0

                              ▀
\033[1;m
        \033[1;31mShodan Eye v1.3.0\033[0m

    ✓ The author is not responsible for any damage, misuse of the information.
    ✓ Shodan Eye shall only be used to expand knowledge and not for
      causing malicious or damaging attacks.
    ✓ Just remember, Performing any hacks without written permission is illegal ..!

            Author:  Jolanda de Koff Bulls Eye
            Github:  https://github.com/BullsEye0
            Website: https://HackingPassion.com

            \033[1;31mHi there, Shall we play a game..?\033[0m 😃
        """)

choi = (banner1, banner2)
print (random.choice(choi))
time.sleep(0.5)


#data = input("\n[+] \033[34mDo you like to save the output in a file? \033[0m(Y/N) ").strip()
#l0g = ("")


#def logger(data):
    #file = open((l0g) + ".txt", "a")
    #file.write(data)
    #file.close()


#if data.startswith("y" or "Y"):
    #l0g = input("\n[~] \033[34mGive the file a name: \033[0m ")
    #print ("\n" + "  " + "»" * 78 + "\n")
    #logger(data)
#else:
    #print ("[!] \033[34mSaving is skipped\033[0m")
    #print ("\n" + "  " + "»" * 78 + "\n")


def showdam():
    api = shodan.Shodan(shodan_api_key)
    time.sleep(0.4)

    limit = 888  # Just a number
    counter = 1

    try:
        #print ("[~] \033[34mChecking Shodan.io API Key... \033[0m")
        #api.search("b00m")
        #print ("[✓] \033[34mAPI Key Authentication:\033[0m SUCCESS..!")
        #time.sleep(0.5)
        #b00m = input("\n[+] \033[34mEnter your keyword(s):\033[0m ")
        counter = counter + 1
        for banner in api.search_cursor(keyword):
            print ("IP " + (banner["ip_str"]))                                                           
            print ("Banner " + (banner["data"]))
            print (" \n")
            #data = ("\nIP: " + banner["ip_str"]) + ("\nPort: " + str(banner["port"])) + ("\nOrganisation: " + str(banner["org"])) + ("\nLocation: " + str(banner["location"])) + ("\nLayer: " + banner["transport"]) + ("\nDomains: " + str(banner["domains"])) + ("\nHostnames: " + str(banner["hostnames"])) + ("\nData\n" + banner["data"])
            #logger(data)
            time.sleep(0.1)            
            counter += 1
            if counter >= limit:
                exit()

    except KeyboardInterrupt:
            print ("\n")
            print ("\033[1;91m[!] User Interruption Detected..!\033[0")
            time.sleep(0.5)
            print ("\n\n\t\033[1;91m[!] I like to See Ya, Hacking \033[0m😃\n\n")
            time.sleep(0.5)
            sys.exit(1)

    print ("\n\n\tShodan Eye \033[1;91mI like to See Ya, Hacking \033[0m😃\n\n")


# =====# Main #===== #
if __name__ == "__main__":
	shodan_api_key = "GIbxTzlwU6QZ59Pn6hHPlNalKRlCMsWl"
	showdam()

