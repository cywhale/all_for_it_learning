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

# weird since Ubuntu20.04/opencpu2.2 saved temp file in /tmp/systemd-private-xxxxxxx-apache2.service-xxx/tmp/ocpu-store/...
# BUT this private dirctory cannot be seen from others (but can mv to /tmp/ocpu-temp and chown -R www-data:www-data /tmp/ocpu-temp && chmod -R g+rwx /tmp/ocpu-temp)
# Then tmp files location can be changed. But Not do it. I cannot find a good way to specify temp dir...
# sudo nano /etc/opencpu/server.conf.d/tempdir.conf
#{
#  "tempdir" : "/tmp/ocpu-temp" 
#}
## <- it created a /tmp/ocpu-temp/tmp/ocpu-temp/ocpu-store/... (really a mess...)
## Delete /tmp/systemd-private-xxxxxxx-apache2.service-xxx will cause apachectl fail. Stop/disable apache2 and re-enable/start it.

#ERROR in session /ocpu/tmp/x0xxxxxxx (under systempd-private-...)
## Message: <simpleWarning in system("timedatectl", intern = TRUE): running command 'timedatectl' had status 1>
timedatectl #see your timezone
# sudo nano /etc/opencpu/Renviron
# TZ="Asia/Taipei"

#RESTART
sudo apachectl restart
