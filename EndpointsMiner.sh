#!/bin/bash
cat << "EOF"

 ______           _             _       _       __  __ _                 
|  ____|         | |           (_)     | |     |  \/  (_)                
| |__   _ __   __| |_ __   ___  _ _ __ | |_ ___| \  / |_ _ __   ___ _ __ 
|  __| | '_ \ / _` | '_ \ / _ \| | '_ \| __/ __| |\/| | | '_ \ / _ \ '__|
| |____| | | | (_| | |_) | (_) | | | | | |_\__ \ |  | | | | | |  __/ |   
|______|_| |_|\__,_| .__/ \___/|_|_| |_|\__|___/_|  |_|_|_| |_|\___|_|   
                   | |                                                   
                   |_|                                                   

EOF

read -p "[Target]~ " target;
read -p "[Dictionary]~ ": dictionary;
read -p "[Folder for JS files]~ " directory;

if [ -z "$target" ] || [ -z "$dictionary" ] || [ -z "$directory" ]
then
    echo "[ERROR] Input can not be blank try again"
    exit 0
fi

main(){

	if  [ -f $dictionary ];
	then
		echo "Initializing..."
		mkdir $directory
		cd $directory
		curl -s "https://web.archive.org/cdx/search/cdx?url=*.$target/*&output=text&fl=original" | egrep "^*.js$" | sort -u >> raw_links.txt
		echo "[*] Raw links gathered."
		for i in $(cat raw_links.txt);do curl -s "https://archive.org/wayback/available?url=$i" | jq '."archived_snapshots"."closest"."url"' |grep -v "null" | xargs ;done  >> $target.txt
		echo "[*] Valid links gathered starting download."
		cat $target.txt | xargs -d '\n' -l1  axel -akn 16 
		echo "[*] Download Completed finding endpoints."
		for w in $(cat $dictionary); do for j in $(ls); do cat $j | grep -o -E "(https?://)?/?[{}a-z0-9A-Z_\.-]{2,}/[{}/a-z0-9A-Z_\.-]+" | grep -v -E "(https?://)|com|net" | grep "$w" | sort -u >> ../$target.final.txt ;done; done;
		echo "Done Final output file has been created with valid endpoints ../$target"
	fi

}

main

