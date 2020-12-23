/* Create 4326 grid of degree 
   https://gis.stackexchange.com/questions/16374/creating-regular-polygon-grid-in-postgis
*/
CREATE OR REPLACE FUNCTION ST_CreateFishnet(
        nrow integer, ncol integer,
        xsize float8, ysize float8,
        x0 float8 DEFAULT 0, y0 float8 DEFAULT 0,
        OUT "row" integer, OUT col integer,
        OUT geom geometry)
    RETURNS SETOF record AS
$$
SELECT i + 1 AS row, j + 1 AS col, ST_Translate(cell, j * $3 + $5, i * $4 + $6) AS geom
FROM generate_series(0, $1 - 1) AS i,
     generate_series(0, $2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||$4||', '||$3||' '||$4||', '||$3||' 0,0 0))')::geometry AS cell
) AS foo;
$$ LANGUAGE sql IMMUTABLE STRICT;

CREATE TABLE grid_1gr AS SELECT * FROM ST_CreateFishnet(180,360,1,1,-180,-90);
UPDATE grid_1gr SET geom = ST_SetSRID (geom, 4326);
CREATE INDEX grid_1gr_geom ON grid_1gr USING gist (geom);
ALTER TABLE grid_1gr ADD gid serial PRIMARY KEY;
ANALYZE VERBOSE grid_1gr;

/* Check SRID of postgis geometry column if your schema is 'public' and table/view is 'grid_1gr'*/
SELECT Find_SRID('public', 'grid_1gr', 'geom');
/* find_srid 
-----------
      4326 */

/* Create a Materialized view to join species distribution data 'taxa_data'*/
CREATE MATERIALIZED VIEW grid_sp as 
SELECT * FROM 
  (select show_name as species, geom from taxa_data) as taxa, 
  (select gid, geom as grid_geom from grid_1gr) as gdt 
WHERE
  ST_Intersects(taxa.geom, gdt.grid_geom);

CREATE INDEX grid_1gr_sp_index ON grid_sp USING btree (species)
CREATE INDEX grid_1gr_sp_geom ON grid_sp USING gist (geom);
ANALYZE VERBOSE grid_sp;

/* Created a Materialized view 'grid_sp' and want to check its data type of each column
https://stackoverflow.com/questions/31119260/column-names-and-data-types-for-materialized-views-in-postgresql
*/
select 
    ns.nspname as schema_name, 
    cls.relname as table_name, 
    attr.attname as column_name,
    trim(leading '_' from tp.typname) as datatype
from pg_catalog.pg_attribute as attr
join pg_catalog.pg_class as cls on cls.oid = attr.attrelid
join pg_catalog.pg_namespace as ns on ns.oid = cls.relnamespace
join pg_catalog.pg_type as tp on tp.typelem = attr.atttypid
where 
ns.nspname = 'public' and
cls.relname = 'grid_05gr_spnum' and
not attr.attisdropped and 
    cast(tp.typanalyze as text) = 'array_typanalyze' and 
    attr.attnum > 0
order by 
    attr.attnum
