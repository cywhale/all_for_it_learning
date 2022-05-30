#Install 
#(Install specific R version, e.g. 4.0.3)
sudo apt policy r-base
sudo aptitude install --full-resolver r-base=4.0.3-1.2004.0 r-base-core=4.0.3-1.2004.0 r-base-html=4.0.3-1.2004.0 r-recommended=4.0.3-1.2004.0 r-base-dev=4.0.3-1.2004.0
#(Install opencpu follow official website)
## Note: sudo apt install opencpu-full # will install texlive, pandoc, rstudio-server, ... (large)
## Note: sudo apt install opencpu-cache

#DEBUG
sudo tail -f /var/log/kern.log | grep opencpu

#/tmp rw permission
sudo nano /etc/apparmor.d/opencpu.d/custom 
# /tmp/ocpu-temp/** rwmix,
# documentation: https://manpages.ubuntu.com/manpages/xenial/man5/apparmor.d.5.html
sudo service apparmor reload

# weird since Ubuntu20.04/opencpu2.2 saved temp file in /tmp/systemd-private-xxxxxxx/tmp/ocpu-store/...
# tmp files location
sudo nano /etc/opencpu/server.conf.d/tempdir.conf
#{
#  "tempdir" : "/tmp/ocpu-temp" 
#}
## <- it created a /tmp/ocpu-temp/tmp/ocpu-store/... 

#RESTART
sudo apachectl restart
