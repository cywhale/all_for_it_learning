# git submodule 
# refer to https://github.blog/2016-02-01-working-with-submodules/ 
git clone --recursive --progress -- https://github.com/cywhale/openocean.git D:\Gits\openocean
# D:\Gits\openocean
git submodule add https://github.com/jdomingu/ThreeGeoJSON ThreeGeoJSON
git commit -m "ThreeGeoJSON submodule"
git submodule update --init --recursive
git push origin master:master --progress
# git fetch --progress --prune origin
 
