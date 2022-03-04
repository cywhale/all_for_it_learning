#!/bin/sh
# (Need to check newest development of timescaleDB and postgresql) When upgrade a new postgresql with timescaleDB
# sudo su postgres
# cat this file and cd /home/username/tmp (so that postgres user can write log file in public tmp
# then directly execute /usr/..pg_upgrade ... --check must check first!! after check ok remove --check
# ref: https://www.kostolansky.sk/posts/upgrading-to-postgresql-12/
# but not work with timescaleDB: https://github.com/timescale/timescaledb/issues/1844
# even if a -O timescaledb.restoring = 'on' now work https://github.com/timescale/timescaledb/commit/730822127d3acda1319918f75d55965528b147f0
# BTW, stop/start specific version of postgresql
# sudo pg_lsclusters
# sudo pg_ctlcluster 12 main stop #12 is your version
/usr/lib/postgresql/12/bin/pg_upgrade \
  --old-datadir=/var/lib/postgresql/11/main \
  --new-datadir=/var/lib/postgresql/12/main \
  --old-bindir=/usr/lib/postgresql/11/bin \
  --new-bindir=/usr/lib/postgresql/12/bin \
  --old-options '-c config_file=/etc/postgresql/11/main/postgresql.conf' \
  --new-options '-c config_file=/etc/postgresql/12/main/postgresql.conf' \
  --check

## This file should be revised. Just backup ##
