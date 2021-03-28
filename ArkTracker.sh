#!/bin/bash
# Description : Debian errata parser
#
# Author: Arif KIZILTEPE
#         kzltpsgm@gmail.com
#
# Created Date : 2021-03-28
# Requirement;
# apt-get install jq wget curl
# 
# Betav1.0 


#Coler variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color



echo "Please Choose Urgency Level" 
proc(){

printf "  ${RED}(1)${NC}      High\n"
printf "  ${RED}(2)${NC}      Medium\n"
printf "  ${RED}(3)${NC}      Low\n"
printf "  ${RED}(4)${NC}      unimportant\n"
printf "  ${RED}(0)${NC}      Exit\n"
read -p "Your Choose  :" ur
}
urques(){
while true;
do
	read -p "Do you want to continue (Y/N) :" yn
	if [[ "$yn" = "Y"  ||  "$yn" = "y" ]]
	then
		yn=""
		proc
		break
	elif [[ "$yn" = "N"  ||  "$yn" = "n" ]]
	then
		exit
	else
		echo "Incorrect choice. Try again."
		read -p "Do you want to continue (Y/N) : " yn
	fi
done

}
proc
if [ "$ur" = "0" ]
then
	exit
elif [ "$ur" = "1" ]
then
	urgency="\"high"\"
elif [ "$ur" = "2" ]
then
	urgency="\"medium"\"
elif [ "$ur" = "3" ]
then
	urgency="\"low"\"
elif [ "$ur" = "4" ]
then
	urgency="\"unimportant"\"
else
	echo "Incorrect choice. Try again."
	urques
fi 


echo $(date) "Work directory  is Creating..."
sleep 1
if test -d "tmperratafiles"; 
then
    rm -rf tmperratafiles
	mkdir tmperratafiles && cd tmperratafiles

else
	mkdir tmperratafiles && cd tmperratafiles


fi




echo $(date) "Updateable Files are Checking..." && echo $(date) "Updateable Files are Checking..."  &>> ArkTracker.log
sleep 2

dpkg --get-selections | xargs apt-cache policy {} | grep -1 Installed | sed -r 's/(:|Installed: |Candidate: )//' | uniq -u | tac | sed '/--/I,+1 d' | tac | sed '$d' | sed -n 1~2p &>> debupdateable.txt
for i in $(cat debupdateable.txt); do
        dpkg --get-selections | grep -o $i| xargs apt-cache policy {} | grep -1 Installed | head -n 4 &>> ArkTracker.log 
done



echo $(date) "Security Tracker Json File is Downloading..." && echo $(date) "Security Tracker Json File is Downloading..." &>> ArkTracker.log 
wget  https://security-tracker.debian.org/tracker/data/json -O security-tracker.json &>> deberrata.log && 
jq 'keys' security-tracker.json > security-tracker.list



codenm=$(lsb_release -cs) 
jq .[] security-tracker.json  | grep "\"CVE-" > CVE.list
sed -i -e 's/://g' CVE.list
sed -i -e 's/{//g' CVE.list
CVENum=$(wc -l CVE.list | awk '{print $1}' )
Dupablenum=$(wc -l debupdateable.txt | awk '{print $1}')
firstp=$(cat debupdateable.txt | head -n 1)


echo $(date) "Found $Dupablenum Updateable Package and $CVENum Security Bug" && echo $(date) "Found $Dupablenum Updateable Package and $CVENum Security Bug"  &>> ArkTracker.log 
sleep 3





echo $(date) "Checking $firstp Package"  && echo $(date) "Checking $firstp Package"  &>> ArkTracker.log

for a in $(cat debupdateable.txt); do
	
	echo $(date) "Checking $a Package" && echo $(date) "Checking $a Package" &>> ArkTracker.log


	
	
	if grep -F "$a" security-tracker.list &>> /dev/null
	then
		a="\"$a"\"
		#jq .$a security-tracker.json  | grep "\"CVE-" > CVE.list
		jq ".$a | keys" security-tracker.json > CVE.list
		sed -i -e 's/://g' CVE.list
		sed -i -e 's/,//g' CVE.list
		sed -i -e 's/{//g' CVE.list
		sed -i -e 's/\[//g' CVE.list
		sed -i -e 's/\]//g' CVE.list
		for r in $(cat CVE.list); do
			#r=$(echo ${r} | sed 's/://' | sed 's/{//')  
			RevLookup="$(jq .$a.$r  security-tracker.json  | grep $urgency)"
			if [[ "$RevLookup" ]]; 
			then
				echo -e "\n"
				jq .$a.$r.releases.buster.repositories.buster security-tracker.json | xargs -i echo "Installable Version {}"
				a=$(echo $a |sed  -e 's/"//g')
				dpkg -s $a | grep '^Version:' |sed  -e 's/Version:/'$a' Installed Version/g'
				r=$(echo $r |sed  -e 's/"//g')
				echo "Bug Detail --> https://security-tracker.debian.org/tracker/$r"
			fi
			#jq '.$a.$r.releases.buster , select( .urgency == "unimportant" )' security-tracker.json

		done
	fi
done

echo -e "\nArk Tracker Process Finished. You can see detail $(pwd)/ArkTracer.log"

