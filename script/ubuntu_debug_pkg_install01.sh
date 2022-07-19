#yarn install node-gyp "remove_cv_t" error #NodeJS #Webpack
#/home/odbadmin/.cache/node-gyp/16.11.1/include/node/v8-internal.h:492:33: error: ‘remove_cv_t’ is not a member of ‘std’
nano /home/odbadmin/.cache/node-gyp/16.11.1/include/node/v8-internal.h
#and replace remove_cv_t to remove_cv

#CUDA
wget https://developer.download.nvidia.com/compute/cuda/11.6.2/local_installers/cuda-repo-ubuntu2004-11-6-local_11.6.2-510.47.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-6-local_11.6.2-510.47.03-1_amd64.deb 
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt update
sudo apt install cuda

#Python
#vscode jupyter: The kernel failed to start due to the missing module 'prompt_toolkit.formatted_text'. Consider installing this module. View Jupyter [log](command:jupyter.viewOutput) for further details.
#solution: reinstall ipykernel
python3 -m pip uninstall -y jupyter jupyter_core jupyter-client jupyter-console jupyterlab_pygments notebook qtconsole nbconvert nbformat jupyterlab-widgets nbclient ipykernel ipynb
# code & ## let code reinstall ipykernel

#GDAL, R
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
sudo apt-get install --reinstall libudunits2-dev libsqlite3-dev libfontconfig1-dev libgdal-dev libgeos-dev libproj-dev proj-bin proj-data gdal-bin gdal-data python3-gdal
which gdal-config
#/usr/bin/gdal-config
which geos-config
#/usr/bin/geos-config
which proj
#/usr/bin/proj

# Note in: https://rtask.thinkr.fr/installation-of-r-4-0-on-ubuntu-20-04-lts-and-tips-for-spatial-packages/
# conti Note: r-cran-raster will install anoter version: libgdal29 libproj19 r-cran-terra r-cran-leaflet
# NOTE error: libproj or sqlite3 not found in standard or given locations... I download PROJ the same version as 
proj --version #8.2.0
# wget https://download.osgeo.org/proj/proj-8.2.0.tar.gz; tar xvf proj-8.2.0.tar.gz; cd proj-8.2.0; ./configure --prefix=/usr
# /usr/bin/pkg-config --libs proj
# find /usr/lib/pkgconfig proj.pc PROJ version is wrong...why? manually change it...
sudo apt install r-base-dev r-cran-devtools r-cran-rjava 
R
remotes::install_github("r-spatial/sf", configure.args = c("--with-proj-include=/usr/include/", "--with-proj-lib=/usr/lib/", "--with-gdal-config=/usr/bin/gdal-config", "--with-geos-config=/usr/bin/geos-config"))
remotes::install_github("r-spatial/stars", configure.args = c("--with-proj-include=/usr/include/", "--with-proj-lib=/usr/lib/", "--with-gdal-config=/usr/bin/gdal-config", "--with-geos-config=/usr/bin/geos-config"))
remotes::install_github("rspatial/rspatial", configure.args = c("--with-proj-include=/usr/include/", "--with-proj-lib=/usr/lib/", "--with-gdal-config=/usr/bin/gdal-config", "--with-geos-config=/usr/bin/geos-config"))
devtools::install_github("rstudio/leaflet")
#q()
sudo apt install r-cran-gstat r-cran-maps r-cran-mapdata r-cran-ncdf4 r-cran-geor r-cran-ggmap
update.packages(ask = FALSE, checkBuilt = TRUE, lib.loc = "/usr/local/lib/R/site-library")

# and also for getting duplicated gdal
# double free or corruption (out) ==> Aborted (core dumped) # https://github.com/r-spatial/sf/issues/1393
# Please refer this written by Edzer Pebesma: # https://github.com/r-spatial/sf#multiple-gdal-geos-andor-proj-versions-on-your-system
# Multiple GDAL, GEOS and/or PROJ versions on your system
# If you use dynamic linking (installation from source) and have multiple versions of these libraries installed 
# (e.g. one from ubuntugis-unstable, another installed from source in /usr/local/lib) then 
# this will in general not work, even when setting LD_LIBRARY_PATH manually. See here for the reason why.

# Error: ogr2ogr: symbol lookup error: /usr/lib/libgdal.so.30: undefined symbol: GEOSMakeValidWithParams_r
nm -D /usr/lib/libgdal.so.30 | grep -n GEOSMakeValidWithParams_r
# refer (but not reall work, but you can check) https://github.com/OSGeo/gdal/issues/2214 
# apt-cache policy libgdal-dev
# apt-cache policy libproj-dev
# apt-cache policy libgeos-dev
# solution: cmake & make install libgeos (capi) as the same version with libgeos-dev #https://libgeos.org/usage/download/

# First, completely remove gdal from Ubuntu 20.04 # https://lists.osgeo.org/pipermail/gdal-dev/2020-August/052465.html
sudo apt purge $(dpkg -l | grep gdal | awk '{print $2}' | xargs)
sudo apt purge $(dpkg -l | grep geos | awk '{print $2}' | xargs)
sudo apt purge $(dpkg -l | grep libproj | awk '{print $2}' | xargs)
# remove  all installed versions of gdal, geos and proj # https://github.com/r-spatial/sf/issues/1685
sudo apt-get remove libproj-dev:amd64 
sudo apt-get remove libproj19:amd64 
sudo apt-get remove libgeos-dev
sudo apt-get remove libgeos-3.9.0:amd64 
sudo apt-get remove libgdal-dev

# U
# dependency conflicts due to package upgrade and still some other dependency no such corresponding upgrade
# The following packages have unmet dependencies:  ffmpeg : Depends: libavcodec58....no going to be installed problem
# apt-get install -f not work
# try aptitude (and dont accept current dependecy options, otherwise just keep the same conflicts. Then aptitude may try downgrade automatically)
sudo aptitude install ffmpeg

# NOTE MS Server 2008R2 cannot use ODBC Driver 18 under ubuntu20, and ODBC Driver 18 not for Ubuntu16.04 neither
# BUT ODBC Driver 17 can work for Ubuntu16.04, and for remote SQL Server on MS Server 2008 R2
# see installing-the-microsoft-odbc-driver-for-sql-server.md
# https://github.com/MicrosoftDocs/sql-docs/blob/live/docs/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server.md#17


