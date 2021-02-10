# find files containing specific text
find ./ -type f -exec grep -l "Text_to_find" {} \;

# list which port being listened
sudo netstat -tulpn | grep LISTEN

# update-alternatives for using different versions (e.g., jar, javac, java...)
sudo update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/openjdk-14/bin/jar 2
sudo update-alternatives --config jar

# -----
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

