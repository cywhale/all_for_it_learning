#==== Note old postgresql upgrade with timescaledb tricks not work anymore, just use pg_upgrade ====
# BUT cannot use mixed version timescaledb (i.e cannot upgrade old-postgres-with-older-timescaledb to new-postgres-with-newer-timescaledb
# refer: https://github.com/timescale/timescaledb/issues/2009
# refer: https://severalnines.com/blog/upgrading-postgresql-11-postgresql-13-timescaledb-and-postgis-linux-using-pgupgrade/
# refer: https://github.com/timescale/timescaledb/issues/1425
# check your current timescaledb version with $psql -> (in postgres) \dx
# check compatable timescaledb with postgrsql https://docs.timescale.com/self-hosted/latest/upgrades/upgrade-pg/
# install newer timescaledb on linux follow: https://docs.timescale.com/self-hosted/latest/install/installation-linux/
# for example if you install timescaledb-2-postgresql-15 for Postgresql 15, and you want to upgrade Postgresql 12 to 15
# then you need to install timescaledb-2-postgresql-12 for Postgresql 12 too and update all your databases which have timescaledb extension
# for example, if your postgres, tsdb databases have timescaledb extension
sudo -u postgres psql -d postgres -qxc "ALTER EXTENSION timescaledb UPDATE;" #can also run in psql terminal
sudo -u postgres psql -d tsdb -qxc "ALTER EXTENSION timescaledb UPDATE;"
# Then check pg_upgrade --check to see if any other errors!!!
# Note!!! add -O "-c timescaledb.restoring='on'" 
sudo -iu postgres /usr/lib/postgresql/15/bin/pg_upgrade -o "-c config_file=/etc/postgresql/12/main/postgresql.conf" --old-datadir=/var/lib/postgresql/12/main/   -O "-c config_file=/etc/postgresql/15/main/postgresql.conf"  --new-datadir=/var/lib/postgresql/15/main/ --old-bindir=/usr/lib/postgresql/12/bin --new-bindir=/usr/lib/postgresql/15/bin -O "-c timescaledb.restoring='on'" --check

# If no other errors, turn off --check
sudo -iu postgres /usr/lib/postgresql/15/bin/pg_upgrade -o "-c config_file=/etc/postgresql/12/main/postgresql.conf" --old-datadir=/var/lib/postgresql/12/main/   -O "-c config_file=/etc/postgresql/15/main/postgresql.conf"  --new-datadir=/var/lib/postgresql/15/main/ --old-bindir=/usr/lib/postgresql/12/bin --new-bindir=/usr/lib/postgresql/15/bin -O "-c timescaledb.restoring='on'"
## When upgrade successful, it gives:
#Once you start the new server, consider running:
#    /usr/lib/postgresql/15/bin/vacuumdb --all --analyze-in-stages

#Running this script will delete the old cluster's data files:
#    ./delete_old_cluster.sh

#=========================================
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
