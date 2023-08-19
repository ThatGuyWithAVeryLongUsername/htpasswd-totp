# htpasswd-totp

Time-based One-Time Passwords for your webserver!

Protect your web application with a simple bash script without complicated installation and zero bloated frameworks.
## Features

- Relies on standard HTTP Basic access authentication.
- Almost no third party requirements.
- Generates QR-code for fast setup.

## Demo
#### setup.sh
[![asciicast](https://asciinema.org/a/603468.svg)](https://asciinema.org/a/603468)

## Installation

Make sure you have ```qrencode```, ```oathtool```, ```sed```, ```openssl```, ```jq``` and ```htpasswd``` installed on your machine. Almost every Linux distro has it.

```bash
git clone https://github.com/ThatGuyWithAVeryLongUsername/htpasswd-totp.git
cd htpasswd-totp

# Just follow step of setup script
sh ./setup.sh

# It's STRONGLY recommended to assign "Only owner can read" (0600) rights to config.json. 
# Because config contains TOTP secret in plaintext.

chmod 0600 config.json
chown root config.json

# Place your config.json and generate-htpasswd.sh
chmod +x generate-htpasswd.sh
sudo mv config.json /path/to/your/location
sudo mv generate-htpasswd.sh /path/to/your/location

# Run generate-htpasswd.sh to update password
# Examples for cron and systemd available in Examples section
generate-htpasswd.sh config.json /path/to/.htpasswd


```


## FAQ
#### Is this 2FA for webserver?
No, it's not 2FA, in fact it's **one** factor authentication, but with dynamically updated password, calculated with TOTP algorythm. 

I highly recommend to setup [fail2ban](https://www.fail2ban.org/wiki/index.php/Category:HTTP) to exclude bruteforce attempts.

#### What OTP app should I use?
Any app that supports *custom time step size*.

I successfully tested with [Aegis](https://getaegis.app/), [FreeOTP](https://freeotp.github.io/), [FreeOTP+](https://github.com/helloworld1/FreeOTPPlus), [Authenticator Pro](https://github.com/jamie-mh/AuthenticatorPro), [Mauth](https://github.com/X1nto/Mauth), [KeePassDX](https://www.keepassdx.com/) and [KeePassXC](https://keepassxc.org/).

⚠️ Apps that doesn't work: Google's Authenticator, Microsoft's Authenticator, 1-2-Authenticate, Secur and OneTimePass.

#### Why generated TOTPs has 30 minutes time window?
Well, it's because [HTTP Basic access authentication limitations](https://en.wikipedia.org/wiki/Basic_access_authentication). Every connection to web server should be authenticated, with default time step size webserver will ask you to authenticate every 30 seconds.


## Examples
crontab:
```bash
@reboot /opt/htpasswd-totp/generate-htpasswd.sh /opt/htpasswd-totp/config.json /var/www/totp.htpasswd
```
systemd unit:
```bash
[Unit]
Description=TOTP for .htpasswd

[Service]
ExecStart=/opt/htpasswd-totp/generate-htpasswd.sh /opt/htpasswd-totp/config.json /var/www/totp.htpasswd

[Install]
WantedBy=multi-user.target
```
nginx
```bash
location / {
    auth_basic "Auth Required";
    auth_basic_user_file /var/www/totp.htpasswd;
    ...
}
```
