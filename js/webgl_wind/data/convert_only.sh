#!/bin/bash

GFS_DATE="20201113"
GFS_TIME="00"; # 00, 06, 12, 18
RES="1p00" # 0p25, 0p50 or 1p00
BBOX="leftlon=0&rightlon=360&toplat=90&bottomlat=-90"
LEVEL="lev_10_m_above_ground=on"
GFS_URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_${RES}.pl?file=gfs.t${GFS_TIME}z.pgrb2.${RES}.f000&${LEVEL}&dir=%2Fgfs.${GFS_DATE}%2F${GFS_TIME}"
#echo "Download from: ${GFS_URL}"
#curl "${GFS_URL}&var_UGRD=on" -o utmp.grib
#curl "${GFS_URL}&var_VGRD=on" -o vtmp.grib

#grib_set -r -s packingType=grid_simple utmp.grib utmp.grib
#grib_set -r -s packingType=grid_simple vtmp.grib vtmp.grib

#printf "{\"u\":`grib_dump -j utmp.grib`,\"v\":`grib_dump -j vtmp.grib`}" > tmp.json

#rm utmp.grib vtmp.grib

DIR=`dirname $0`
echo "Now execute: ${DIR}/prepare.js ${1}/${GFS_DATE}${GFS_TIME}"
node ${DIR}/prepare.js ${1}/${GFS_DATE}${GFS_TIME}

#rm tmp.json
