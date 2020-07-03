# Dockerize opencpu
# just follow https://hub.docker.com/r/opencpu/rstudio
docker pull opencpu/rstudio

## Deploy opencpu/studio
docker run -t --name ocpu -p 8000:80 -p 8004:8004 opencpu/rstudio

## install some R packages in opencpu/rstudio
## by external source, use docker cp
docker cp YOUR_package.tar.gz ocpu:/root/
## by install. packages from cran: may need re-run ducker by --net=host if cannot access network 
docker exec -it ocpu /bin/bash
# sudo R
# install.packages()
# quit()
# exit
docker commit -c "CMD service cron start && /usr/lib/rstudio-server/bin/rserver && apachectl -DFOREGROUND" ocpu opencpu/rstudio

# Dockerize postgresql
# Store data: https://github.com/docker-library/docs/tree/master/postgres#pgdata
# Postgres in docker, setting in /var/lib/postgresql/data
# start postgres: pg_ctl -D /var/lib/postgresql/data -l logfile start
docker pull postgres
# or want postgis
docker pull mdillon/postgis
# or by Dockerfile https://github.com/cywhale/all_for_it_learning/blob/master/dockerfile_postgis25
docker build --network host -t pgis ./ 
# -----------------------------------------------------------------------------------------
docker images
## REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
## postgres            latest              cf879a45faaa        5 days ago          394MB
## pgis                latest              6b907f43daf0        10 minutes ago      572MB

# initdb user see aboving dockerfile
docker run                           \
  -p YOUR_PORT:5432                  \
  -e POSTGRES_USER=YOUR_USER         \
  -e POSTGRES_PASSWORD=YOUR_PASSWORD \
  -v YOUR_DATA_DIR/pgdata:/var/lib/postgresql/data \
  --name pgis -d pgis

## 5c13abf3e5ecce84e8eaf1e4ba0d3488f8825c44d9076e3f82de86fd926a26f2
docker ps
## CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
## 5c13abf3e5ec        pgis                "docker-entrypoint.s…"   5 seconds ago       Up 3 seconds        0.0.0.0:8432->5432/tcp                                  pgis

# Q1: docker exec in bash CANNOT store data, lost new user and database after docker commit
# -----------------------------------------------------------------------------------------
docker exec -it pgis bash
## if need locale zh_TW.utf8
# locale-gen zh_TW.UTF-8
# dpkg-reconfigure locales

psql -U postgres ## or user create in init-user-db.sh
## psql (12.1 (Debian 12.1-1.pgdg100+1))
## postgres=# (psql command-line)

CREATE USER user_namexx  with LOGIN password 'YOUR_PASSWORD' CREATEDB;
create database your_dbxx encoding='UTF8' TEMPLATE = template0 LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';
# exit
# psql -U postgres -d your_dbxx
# ALTER SCHEMA public OWNER TO user_namexx;
GRANT ALL privileges on database your_dbxx to user_namexx;
exit
exit

docker commit pgis pgis #:tag if need tag

# -----------------------------------------------------------------------------------------
# plumber API
# (Not work: Download file from plumber GET API within docker container got error 500
# Dockerfile from trestletech/plumber
# RUN R -e "install.packages(c('Your_Pkgs'))"
# COPY ./run_Your_App.R /root/
# CMD ["/root/run_Your_App.R"]
# in run_Your_App.R
# function(...) {
#    fs <- file.path(tempdir(), "data.csv")
#    fwrite(dt, fs)
#    include_file(fs, res, "text/csv")
# }
# ######## It can only work without Docker, failed if running within docker ###############
docker build --network host -t plumb ./
docker run -v /tmp/Your_app_dir:/tmp -it --rm --name plumb -p 8001:8000 -d plumb

# -----------------------------------------------------------------------------------------
# (to be continued)
# -----------------------------------------------------------------------------------------
#Deploy shiny: docker run -P --name testss --link testpg:testpg -p 8038:3838 testss:corona /usr/bin/shiny-server

## Deploy shiny on shinyproxy: 
# java -jar shinyproxy-2.3.0.jar

