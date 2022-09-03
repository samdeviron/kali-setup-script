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

create_user() {
   # Ask the user for login details
   echo "Set your desired username and password"
   read -p 'Username: ' uservar

   killall -u kali

   usermod -l $uservar kali
   usermod -m -d /home/$uservar $uservar

   passwd $uservar

   sed -i "s/Kali/${uservar}/" /etc/passwd
}

install_essentials() {
   # Run updates
   apt update
   apt upgrade -y
   apt dist-upgrade -y

   apt install vim build-essential apt-transport-https axel libsasl2-dev seclists gobuster python2-dev libldap2-dev libssl-dev kali-desktop-gnome terminator flameshot linux-headers-$(uname -r) -y

   apt autoremove
}

install_tmux() {
   # Install tmux logging
   runuser -l $uservar -c "cd /opt && mkdir tmux-logging"
   chown -R $uservar: /opt
   git clone https://github.com/tmux-plugins/tmux-logging.git /opt/tmux-logging
   runuser -l $uservar -c "cd /home/${uservar} && wget https://raw.githubusercontent.com/samdeviron/tmux.conf/main/.tmux.conf"
}

install_sublime() {
   # Install Sublime Text
   wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
   echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
   apt update
   apt install sublime-text -y
}

install_joplin() {
   # Install Joplin
   runuser -l $uservar -c "wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash"
}

install_chrome() {
   # Install Google Chrome
   runuser -l $uservar -c "cd /home/${uservar}/Downloads && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

   apt install /home/$uservar/Downloads/google-chrome-stable_current_amd64.deb -y
}

install_opt() {
   # Install /opt tools
   runuser -l $uservar -c "cd /opt"
   chown -R $uservar: /opt
   cd /opt
   runuser -l $uservar -c "git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git /opt/windows-exploit-suggester"
   runuser -l $uservar -c "git clone https://github.com/bitsadmin/wesng.git /opt/wesng"
   runuser -l $uservar -c "git clone https://github.com/galkan/crowbar.git /opt/crowbar"
   runuser -l $uservar -c "git clone https://github.com/BC-SECURITY/Empire.git /opt/empire"
   runuser -l $uservar -c "git clone https://github.com/ropnop/windapsearch.git /opt/windapsearch" 
   runuser -l $uservar -c "pip install python-ldap" 
   runuser -l $uservar -c "mkdir /opt/tunnel && git clone https://github.com/sensepost/reGeorg.git /opt/tunnel/reGeorg"
   chown -R $uservar: /opt
}

install_impacket() {
   # Install Impacket
   apt install python3-pip -y
   runuser -l $uservar -c "git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket"
   pip3 install -r /opt/impacket/requirements.txt
   cd /opt/impacket && python3 /opt/impacket/setup.py install
}

install_burp() {
   # Install latest burp suite
   runuser -l $uservar -c "cd /home/${uservar}/Downloads && curl --header 'Host: portswigger.net' --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --referer 'https://portswigger.net/burp/releases/professional-community-2021-8-4' --cookie 'SessionId=CfDJ8E%2Bwz0j835xPn7BOifDmT9Ll3pv0cz33oybtmJQgyPs4JVEBAgLDF0DHOaNQiHWWZfwy6gOSv8eJUg43TWm%2FzD6j459errefShcsjLiU7%2Bylxn%2B97nxa%2B3lR8YNKGFVRJkzOSnW6Qqy0aCIncFnjabmVrGtp1kqCMOz2hkiAIfVc' --header 'Upgrade-Insecure-Requests: 1' --header 'Sec-Fetch-Dest: document' --header 'Sec-Fetch-Mode: navigate' --header 'Sec-Fetch-Site: same-origin' --header 'Sec-Fetch-User: ?1' 'https://portswigger.net/burp/releases/download?product=community&version=2021.8.4&type=Linux' --output 'burpsuite_community_linux_v2021_8_4.sh'"
   runuser -l $uservar -c "chmod +x /home/${uservar}/Downloads/burpsuite_community_linux_v2021_8_4.sh && /home/${uservar}/Downloads/burpsuite_community_linux_v2021_8_4.sh"
}

install_vscode() {
   # Install VSCode
   runuser -l $uservar -c "cd /home/${uservar}/Downloads && wget https://az764295.vo.msecnd.net/stable/784b0177c56c607789f9638da7b6bf3230d47a8c/code_1.71.0-1662018389_amd64.deb"
   cd /home/${uservar}/Downloads
   apt install ./code_* -y
}

install_pcloud() {
   # Install Pcloud
   runuser -l $uservar -c "mkdir /home/${uservar}/Applications"
   runuser -l $uservar -c "cd /home/${uservar}/Applications && wget https://p-lux3.pcloud.com/cBZsfshJnZQwH1ExZZZubbov7Z2ZZH30ZkZkkypVZBkZapZFRZtzZQzZ3zZrkZ2zZc7ZWRZsFZTJZd5ZY7Z0FAtXZ8P4pu9lCmV0v3vR8qRq6vRVi1OzX/pcloud"
   runuser -l $uservar -c "chmod +x /home/${uservar}/Applications/pcloud && /home/${uservar}/Applications/pcloud"
}

