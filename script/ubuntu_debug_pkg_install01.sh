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

# dependency conflicts due to package upgrade and still some other dependency no such corresponding upgrade
# The following packages have unmet dependencies:  ffmpeg : Depends: libavcodec58....no going to be installed problem
# apt-get install -f not work
# try aptitude (and dont accept current dependecy options, otherwise just keep the same conflicts. Then aptitude may try downgrade automatically)
sudo aptitude install ffmpeg
 
