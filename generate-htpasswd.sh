#!/usr/bin/env bash
# Script that generates .htpasswd
# Tested with nginx
# 
# USAGE : generate-htpasswd.json /path/to/config/json /path/to/.htpasswd
# (!!!) REQUIRES htpasswd, jq & oathtool 

# VARIABLES
# Username used for HTTP AUTH
user=$(jq -r '.user' $cfgFile)
# Secret to generate TOTP
secret=$(jq -r '.secret' $cfgFile)

# READ INPUT
cfgFile=$1
htpasswdFile=$2

# Checking that .htpasswd exist. Otherwise htpasswd will ask to use -c flag
cat $htpasswdFile > /dev/null || touch $htpasswdFile
# Infinite loop for generating new .htpasswd every 30s
while :
do
  htpasswd -b $htpasswdFile $user $(oathtool --totp -s 1800 --base32 $secret)
  sleep 30s
done

