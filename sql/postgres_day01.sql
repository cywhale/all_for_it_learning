/* create a database if having chinese character */

CREATE DATABASE mydb
ENCODING = 'UTF8'
TEMPLATE = template0
LC_COLLATE = 'zh_TW.utf8'
LC_CTYPE = 'zh_TW.utf8';

/* if write a data table by external program (such as R), check data rows, and datatype */

select count(*) from mytbl;
select column_name, data_type from information_schema.columns where table_name = 'mytbl';

/* if wrong type due to batch write into db, initially NA or as boolean, but after that, get real data, causing type conversion error
   Tips: first convert to integer, then double precision */

alter table mytbl alter "mycol1" type double precision USING("mycol1"::integer); 

/* convert datatype to date */

alter table mytbl alter mycol2 type date using(mycol2::date);

/* simple datatype conversion */

alter table mytbl alter mycol3 type text;

/* After batch writing, find some replicated rows or ID */
/* check it */
 select myid, count(*) from mytbl group by myid having count(*) > 1;
 
/* https://dba.stackexchange.com/questions/138320/duplicate-rows-how-to-remove-one
   But indeed, it removes all duplicated ones. Need to find some way that can delete only one */ 
with d as 
  ( select myid, row_number() over (partition by t.myid) as rn 
    from mytbl as t 
  ) 
delete from mytbl as t 
using d 
where d.rn > 1 
  and d.myid = t.myid; 
