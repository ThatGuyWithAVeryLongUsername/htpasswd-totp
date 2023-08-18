#!/usr/bin/env bash
# Setup script for htpasswd-totp.
# Generates config for htpasswd-totp.sh 
#
# (!!!) REQUIRES qrencode, oathtool, sed, openssl & jq 

# Generating TOTP secret
SECRET=$(openssl rand -hex 5 | base32)

# I have no idea why $HOST doesn't work
TOTPString="otpauth://totp/"$(hostname)"?period=1080&issuer=htpasswd-topt&secret="$SECRET

# Some coloring
RED="\e[31m"
ENDCOLOR="\e[0m"

# Welcome message
echo -e "Hello! This is setup script for htpasswd-totp.\n\nPlease note that generated passwords are valid for ${RED}30 minutes${ENDCOLOR}, unlike regular 30 seconds."
# Print QR-code in terminal
echo -e "Scan this QR with your favorite 2FA app: \n"
qrencode -m 2 -t utf8 <<< $TOTPString

# Aegis, KeePassXC doesn't requre equals on end
echo -e "\nOr type this secret manually:\n\t"$(echo $SECRET | sed 's/=//g')"\n\n${RED}DON'T FORGET TO SETUP 1080 SECOND TIME STEP SIZE${ENDCOLOR}\n"


# Generage config.json
generateConfig () {
  echo "Writing config.json"
  jq -n --arg user "$USER" --arg secret "$SECRET" '$ARGS.named'> config.json
  echo -e "It's ${RED}STRONGLY${ENDCOLOR} recommended to assign \"Only owner can read\" (0600) rights to config.json.\nUse chown and chmod:\n\t chmod 0600 config.json\n\t chown root config.json\t# Replace \"root\" to user who will run the script\n\nAlso you can change \"user\" value in config.json to something else."
}
read -r -p "Do you want to test your TOTP? [y/N] " responce
case "$responce" in
  [yY][eE][sS]|[yY])
    read -p "Type TOTP generated in your app: " TOTPin

    if [ "$TOTPin" -eq "$(oathtool --totp -s 1080 --base32 $SECRET)" ]; then
      echo "Great! You have configured the TOTP app!"
      generateConfig
    else 
      echo "TOTP doesn't match. Please check time settings on your device and/or use supported app." 
    fi
    ;;
   *)
     generateConfig
    ;;
esac
