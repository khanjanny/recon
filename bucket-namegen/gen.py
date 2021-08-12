#!python3

from sys import argv

SEPARATORS="-."
SUFFIXES_FILE="suffixes.txt"

def main():
    names = []
    if len(argv) > 1:
        prefix = argv[1]
    else:
        prefix = input("prefix (company/app name) : ")
    with open(SUFFIXES_FILE) as f:
        suffixes = f.readlines()
        for suffix in suffixes:
            for separator in SEPARATORS:
                name = '%s%s%s' %(prefix, separator, suffix)
                print(name, end='')
    print(prefix)
    

if __name__ == "__main__":
    exit(main())
