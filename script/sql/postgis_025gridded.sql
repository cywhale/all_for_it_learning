/* a similar version of ST_CreateFishnet but output longitude (-180-180), latitude, lon (0-360), lat */
CREATE OR REPLACE FUNCTION ST_CreateGrid(
        nrow integer, ncol integer,
        xsize float8, ysize float8,
        x0 float8 DEFAULT 0, y0 float8 DEFAULT 0,
        OUT "row" integer, OUT col integer,
        OUT longitude float8, OUT latitude float8, OUT lon float8, OUT lat float8, 
        OUT geom geometry)
    RETURNS SETOF record AS
$$
SELECT i + 1 AS row, j + 1 AS col, 
       $5 + $3 * 0.5 + j * $3 AS longitude, $6 + $4 * 0.5 + i * $4 AS latitude,  
       CASE WHEN ($5 + $3 * 0.5 + j * $3 )>=0 THEN $5 + $3 * 0.5 + j * $3 ELSE $5 + $3 * 0.5 + j * $3 + 360 END AS lon,
       $6 + $4 * 0.5 + i * $4 AS lat,
       ST_Translate(cell, j * $3 + $5, i * $4 + $6) AS geom
FROM generate_series(0, $1 - 1) AS i,
     generate_series(0, $2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||$4||', '||$3||' '||$4||', '||$3||' 0,0 0))')::geometry AS cell
) AS foo;
$$ LANGUAGE sql IMMUTABLE STRICT;

CREATE TABLE grid_025gr AS SELECT * FROM ST_CreateGrid(720,1440,0.25,0.25,-180,-90);
UPDATE grid_025gr SET geom = ST_SetSRID (geom, 4326);
CREATE INDEX grid_025gr_geom ON grid_025gr USING gist (geom);
ALTER TABLE grid_025gr ADD gid serial PRIMARY KEY;

/* check consistency of lon/at between tables */
select distinct T.lon as tlon, T.lat as tlat, G.lon as glon, G.lat as glat from grid_025gr G FULL OUTER JOIN td T ON G.lat = T.lat and G.lon= T.lon;


CREATE DATABASE marineheatwave
ENCODING = 'UTF8'
TEMPLATE = template0
LC_COLLATE = 'zh_TW.utf8'
LC_CTYPE = 'zh_TW.utf8';

/* psql -U postgres -d marineheatwave */
CREATE EXTENSION dblink;
/* create /var/lib/postgresql/.pgpass by https://stackoverflow.com/questions/16786011/postgresql-pgpass-not-working 
   https://www.postgresql.org/docs/current/contrib-dblink-connect.html
*/
SELECT dblink_connect('conn1', 'hostaddr=127.0.0.1 port=5432 dbname=postgres user=postgres');

CREATE TABLE td AS 
(SELECT * FROM dblink('conn1','SELECT G.gid, T.lon, T.lat, T.distance, T.date FROM grid_025gr G JOIN td T ON G.lat = T.lat and G.lon= T.lon') 
 AS td2(gid integer, lon float8, lat float8, distance float8, date date));
 
CREATE TABLE sst_anomaly_without_detrend AS 
(SELECT * FROM dblink('conn1','SELECT G.gid, S.lon, S.lat, S.sst_anomaly, S.date, S.level FROM grid_025gr G JOIN sst_anomaly_without_detrend S ON G.lat = S.lat and G.lon= S.lon') 
 AS sst2(gid integer, lon float8, lat float8, sst_anomaly float8, date date, level int4));

CREATE TABLE threshold_anomaly_without_detrend AS 
(SELECT * FROM dblink('conn1','SELECT G.gid, H.lon, H.lat, H.ano_1, H.ano_2, H.ano_3, H.ano_4, H.ano_5, H.ano_6, H.ano_7, H.ano_8, H.ano_9, H.ano_10, H.ano_11, H.ano_12 FROM grid_025gr G JOIN threshold_anomaly_without_detrend H ON G.lat = H.lat and G.lon= H.lon') 
 AS th2(gid integer, lon float8, lat float8, ano_1 float8, ano_2 float8, ano_3 float8, ano_4 float8, ano_5 float8, ano_6 float8, ano_7 float8, ano_8 float8, ano_9 float8, ano_10 float8, ano_11 float8, ano_12 float8));
 
SELECT dblink_disconnect('conn1');

create extension POSTGIS;

/* create a smaller (without lon/lat) 0.25-gridded Fishnet for marineheatwave
CREATE OR REPLACE FUNCTION ST_CreateGrid2(
        nrow integer, ncol integer,
        xsize float8, ysize float8,
        x0 float8 DEFAULT 0, y0 float8 DEFAULT 0,
        OUT "row" integer, OUT col integer,
        OUT longitude float8, OUT latitude float8,
        OUT geom geometry)
    RETURNS SETOF record AS
$$
SELECT i + 1 AS row, j + 1 AS col, 
       $5 + $3 * 0.5 + j * $3 AS longitude, $6 + $4 * 0.5 + i * $4 AS latitude,  
       ST_Translate(cell, j * $3 + $5, i * $4 + $6) AS geom
FROM generate_series(0, $1 - 1) AS i,
     generate_series(0, $2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||$4||', '||$3||' '||$4||', '||$3||' 0,0 0))')::geometry AS cell
) AS foo;
$$ LANGUAGE sql IMMUTABLE STRICT;

CREATE TABLE grid_025gr AS SELECT * FROM ST_CreateGrid2(720,1440,0.25,0.25,-180,-90);
UPDATE grid_025gr SET geom = ST_SetSRID (geom, 4326);
CREATE INDEX grid_025gr_geom ON grid_025gr USING gist (geom);
ALTER TABLE grid_025gr ADD gid serial PRIMARY KEY;
