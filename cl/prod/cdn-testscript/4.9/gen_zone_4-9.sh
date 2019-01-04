#!/bin/bash

#--------------------------------------------------------------------
# Name: gen_zone v1.0
# Description: Script to create the zone file to be used with bind9
# Author: Victor Jesus - 2018-03-28
# Versions:
#   1.0 - initial script
#
# Usage:
#   gen_zone [country code] [environment]
# Example:
#   gen_zone de preprod
#   ger_zone nl labe2esi
#--------------------------------------------------------------------
#
# Name: gen_zone v1.2
# Description: Script to create the zone file to be used with bind9
# Author: Leandro Magrassi - 22 May 2018
# Versions:
#   1.2 - initial script
#
# Adapted to 4.8 and 4.9  
#--------------------------------------------------------------------

# ------ PARAMETERS
# CC = Country Code
# E  = Environment
# SUBE = sub envrioment
if [ $# -eq 0 ]; then
	# Defaults
  	CC="cl"
	E="prod"
	SUBE="vtrprod"
	EX="dmdsdp.com"
else
	CC="$1"
	E="$2"
	SUBE="$3"
fi

# --- CHANGE WHEN NEEDED!!!

# --- OBO-F5 entries
declare -a obo_list=("ntp01" "ntp02" "dm" "obodrm" "obotraxis" "oboqbr" "obomsg" "oboacs" "obousage" "omwlogs" "oboxagget" "omwcrash")

# --- OBO-CDN entries
declare -a cdn_list=("omwssu" "omw" "epg" "oboposter" "speedtest" "time" "thumbnail-service")

# --- OBO-CDN new entries
declare -a cdn_list2=("staticqbr-$CC-$E")

#MAXPOD=1
# corrigir -------

# --- CDN entries
#  review = startover
#  dvras = nPVR
#  dvrrb = review buffer
#  replay = replayTV
declare -a cdn_playout_list=("vod" "replay" "dvrrb" "dvras" "review")

# ------ Zone file header
echo "\$ORIGIN $E.$CC.$EX"
echo -e "\$TTL\t3600\t; 1 hour"
echo -e "@\tIN\tSOA\t$E.$CC.$EX. hostmaster.$E.$CC.$EX. ("
echo -e "\t\t\t$(date +%Y%m%d)01\t; serial"
echo -e "\t\t\t3600\t\t; refresh (1 hour)"
echo -e "\t\t\t300\t\t; retry (5 minutes)"
echo -e "\t\t\t3600000\t\t; expire (1000 hours)"
echo -e "\t\t\t3600\t\t; minimum (1 hour)"
echo -e "\t\t\t)"
echo
echo -e "\t\t\tIN\tNS\tns01"
echo -e "\t\t\tIN\tTXT\t\"Change: this is the kit version of $E.$CC.$EX\""
echo
echo -e "ns01\t\t\tIN\tA\t192.168.9.1"
echo -e "ntp01\t\t\tIN\tA\t192.168.9.1"
echo -e "ntp02\t\t\tIN\tA\t$(dig ntp01.$EX a +short)"
echo -e "dm\t\t\tIN\tA\t127.0.0.1"
echo

# ------ Get all VIPs of OBO-F5
echo "; ------ OBO-F5 VIPs >> domain=.$E.$CC.$EX"
for y in "${obo_list[@]}";
do
	ip=$(dig $y.$E.$CC.$EX a +short)
	if [ -z $ip ]; then
		printf "%-23s %-15s %s\n" ";$y" "IN      A" "****** UNABLE TO RESOLVE THIS ENTRY, PLEASE CHECK!!! ******"
	else
		printf "%-23s %-15s %s\n" "$y" "IN      A" "$ip"
	fi
done
echo

# ------ Get OBO-CDN entries
echo "; ------ OBO-CDN entries >> domain=$E.$CC.$EX"
for y in "${cdn_list[@]}";
do
	nome=$(dig $y.$E.$CC.$EX cname +short)
	if [ -z $nome ]; then
		printf "%-23s %-15s %s\n" ";$y" "IN      CNAME" "****** UNABLE TO RESOLVE THIS ENTRY, PLEASE CHECK!!! ******"
	else
		printf "%-23s %-15s %s\n" "$y" "IN      CNAME" "$nome"
	fi
done
echo

echo "; ------ OBO-CDN 4.8 entries >> domain=$SUBE.cdn.$EX "
for y in "${cdn_list2[@]}";
do
	nome=$(dig $y.$SUBE.cdn.$EX cname +short)
	if [ -z $nome ]; then
		printf "%-23s %-15s %s\n" ";$y" "IN      CNAME" "****** UNABLE TO RESOLVE THIS ENTRY, PLEASE CHECK!!! ******"
	else
		printf "%-23s %-15s %s\n" "$y" "IN      CNAME" "$nome"
	fi
done
echo

# ------ Get CDN NEW entries used for playout
echo "; ------ CDN NEW entries 4.8 >> domain=.$SUBE.cdn.$EX"
for y in "${cdn_playout_list[@]}";
do
  for z in {1..1}; # 1 POD
  do
  for x in {1..8}; # 8 PODs
  do
	nome=$(dig wp$x\-pod$z\-$y\-$CC-$E.$SUBE.cdn.$EX cname +short)
	#echo $nome
	#printf "%-23s %-15s %s\n" "wp$x-pod$z-$y-$CC-$E" "IN      CNAME" "$nome"
	if [ -z $nome ]; then
		printf "%-23s %-15s %s\n" ";wp$x-pod$z-$y-$CC-$E" "IN      CNAME" "****** UNABLE TO RESOLVE THIS ENTRY, PLEASE CHECK!!! ******"
	else
		printf "%-23s %-15s %s\n" "wp$x-pod$z-$y-$CC-$E" "IN      CNAME" "$nome"
	fi
  done
  done
  echo
done

# ------ Get CDN NEW vxtoken entries used for playout
echo "; ------ CDN NEW vxtoken >> domain=.$SUBE.cdn.$EX"
for y in "${cdn_playout_list[@]}";
do
  for z in {1..1}; # 1 POD
  do
  for x in {1..8}; # 8 PODS
  do
	nome=$(dig wp$x\-pod$z\-$y\-vxtoken\-$CC-$E.$SUBE.cdn.$EX cname +short)
	#echo $nome
	#printf "%-23s %-15s %s\n" "wp$x-pod$z-$y-$CC-$E" "IN      CNAME" "$nome"
	if [ -z $nome ]; then
		printf "%-23s %-15s %s\n" ";wp$x-pod$z-$y-vxtoken-$CC-$E" "IN      CNAME" "****** UNABLE TO RESOLVE THIS ENTRY, PLEASE CHECK!!! ******"
	else
		printf "%-23s %-15s %s\n" "wp$x-pod$z-$y-vxtoken-$CC-$E" "IN      CNAME" "$nome"
	fi
  done
  done
  echo
done


# ------ Get CDN entries used for playout
echo "; ------ CDN \"old\" entries used for playout >> domain=$E.$CC.$EX"
for y in "${cdn_playout_list[@]}";
do
  for z in {1..1}; # 1 POD
  do
  for x in {1..28}; # 28 PODs
  do
	nome=$(dig wp$x.pod$z.$y.$E.$CC.$EX cname +short)
	#printf "%-23s %-15s %s\n" "wp$x.pod$z.$y" "IN      CNAME" "$nome"
	if [ -z $nome ]; then
		#printf "%-23s %-15s %s\n" ";wp$x.pod$z.$y" "IN      CNAME" "****** UNABLE TO RESOLVE THIS ENTRY, PLEASE CHECK!!! ******"
		a=1
	else
		printf "%-23s %-15s %s\n" "wp$x.pod$z.$y" "IN      CNAME" "$nome"
	fi
  done
  done
  echo
done