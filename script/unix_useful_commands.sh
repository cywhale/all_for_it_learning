# find files containing specific text
find ./ -type f -exec grep -l "Text_to_find" {} \;

# list which port being listened
sudo netstat -tulpn | grep LISTEN

# update-alternatives for using different versions (e.g., jar, javac, java...)
sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/openjdk-14/bin/jar 2
sudo update-alternatives --config jar

# Change DNS ubuntu16
sudo nano /etc/network/interfaces
# dns-nameservers 1.1.1.1 8.8.8.8 208.67.222.222
sudo /etc/init.d/networking restart
# check: sudo nano /etc/resolv.conf
# if have other additional DNS in resolv.conf, may in other files, just delete it and may need sudo shutdown -r now
#sudo nano /etc/resolvconf/resolv.conf.d/head
#sudo nano /etc/resolvconf/resolv.conf.d/tail
#sudo nano /etc/resolvconf/resolv.conf.d/base
#sudo systemctl status resolvconf.service
# See now which DNS resolved
nslookup www.google.com

# remove iptables prerouting by opencpu (note: https://github.com/biigle/core/discussions/339
# debug why input/output port not works, and see which port tcp i/o
netstat -tulpn
ngrep tcp and port 80
# debug why 80 port no connection
curl -I localhost
wget https://your_host
# debug port 80, 443 usage
sudo netstat -tulpn | grep 80
sudo netstat -tulpn | grep 443
sudo nmap -sS 127.0.0.1 -p 80 

# Find iptables 80,433 prerouting rules and remove them (after remove opencpu...)
sudo iptables -t nat -nvL #just list
sudo iptables -L OUTPUT  -n --line-numbers #according 'Chain' === 'OUTPUT' and listed the rules (under, & limited to this Chain) by line numbers
# Note: -D is delete, and according the list line-number of the rule you want to deleted (assume N, N=1,2,3,...)
sudo iptables -t nat -D OUTPUT N

# if modify /etc/hosts /etc/hostname
sudo systemctl restart systemd-hostnamed
sudo /etc/init.d/networking restart
curl -I localhost

# change static ip
sudo vi /etc/network/interface
sudo ip addr flush eth0
sudo systemctl restart networking.service

# ---- others ----
# Node devs
# bundle analyze
webpack-bundle-analyzer --port 4200 build/stats.json

# 
# WSL2 for win10 (ubuntu20.04)
# VxServ and Xfce4 (startxfce4) trouble shooting in WSL2: https://github.com/cascadium/wsl-windows-toolbar-launcher/blob/master/README.md#troubleshooting
# After Xlaunch, got black screen: euid !=0,directory /tmp/.ICE-unix will not be created
# https://lists.freebsd.org/pipermail/freebsd-questions/2005-May/087042.html
sudo mkdir -m 1777 /tmp/.X11-unix
sudo mkdir -m 1777 /tmp/.ICE-unix
sudo startxfce4