set_bashrc() {
   # Set .bashrc settings
   echo "alias ls='ls -lha'" >> /home/${uservar}/.bashrc
   echo "export HISTCONTROL=ignoredups" >> /home/${uservar}/.bashrc
   echo "export HISTIGNORE='&:ls:[bf]g:exit:history'" >> /home/${uservar}/.bashrc
   echo "alias empire-server='cd /opt/empire && /opt/empire/ps-empire server'" >> /home/${uservar}/.bashrc
   echo "alias empire-client='cd /opt/empire && /opt/empire/ps-empire client'" >> /home/${uservar}/.bashrc
   echo "export PATH='/opt/tunnel/reGeorg:/opt/impacket/impacket:/opt/empire:/opt/windapsearch:/opt/windows-exploit-suggester:/opt/wes-ng:$PATH'" >> /home/${uservar}/.bashrc
}

set_zshrc() {
   # Set .zshrc settings
   echo "alias ls='ls -lha'" >> /home/${uservar}/.zshrc
   echo "export HISTCONTROL=ignoredups" >> /home/${uservar}/.zshrc
   echo "export HISTIGNORE='&:ls:[bf]g:exit:history'" >> /home/${uservar}/.zshrc
   echo "alias empire-server='cd /opt/empire && /opt/empire/ps-empire server'" >> /home/${uservar}/.zshrc
   echo "alias empire-client='cd /opt/empire && /opt/empire/ps-empire client'" >> /home/${uservar}/.zshrc
   echo "export PATH='/opt/tunnel/reGeorg:/opt/impacket/impacket:/opt/empire:/opt/windapsearch:/opt/windows-exploit-suggester:/opt/wes-ng:$PATH'" >> /home/${uservar}/.zshrc
}

# Create a user?
echo "Would you like to create user? (answer no to install tools only)"
read -p 'Create user? (Y/N): ' create_user_bool
if [[ create_user_bool == "Y" ]]; then
   create_user
else
   uservar=$SUDO_USER
fi

# User
echo "You are currently running this script as: $uservar"

# Install everything?
echo "Would you like to install everything?"
echo "This currently includes: essentials, tmux, sublime, joplin, chrome, opt tools, burp, vscode and bashrc & zshrc files"
read -p 'Install everything? (Y/N): ' create_everything_bool
if [[ $create_everything_bool == "Y" ]]; then
   install_essentials
   install_tmux
   install_sublime
   install_joplin
   install_chrome
   install_opt
   install_burp
   install_vscode
   #install_pcloud
   set_bashrc
   set_zshrc
else
   # Install essentials?
   echo "Would you like to install essentials?"
   read -p 'Install essentials? (Y/N): ' install_essentials_bool
   
   # Install tmux?
   echo "Would you like to install tmux?"
   read -p 'Install tmux? (Y/N): ' install_tmux_bool
   
   # Install sublime?
   echo "Would you like to install sublime?"
   read -p 'Install sublime? (Y/N): ' install_sublime_bool
  
   # Install joplin?
   echo "Would you like to install joplin?"
   read -p 'Install joplin? (Y/N): ' install_joplin_bool
   
    # Install chrome?
   echo "Would you like to install chrome?"
   read -p 'Install chrome? (Y/N): ' install_chrome_bool
   
    # Install opt?
   echo "Would you like to install opt tools?"
   read -p 'Install opt tools? (Y/N): ' install_opt_bool
  
    # Install burp?
   echo "Would you like to install burp?"
   read -p 'Install burp? (Y/N): ' install_burp_bool
   
   # Install vscode?
   echo "Would you like to install vscode?"
   read -p 'Install vscode? (Y/N): ' install_vscode_bool
   
    # Install bashrc and zshrc?
   echo "Would you like to install bashrc and zshrc?"
   read -p 'Install bashrc and zshrc? (Y/N): ' install_rc_bool
  
   if [[ $install_essentials_bool == "Y" ]]; then
      install_essentials
   fi
   
    if [[ $install_tmux_bool == "Y" ]]; then
      install_tmux
   fi
   
    if [[ $install_sublime_bool == "Y" ]]; then
      install_sublime
   fi
   
    if [[ $install_joplin_bool == "Y" ]]; then
      install_joplin
   fi
   
    if [[ $install_chrome_bool == "Y" ]]; then
      install_chrome
   fi
   
    if [[ $install_opt_bool == "Y" ]]; then
      install_opt
   fi
   
    if [[ $install_burp_bool == "Y" ]]; then
      install_burp
   fi
     
    if [[ $install_vscode_bool == "Y" ]]; then
      install_vscode
   fi
    
    if [[ $install_rc_bool == "Y" ]]; then
      set_bashrc
      set_zshrc
   fi
fi

touch /home/${uservar}/.hushlogin

echo "Done! Please reboot, login with the new user and disable direct root user login" | tee /home/$uservar/Desktop/todo.txt
echo "TODO: Add flameshot to keyboard shortcuts" | tee -a /home/$uservar/Desktop/todo.txt
echo "TODO: Change win/ctrl location in gnome settings" | tee -a /home/$uservar/Desktop/todo.txt
echo "TODO: sudo apt-get purge --auto-remove kali-desktop-xfce" | tee -a /home/$uservar/Desktop/todo.txt
