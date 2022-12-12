dpkg --get-selections | grep postgres
sudo apt install posgresql-14
psql -U xxx -d xxx
#For all databases that use POSTGIS and TIMESCALEDB, do Drop Extension
#$ DROP EXTENSION POSTGIS; ##NOTE: if use materialized view, maybe need CASCADE
#$ DROP EXTENSION postgis_raster; 
#$ DROP EXTENSION postgis_topology;
#$ DROP EXTENSION timescaledb;  ##Note: cannot use CASCADE, otherwise all data lost
#### https://docs.timescale.com/timescaledb/latest/how-to-guides/uninstall/uninstall-timescaledb/
sudo nano /etc/postgresql/11/main/postgresql.conf
# ---> shared_preload_libraries = ''           # (change requires restart)
# ---> commented #shared_preload_libraries = 'timescaledb'

# https://gorails.com/guides/upgrading-postgresql-version-on-ubuntu-server
sudo systemctl stop postgresql
pg_lsclusters
#### need all down
# 11  main          5432 down   postgres /var/lib/postgresql/11/main          /var/log/postgresql/postgresql-11-main.log
# 14  main_pristine 5433 down   postgres /var/lib/postgresql/14/main_pristine /var/log/postgresql/postgresql-14-main_pristine.log

#STOP or RESTART specific version of postgres
sudo -i -u postgres
postgres@odb37:~$ /usr/lib/postgresql/11/bin/pg_ctl stop -D /var/lib/postgresql/11/main -l /var/log/postgresql/postgresql-11-main.log -s -o  '-c config_file="/etc/postgresql/11/main/postgresql.conf"'

# if you have installed timescaledb or postgis on older PostgreSQL, even you DROP this extension, you still need to install newer version for newer PostgreSQL
# https://docs.timescale.com/install/latest/self-hosted/installation-debian/
sudo apt-get install timescaledb-2-postgresql-14='2.8.1*' timescaledb-2-loader-postgresql-14='2.8.1*'
sudo apt-get install postgresql-14-postgis-3-scripts

sudo pg_renamecluster 14 main main_pristine
sudo pg_upgradecluster 11 main

sudo service postgresql start
sudo pg_dropcluster 11 main --stop
