#!/bin/bash

GFS_DATE="20201113"
GFS_TIME="00"; # 00, 06, 12, 18
RES="1p00" # 0p25, 0p50 or 1p00
BBOX="leftlon=0&rightlon=360&toplat=90&bottomlat=-90"
LEVEL="lev_10_m_above_ground=on"
#correct https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20201113/00/
# https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?dir=%2Fgfs.2020111300 cause
# Directory is not accessible: /common/data/model/com/gfs/prod/gfs.2020111300
#old https://nomads.ncep.noaa.gov/txt_descriptions/grib_filter_doc.shtml
#http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs.pl?file=gfs.t12z.pgrbf12.grib2&lev_500_mb=on&var_TMP=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&showurl=&dir=%2Fgfs.2009020612
#http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs.pl?file=gfs.t00z.pgrbf12.grib2&lev_10_mb=on            &leftlon=0&rightlon=360&toplat=90&bottomlat=-90         &dir=%2Fgfs.2019091600
#http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?file=gfs.t00z.pgrb2.1p00.f000&lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&dir=%2Fgfs.${YYYYMMDD}00
#https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?file=gfs.t00z.pgrb2.1p00.f000&lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&dir=%2Fgfs.${YYYYMMDD}%2F00
#GFS_URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_${RES}.pl?file=gfs.t${GFS_TIME}z.pgrb2.${RES}.f000&${LEVEL}&${BBOX}&dir=%2Fgfs.${GFS_DATE}${GFS_TIME}"
GFS_URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_${RES}.pl?file=gfs.t${GFS_TIME}z.pgrb2.${RES}.f000&${LEVEL}&dir=%2Fgfs.${GFS_DATE}%2F${GFS_TIME}"
#GFS_URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_${RES}.pl?dir=%2Fgfs.${GFS_DATE}${GFS_TIME}"
#GFS_URL="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${GFS_DATE}/${GFS_TIME}/"
echo "Download from: ${GFS_URL}"
curl "${GFS_URL}&var_UGRD=on" -o utmp.grib
curl "${GFS_URL}&var_VGRD=on" -o vtmp.grib

grib_set -r -s packingType=grid_simple utmp.grib utmp.grib
grib_set -r -s packingType=grid_simple vtmp.grib vtmp.grib

printf "{\"u\":`grib_dump -j utmp.grib`,\"v\":`grib_dump -j vtmp.grib`}" > tmp.json

#rm utmp.grib vtmp.grib

DIR=`dirname $0`
echo 'Now execute: ${DIR}/prepare.js ${1}/${GFS_DATE}${GFS_TIME}'
node ${DIR}/prepare.js ${1}/${GFS_DATE}${GFS_TIME}

#rm tmp.json
