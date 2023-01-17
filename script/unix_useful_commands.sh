# find files containing specific text
find ./ -type f -exec grep -l "Text_to_find" {} \;

# find files older than 100days and move
find . -name "test*" -mtime +100 -exec mv {} /tmp/ \;

# compress all and remove original files
sudo tar -zvcf /media/disk1/cmd/tmp_bak/bak_2022_log.tar.gz ./2022* --remove-files

# match all 3 character word starting with 'b' and ending in 't' 
# https://www.cyberciti.biz/faq/grep-regular-expressions/
grep '\<b.t\>' filename

# dist-upgrade meet disk full (/boot) error or Write error : cannot write compressed block 
df -h | grep boot
uname -r #check current kernel used
dpkg -l | tail -n +6 | grep -E 'linux-image-[0-9]+' | grep -Fv $(uname -r) #list all kernels existed
ls -lh /boot/ #check if older initrd.img-xxx version still existed or not?
sudo update-initramfs -d -k 5.4.0-91-generic #if it's a not-wanted version of kernel
sudo dpkg --purge linux-modules-extra-5.4.0-91-generic linux-image-5.4.0-91-generic #carefully check version number and purge it
# if encouter Removing symbolic link initrd.img.old  you may need to re-run your boot loader
# sudo update-grub
sudo apt --fix-broken install
sudo apt autoremove

# list which port being listened
sudo netstat -tulpn | grep LISTEN

# clear disk https://itsfoss.com/free-up-space-ubuntu-linux/
journalctl --disk-usage
sudo journalctl --vacuum-time=10d #clear logs older than 10 days
# get old versions of snap-installed software
du -h /var/lib/snapd/snaps
snap list --all | awk '/disabled/{print $1, $3}'
set -eu
sudo snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

# update-alternatives for using different versions (e.g., jar, javac, java...)
sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/openjdk-14/bin/jar 2
sudo update-alternatives --config jar

# after sudo apt-get update && upgrade
# sudo apt install update-manager-core
# sudo sudo do-release-upgrade
# Got some errors libblas3:amd64 (3.7.1-4ubuntu1) ... update-alternatives: Error:  /usr/lib/x86_64-linux-gnu/libblas.so.3 已由 libblas.so.3 管理
 sudo mv /var/lib/dpkg/alternatives/libblas.so*.* ~/temp/
sudo dpkg --configure -a
sudo apt-get install -f

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

