#!/bin/bash
# Açıklama : Debian errata parser
#
# Yazar: Arif KIZILTEPE
#         kzltpsgm@gmail.com
#
# Oluşturma Tarihi: 2019-04-26
# Gereksinim;
# apt-get install jq wget curl
# 
# v1.0 
#Temporary çalışma dizini oluşturuluyor

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

if test -d "tmperratafiles"; 
then
    rm -rf tmperratafiles
	mkdir tmperratafiles && cd tmperratafiles && touch deberrata.log
	echo -ne '#                     (0%)\r'
	echo $(date) "ArkTracker is Preparing..."  &>> deberrata.log
else
	mkdir tmperratafiles && cd tmperratafiles && touch deberrata.log
	echo -ne '#                     (0%)\r'
	echo $(date) "ArkTracker is Preparing..."  &>> deberrata.log

fi




echo -ne '#                     (2%)\r'
echo $(date) "Updateable Files are Checking..."  &>> deberrata.log
sleep 2

dpkg --get-selections | xargs apt-cache policy {} | grep -1 Installed | sed -r 's/(:|Installed: |Candidate: )//' | uniq -u | tac | sed '/--/I,+1 d' | tac | sed '$d' | sed -n 1~2p &>> debupdateable.txt
echo bash >> debupdateable.txt

for i in $(cat debupdateable.txt); do
        dpkg --get-selections | grep -m1 $i| xargs apt-cache policy {} | grep -1 Installed &>> deberrata.log
done



echo -ne '#                     (4%)\r'
echo $(date) "Security Tracker Json File is Downloading..."  &>> deberrata.log
sleep 2
wget  https://security-tracker.debian.org/tracker/data/json -O security-tracker.json &>> deberrata.log && 
jq 'keys' security-tracker.json > security-tracker.list



codenm=$(lsb_release -cs) 
jq .[] security-tracker.json  | grep "\"CVE-" > CVE.list
sed -i -e 's/://g' CVE.list
sed -i -e 's/{//g' CVE.list
CVENum=$(wc -l CVE.list | awk '{print $1}' )
Dupablenum=$(wc -l debupdateable.txt | awk '{print $1}')


echo -ne '#                     (8%)\r'
echo $(date) "Found $Dupablenum Updateable Package and $CVENum Security Bug"  &>> deberrata.log
sleep 2

firstp=$(cat debupdateable.txt | head -n 1)


echo -ne "#                     (10%)\r" 
echo $(date) "Checking $firstp Package"  &>> deberrata.log
sleep 2





for a in $(cat debupdateable.txt); do






	
	
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

			jq .$a.$r  security-tracker.json  | grep $urgency && echo $a $r
			#jq '.$a.$r.releases.buster , select( .urgency == "unimportant" )' security-tracker.json

		done
	fi

done
echo -ne '#######################   (100%)\r'
echo -ne '\n'


