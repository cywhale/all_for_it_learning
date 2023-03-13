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

/* if gid must be updated from grid_025gr, since sst_anomaly_without_detrend is always updating by external python, see belowing ---- */
/* ---------------------------------------------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION update_anomaly_gid() RETURNS TRIGGER AS $$
BEGIN
    UPDATE sst_anomaly_without_detrend
    SET gid = grid_025gr.gid
    FROM grid_025gr
    WHERE sst_anomaly_without_detrend.lon = grid_025gr.lon
    AND sst_anomaly_without_detrend.lat = grid_025gr.lat;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_anomaly_gid_trigger
AFTER INSERT OR UPDATE ON sst_anomaly_without_detrend
FOR EACH ROW
EXECUTE FUNCTION update_anomaly_gid();

/* ---------------------------------------------------------------------------------------------------------------------------------- */
CREATE DATABASE marineheatwave
ENCODING = 'UTF8'
TEMPLATE = template0
LC_COLLATE = 'zh_TW.utf8'
LC_CTYPE = 'zh_TW.utf8';

/* psql -U postgres -d marineheatwave */
CREATE EXTENSION dblink;
/* create /var/lib/postgresql/.pgpass by https://stackoverflow.com/questions/16786011/postgresql-pgpass-not-working
   https://www.postgresql.org/docs/current/contrib-dblink-connect.html
$sudo nano /var/lib/postgresql/.pgpass
127.0.0.1:5432:USER:DB:PASS
sudo chmod 600 /var/lib/postgresql/.pgpass
sudo chown postgres:postgres /var/lib/postgresql/.pgpass
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

/* create 0.25-gridded Fishnet for marineheatwave */
CREATE TABLE grid_025gr AS SELECT * FROM ST_CreateGrid(720,1440,0.25,0.25,-180,-90);
UPDATE grid_025gr SET geom = ST_SetSRID (geom, 4326);
CREATE INDEX grid_025gr_geom ON grid_025gr USING gist (geom);
ALTER TABLE grid_025gr ADD gid serial PRIMARY KEY;

/* if need change Alter Table xxx owner to xxx, the following not sure works or not?? 
SELECT 'ALTER TABLE '|| schemaname || '."' || tablename ||'" OWNER TO bioer;' FROM pg_tables WHERE NOT schemaname IN ('pg_catalog', 'information_schema') ORDER BY schemaname, tablename;
SELECT 'ALTER SEQUENCE '|| sequence_schema || '."' || sequence_name ||'" OWNER TO bioer;' FROM information_schema.sequences WHERE NOT sequence_schema IN ('pg_catalog', 'information_schema') ORDER BY sequence_schema, sequence_name;
SELECT 'ALTER VIEW '|| table_schema || '."' || table_name ||'" OWNER TO bioer;' FROM information_schema.views WHERE NOT table_schema IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name;
*/
/*
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bioer;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO bioer;
*/

