#!/bin/bash

archivo="$1"

grep --color=never -ohE "{path:\"/[A-Za-z0-9_-]*" $archivo | tee -a paths.txt
grep --color=never -ohE "console.log\(\"[A-Za-z0-9_-. ]*" $archivo | tee -a console.txt

grep --color=never -ohE "get\(\"[A-Za-z0-9_-. ]*" $archivo | tee -a peticiones2.txt
grep --color=never -ohE "post\(\"[A-Za-z0-9_-. ]*" $archivo | tee -a peticiones2.txt
grep --color=never -ohE "put\(\"[A-Za-z0-9_-. ]*" $archivo | tee -a peticiones2.txt
grep --color=never -ohE "patch\(\"[A-Za-z0-9_-. ]*" $archivo | tee -a peticiones2.txt
grep --color=never -ohE "delete\(\"[A-Za-z0-9_-. ]*" $archivo | tee -a peticiones2.txt

sort peticiones2.txt | uniq > peticiones.txt
rm peticiones2.txt

grep --color=never -ohE "graphql\(\{[A-Za-z0-9_-. :$+\"\\(){}]*variables" $archivo | sed 's/\\n/ /g' | sed 's/  */ /g' | sed 's/graphql({//g' | sed 's/,variables/ /g' | sort |uniq |  tee -a queries.txt
	
grep --color=never -ohE "url+\"[A-Za-z0-9_-. ]*" $archivo | tee -a urls2.txt
grep --color=never -ohE "url\+\"[A-Za-z0-9_-. ]*" $archivo | sort | uniq | tee -a urls2.txt
grep --color=never -ohE "Url\+\"[A-Za-z0-9_-. ]*" $archivo | sort | uniq | tee -a urls2.txt
grep --color=never -irao "http://[^ ]*\""  $archivo | tee -a urls2.txt
grep --color=never -irao "https://[^ ]*\""  $archivo | tee -a urls2.txt

sort urls2.txt | uniq > urls.txt
rm urls2.txt
