#!/bin/bash

# Check if user is Kali
if [[ $(whoami) == "kali" ]]; then
   echo "You are currently running as the $(whoami) user"
   echo "This script must be run as the root user, in order to replace the default kali user"
   echo "Please copy and paste the two commands below to set the root password and to logout"
   echo "After that you can login as root and run this script again"
   echo ""
   echo "sudo passwd root"
   echo "logout"
   exit 1
fi\

# Check if user is Root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Ask the user for login details
echo "Set your desired username and password"
read -p 'Username: ' uservar

killall -u kali

usermod -l $uservar kali
usermod -m -d /home/$uservar $uservar

passwd $uservar

# Run updates
apt update
apt upgrade -y
apt dist-upgrade -y

apt install vim build-essential apt-transport-https axel libsasl2-dev python-dev libldap2-dev libssl-dev kali-desktop-gnome -y

apt autoremove

# Install Joplin & Google Chrome
runuser -l $uservar -c "wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash"
runuser -l $uservar -c "cd /home/${uservar}/Downloads && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

apt install /home/$uservar/Downloads/google-chrome-stable_current_amd64.deb -y

# Install Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt update
apt install sublime-text -y

# Install latest burp suite
runuser -l $uservar -c "cd /home/${uservar}/Downloads && curl --header 'Host: portswigger.net' --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --referer 'https://portswigger.net/burp/releases/professional-community-2021-8-4' --cookie 'SessionId=CfDJ8E%2Bwz0j835xPn7BOifDmT9Ll3pv0cz33oybtmJQgyPs4JVEBAgLDF0DHOaNQiHWWZfwy6gOSv8eJUg43TWm%2FzD6j459errefShcsjLiU7%2Bylxn%2B97nxa%2B3lR8YNKGFVRJkzOSnW6Qqy0aCIncFnjabmVrGtp1kqCMOz2hkiAIfVc' --header 'Upgrade-Insecure-Requests: 1' --header 'Sec-Fetch-Dest: document' --header 'Sec-Fetch-Mode: navigate' --header 'Sec-Fetch-Site: same-origin' --header 'Sec-Fetch-User: ?1' 'https://portswigger.net/burp/releases/download?product=community&version=2021.8.4&type=Linux' --output 'burpsuite_community_linux_v2021_8_4.sh'"
runuser -l $uservar -c "cd /home/${uservar}/Downloads && /home/${uservar}/burpsuite_community_linux_v2021_8_4.sh"

# Install tmux logging
runuser -l $uservar -c "cd /opt && mkdir tmux-logging"
chown -R $uservar: /opt
git clone https://github.com/tmux-plugins/tmux-logging.git /opt/tmux-logging

runuser -l $uservar -c "cd /home/${uservar} && wget https://raw.githubusercontent.com/samdeviron/tmux.conf/main/.tmux.conf"

# Install /opt tools
runuser -l $uservar -c "cd /opt"
cd /opt
runuser -l $uservar -c "git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git /opt/windows-exploit-suggester"
runuser -l $uservar -c "git clone https://github.com/bitsadmin/wesng.git /opt/wesng"
runuser -l $uservar -c "git clone https://github.com/galkan/crowbar.git /opt/crowbar"
runuser -l $uservar -c "git clone https://github.com/BC-SECURITY/Empire.git /opt/empire"
runuser -l $uservar -c "git clone https://github.com/ropnop/windapsearch.git /opt/windapsearch" 
runuser -l $uservar -c "pip install python-ldap" 
runuser -l $uservar -c "mkdir /opt/tunnel && git clone https://github.com/sensepost/reGeorg.git /opt/tunnel/reGeorg" 

# Install Impacket
apt install python3-pip -y
runuser -l $uservar -c "git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket"
pip3 install -r /opt/impacket/requirements.txt
cd /opt/impacket && python3 /opt/impacket/setup.py install

# Set .zshrc settings
echo "alias ls='ls -lha'" >> /home/${uservar}/.zshrc
echo "export HISTCONTROL=ignoredups" >> /home/${uservar}/.zshrc
echo "export HISTIGNORE='&:ls:[bf]g:exit:history'" >> /home/${uservar}/.zshrc
echo "alias empire-server='cd /opt/empire && /opt/empire/ps-empire server'" >> /home/${uservar}/.zshrc
echo "alias empire-client='cd /opt/empire && /opt/empire/ps-empire client'" >> /home/${uservar}/.zshrc
echo "export PATH='/opt/tunnel/reGeorg:/opt/impacket/impacket:/opt/empire:/opt/windapsearch:/opt/windows-exploit-suggester:/opt/wes-ng:$PATH'" >> /home/${uservar}/.zshrc

touch /home/${uservar}/.hushlogin

echo "Done! Please reboot, login with the new user and disable direct root user login"
