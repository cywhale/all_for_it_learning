#DAY1
# find resource: https://doc.yonyoucloud.com/doc/chinese_docker/examples/postgresql_service.html
docker pull postgres
docker images
## REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
## postgres            latest              cf879a45faaa        5 days ago          394MB

# initdb with password
docker run --name testpg -e POSTGRES_PASSWORD=YOUR_PASSWORD -d postgres
## f5ed60fc4327d9c7826ece3c8a670e423b855541578483d05e6ff8841ab475e0
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
f5ed60fc4327        postgres            "docker-entrypoint.s…"   3 seconds ago       Up 2 seconds        5432/tcp            testpg

# docker exec in bash
docker exec -it testpg bash
psql -U postgres

## psql (12.1 (Debian 12.1-1.pgdg100+1))
## postgres=# (psql command-line)

CREATE USER user_namexx WITH LOGIN PASSWORD 'passwordxx' CREATEDB;
create database your_dbxx encoding='UTF8' TEMPLATE = template0 LC_COLLATE = 'en_US.utf8' LC_CTYPE = 'en_US.utf8';
exit
psql -U postgres -d your_dbxx
ALTER SCHEMA public OWNER TO user_namexx;
GRANT ALL privileges on database your_dbxx to user_namexx;
exit
exit

docker commit f5ed60fc4327d9c7826ece3c8a670e423b855541578483d05e6ff8841ab475e0 postgres:tagxx

docker run -d --name testpg postgres:tagxx ## TRY link by other docker container