ALTER TABLE td ADD CONSTRAINT td_gid_fkey FOREIGN KEY (gid) REFERENCES grid_025gr (gid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE sst_anomaly_without_detrend ADD CONSTRAINT ano_gid_fkey FOREIGN KEY (gid) REFERENCES grid_025gr (gid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE threshold_anomaly_without_detrend ADD CONSTRAINT thres_gid_fkey FOREIGN KEY (gid) REFERENCES grid_025gr (gid) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
CREATE INDEX row_for_lat_index ON grid_025gr USING btree (row);
CREATE INDEX col_for_lon_index ON grid_025gr USING btree (col);
CREATE INDEX grid025_longitude_index ON grid_025gr USING btree (longitude);
CREATE INDEX grid025_latitude_index ON grid_025gr USING btree (latitude);

create extension timescaledb;
SELECT create_hypertable('td', 'date', migrate_data => true);
SELECT create_hypertable('sst_anomaly_without_detrend', 'date', migrate_data => true);
SELECT set_chunk_time_interval('sst_anomaly_without_detrend', INTERVAL '1 month');
SELECT set_chunk_time_interval('td', INTERVAL '1 month');

CREATE INDEX ano_gid_index ON sst_anomaly_without_detrend (date DESC, gid);
CREATE INDEX td_gid_index ON td (date DESC, gid);
CREATE INDEX ano_level_notnull_index ON sst_anomaly_without_detrend (date DESC, level) WHERE level IS NOT NULL;
VACUUM ANALYZE sst_anomaly_without_detrend;
VACUUM ANALYZE td;

EXPLAIN ANALYZE select T.lon, T.lat, T.distance, T.date, S.sst_anomaly, S.level from sst_anomaly_without_detrend S inner join td T on S.gid = T.gid and S.date = T.date and S.level >= 3;
/* Awful slow...
 Gather  (cost=4641863.73..5035674.58 rows=64474 width=40) (actual time=594559.938..603370.265 rows=238565 loops=1)
   Workers Planned: 8
   Workers Launched: 8
   ->  Parallel Hash Join  (cost=4640863.73..5028227.18 rows=8059 width=40) (actual time=593752.434..601906.968 rows=26507 loops=9)
         Hash Cond: ((t_39.gid = s_1.gid) AND (t_39.date = s_1.date))
         ->  Parallel Append  (cost=0.00..364351.62 rows=3066901 width=32) (actual time=152.075..7196.764 rows=2726141 loops=9)
               ->  Parallel Seq Scan on _hyper_1_39_chunk t_39  (cost=0.00..1928.75 rows=79775 width=32) (actual time=149.678..511.906 rows=135618 loops=1)
               ->  Parallel Seq Scan on _hyper_1_164_chunk t_164  (cost=0.00..1816.65 rows=75165 width=32) (actual time=149.650..495.901 rows=127780 loops=1)
               ...
               ->  Parallel Seq Scan on _hyper_1_401_chunk t_401  (cost=0.00..245.15 rows=10115 width=32) (actual time=165.092..315.900 rows=17195 loops=1)
         ->  Parallel Hash  (cost=4638418.57..4638418.57 rows=163011 width=20) (actual time=593570.948..593572.388 rows=144736 loops=9)
               Buckets: 2097152  Batches: 1  Memory Usage: 87904kB
               ->  Parallel Append  (cost=0.42..4638418.57 rows=163011 width=20) (actual time=33100.773..593490.095 rows=144736 loops=9)
                     ->  Parallel Index Scan Backward using _hyper_2_487_chunk_ano_level_notnull_index on _hyper_2_487_chunk s_1  (cost=0.42..13946.22 rows=6038 width=20) (actual time=32251.954..42900.487 rows=18063 loops=1)
                           Index Cond: (level >= 3)
                     ->  Parallel Index Scan Backward using _hyper_2_936_chunk_ano_level_notnull_index on _hyper_2_936_chunk s_450  (cost=0.42..13902.22 rows=5978 width=20) (actual time=32183.267..38996.690 rows=18755 loops=1)
                           Index Cond: (level >= 3)
                     ->  Parallel Index Scan Backward using _hyper_2_925_chunk_ano_level_notnull_index on _hyper_2_925_chunk s_439  (cost=0.42..13658.50 rows=5645 width=20) (actual time=33972.584..39777.908 rows=17432 loops=1)
                           Index Cond: (level >= 3)
                     ...
                     ->  Parallel Seq Scan on _hyper_2_968_chunk s_482  (cost=0.00..14040.00 rows=8735 width=20) (actual time=10.262..161.194 rows=21066 loops=1)
                           Filter: (level >= 3)
                           Rows Removed by Filter: 1015734
                     ->  Parallel Seq Scan on _hyper_2_969_chunk s_483  (cost=0.00..14040.00 rows=10930 width=20) (actual time=32193.001..32338.571 rows=25738 loops=1)
                           Filter: (level >= 3)
                           Rows Removed by Filter: 1011062
 Planning Time: 8214.459 ms
 JIT:
   Functions: 26316
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 3764.519 ms, Inlining 1182.240 ms, Optimization 184568.529 ms, Emission 109459.001 ms, Total 298974.290 ms
 Execution Time: 603884.467 ms
(1497 rows)                   
*/

SELECT set_chunk_time_interval('sst_anomaly_without_detrend', INTERVAL '3 month');
SELECT set_chunk_time_interval('td', INTERVAL '3 month');
/* Improve after setting new time-ineterval: 3 month
 Gather  (cost=4641863.73..5035674.58 rows=64474 width=40) (actual time=37174.013..39278.116 rows=238565 loops=1)
   Workers Planned: 8
   Workers Launched: 8
   ->  Parallel Hash Join  (cost=4640863.73..5028227.18 rows=8059 width=40) (actual time=36630.867..38356.346 rows=26507 loops=9)
         Hash Cond: ((t_39.gid = s_1.gid) AND (t_39.date = s_1.date))
         ->  Parallel Append  (cost=0.00..364351.62 rows=3066901 width=32) (actual time=0.068..767.093 rows=2726141 loops=9)
               ->  Parallel Seq Scan on _hyper_1_39_chunk t_39  (cost=0.00..1928.75 rows=79775 width=32) (actual time=0.043..30.335 rows=135618 loops=1)
               ...
               ->  Parallel Seq Scan on _hyper_1_401_chunk t_401  (cost=0.00..245.15 rows=10115 width=32) (actual time=0.029..4.552 rows=17195 loops=1)
         ->  Parallel Hash  (cost=4638418.57..4638418.57 rows=163011 width=20) (actual time=36623.418..36623.659 rows=144736 loops=9)
               Buckets: 2097152  Batches: 1  Memory Usage: 87936kB
               ->  Parallel Append  (cost=0.42..4638418.57 rows=163011 width=20) (actual time=32662.617..36544.287 rows=144736 loops=9)
                     ->  Parallel Index Scan Backward using _hyper_2_487_chunk_ano_level_notnull_index on _hyper_2_487_chunk s_1  (cost=0.42..13946.22 rows=6038 width=20) (actual time=32216.431..32241.981 rows=18063 loops=1)
                           Index Cond: (level >= 3)
                     ->  Parallel Index Scan Backward using _hyper_2_936_chunk_ano_level_notnull_index on _hyper_2_936_chunk s_450  (cost=0.42..13902.22 rows=5978 width=20) (actual time=32034.883..32060.795 rows=18755 loops=1)
                           Index Cond: (level >= 3)
                     ...
                     ->  Parallel Seq Scan on _hyper_2_968_chunk s_482  (cost=0.00..14040.00 rows=8735 width=20) (actual time=9.665..153.210 rows=21066 loops=1)
                           Filter: (level >= 3)
                           Rows Removed by Filter: 1015734
                     ->  Parallel Seq Scan on _hyper_2_969_chunk s_483  (cost=0.00..14040.00 rows=10930 width=20) (actual time=32113.661..32241.554 rows=25738 loops=1)
                           Filter: (level >= 3)
                           Rows Removed by Filter: 1011062
 Planning Time: 365.511 ms
 JIT:
   Functions: 26316
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 3297.170 ms, Inlining 741.871 ms, Optimization 182623.868 ms, Emission 110458.458 ms, Total 297121.366 ms
 Execution Time: 39649.694 ms
(1497 rows)
*/

SELECT set_chunk_time_interval('sst_anomaly_without_detrend', INTERVAL '6 month');
SELECT set_chunk_time_interval('td', INTERVAL '6 month');
/* if set interval to 6 month, slightly improved
 Planning Time: 319.493 ms
 JIT:
   Functions: 26316
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 3360.487 ms, Inlining 787.079 ms, Optimization 184226.145 ms, Emission 110643.413 ms, Total 299017.124 ms
 Execution Time: 40309.816 ms
(1497 rows)
*/

/* But for a simpler query index, larger chunk seems preferred
   There is another problem about parallel scan not started and
   Query performance of index scans much slower than parallel scan
   https://dba.stackexchange.com/questions/242918/query-performance-of-index-scans-slower-than-parallel-seq-scan-on-postgres
   
in postgresql.conf, force parallel scan being used:

min_parallel_table_scan_size = 1MB
min_parallel_index_scan_size = 128kB
parallel_setup_cost = 0 ## this is the prerequisites to make the parallelism on
parallel_tuple_cost = 0
$ sudo systemctl restart postgresql
*/
/* use pg_top to monitor parallel workers by 
$apt install pgtop
$pg_top -U xxx -d marineheatwave -W
*/
SELECT set_chunk_time_interval('sst_anomaly_without_detrend', INTERVAL '1 year');
SELECT set_chunk_time_interval('td', INTERVAL '1 year');
/* test */
explain analyze select * from sst_anomaly_without_detrend where gid=171668 AND level >= 1 ORDER by date desc;
/* NOTE: ORDER BY -> cause quicksort, and each chunk (1yr) use 25kB only?
         Actually use _hyper_2_968_chunk_ano_gid_index (ano_gid_index we created)


 Gather Merge  (cost=5300817.90..5300818.08 rows=9 width=36) (actual time=19805.478..19937.106 rows=50 loops=1)
   Workers Planned: 9
   Workers Launched: 9
   ->  Sort  (cost=5300817.74..5300817.74 rows=1 width=36) (actual time=19389.823..19391.804 rows=5 loops=10)
         Sort Key: _hyper_2_968_chunk.date DESC
         Sort Method: quicksort  Memory: 25kB
         Worker 0:  Sort Method: quicksort  Memory: 25kB
         Worker 1:  Sort Method: quicksort  Memory: 25kB
         Worker 2:  Sort Method: quicksort  Memory: 25kB
         Worker 3:  Sort Method: quicksort  Memory: 25kB
         Worker 4:  Sort Method: quicksort  Memory: 25kB
         Worker 5:  Sort Method: quicksort  Memory: 25kB
         Worker 6:  Sort Method: quicksort  Memory: 25kB
         Worker 7:  Sort Method: quicksort  Memory: 25kB
         Worker 8:  Sort Method: quicksort  Memory: 25kB
         ->  Parallel Append  (cost=0.42..5300817.73 rows=1 width=36) (actual time=17113.874..19391.684 rows=5 loops=10)
               ->  Parallel Index Scan using _hyper_2_968_chunk_ano_gid_index on _hyper_2_968_chunk  (cost=0.42..10907.03 rows=1 width=36) (actual time=16410.275..16410.276 rows=0 loops=1)
                     Index Cond: (gid = 171668)
                     Filter: (level >= 1)
                     Rows Removed by Filter: 1
               ->  Parallel Index Scan using _hyper_2_924_chunk_ano_gid_index on _hyper_2_924_chunk  (cost=0.42..10907.03 rows=1 width=36) (actual time=16477.649..16477.649 rows=0 loops=1)
               ...
 Planning Time: 51.463 ms
 JIT:
   Functions: 19440
   Options: Inlining true, Optimization true, Expressions true, Deforming true
   Timing: Generation 2605.941 ms, Inlining 788.042 ms, Optimization 104408.669 ms, Emission 61791.495 ms, Total 169594.148 ms
 Execution Time: 20148.074 ms
(1916 rows)      
*/


