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

# continue...
