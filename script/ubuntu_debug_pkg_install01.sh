#debug GDAL spatially-related packages installation
#gdalinfo --version and got 
# GDAL 3.3.2, free(): invalid pointer Aborted (core dumped)
# and will cause mapview install error like:
# configure: error: OGRCoordinateTransformation() does not return a coord.trans: PROJ not available?
# some old source of GDAL, GEOS, PROJ related library coexist in system may cause it.
dpkg -l | grep proj
#libproj-dev:amd64                          7.2.1-1~focal0                              amd64        Cartographic projection library (development files)
#libproj0                                   4.8.0-2ubuntu2                              amd64        Cartographic projection library
#libproj15:amd64                            6.3.1-1                                     amd64        Cartographic projection library
#libproj19:amd64                            7.2.1-1~focal0                              amd64        Cartographic projection library
#apt purge librpoj0 libproj15
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get update
sudo apt-get install --reinstall libudunits2-dev libgdal-dev libgeos-dev libproj-dev proj-bin gdal-bin

# and also for getting duplicated gdal
# double free or corruption (out) ==> Aborted (core dumped) # https://github.com/r-spatial/sf/issues/1393
# Please refer this written by Edzer Pebesma: # https://github.com/r-spatial/sf#multiple-gdal-geos-andor-proj-versions-on-your-system
# Multiple GDAL, GEOS and/or PROJ versions on your system
# If you use dynamic linking (installation from source) and have multiple versions of these libraries installed 
# (e.g. one from ubuntugis-unstable, another installed from source in /usr/local/lib) then 
# this will in general not work, even when setting LD_LIBRARY_PATH manually. See here for the reason why.

# Error: ogr2ogr: symbol lookup error: /usr/lib/libgdal.so.30: undefined symbol: GEOSMakeValidWithParams_r
# refer (but not reall work, but you can check) https://github.com/OSGeo/gdal/issues/2214 
# apt-cache policy libgdal-dev
# apt-cache policy libproj-dev
# apt-cache policy libgeos-dev
# solution: cmake & make install libgeos (capi) as the same version with libgeos-dev #https://libgeos.org/usage/download/

# First, completely remove gdal from Ubuntu 20.04 # https://lists.osgeo.org/pipermail/gdal-dev/2020-August/052465.html
sudo apt purge $(dpkg -l | grep gdal | awk '{print $2}' | xargs)
# remove  all installed versions of gdal, geos and proj # https://github.com/r-spatial/sf/issues/1685
sudo apt-get remove libproj-dev:amd64 
sudo apt-get remove libproj19:amd64 
sudo apt-get remove libgeos-dev
sudo apt-get remove libgeos-3.9.0:amd64 
sudo apt-get remove libgdal-dev


# dependency conflicts due to package upgrade and still some other dependency no such corresponding upgrade
# The following packages have unmet dependencies:  ffmpeg : Depends: libavcodec58....no going to be installed problem
# apt-get install -f not work
# try aptitude (and dont accept current dependecy options, otherwise just keep the same conflicts. Then aptitude may try downgrade automatically)
sudo aptitude install ffmpeg
 
