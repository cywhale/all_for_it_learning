URL="https://github.com/rspatial/rspatial/raw/refs/heads/master/inst/rds/airqual.rds"
download.file(URL, "airqual.rds")
dat = readRDS("airqual.rds")
keep_column=c("SHORT_NAME", "LATITUDE", "LONGITUDE", "OZDLYAV")
dat = dat[,keep_column]
head(dat)
library(sp); library(sf)
coordinates(dat) = ~LONGITUDE + LATITUDE
proj4string(dat) = CRS('+proj=longlat +datum=WGS84') 
dat=st_as_sf(dat)
dat=st_transform(dat,crs=32610)  #UTM Zone 10N
location=st_coordinates(dat)
DATA=data.frame(x1=location[,"X"],x2=location[,"Y"],
                y=st_drop_geometry(dat)[,"OZDLYAV"])

URL="https://github.com/rspatial/rspatial/raw/refs/heads/master/inst/rds/counties.rds"
download.file(URL, "countries.rds")
CA_map = readRDS("countries.rds")


# 轉為 sf 格式
ca_sf <- st_as_sf(CA_map)

# 儲存為 GeoJSON，方便 Python 讀取
st_write(ca_sf, "ca_map.geojson", delete_dsn=TRUE)

library(stars)
ca_sf=st_as_sf(CA_map)
ca_sf=st_transform(ca_sf,crs=32610)  #UTM Zone 10N
grd=st_as_stars(st_bbox(ca_sf) , dx = 10000, dy= 10000)
grids =st_crop(grd, ca_sf) 
grids = as.data.frame(grids)[!is.na(grids$value),]
colnames(grids) = c("x1","x2","value")
plot(CA_map)
plot(st_crop(grd, ca_sf))



library(fields)
sDATA=DATA
coordinates(sDATA)=~x1+x2
spplot(sDATA, 'y', sp.layout=list("sp.points", as_Spatial(ca_sf), fill = "lightgray"), 
       col.regions=tim.colors(11), cuts=10, pch=20, cex=1.5, colorkey =TRUE)

DATA[,"y"]=DATA[,"y"]*1000
MODEL = lm(y ~ x1 + x2, data = DATA)
summary(MODEL)

grids[,"yhat"] = predict(MODEL, newdata = grids)
library(lattice)
levelplot(yhat~x1+x2, data=grids, col.regions =tim.colors (15),
          at= seq(min(grids$yhat),max(grids$yhat),l=16), main="Predicted y")

library(FNN)
coords = DATA[,c("x1","x2")]
# cross validation and find the best K
cv_value=numeric(30)
for(k in 1:30) 
  cv_value[k]=knn.reg(train = coords, y = DATA[,"y"], k = k)$PRESS
plot( cv_value) 
grids=grids[,c("x1","x2")]
k6_predictions = knn.reg(train = coords, test = grids, y = DATA[,"y"], k = 6)
grids$yhat = k6_predictions$pred
levelplot(yhat~x1+x2, data=grids, col.regions =tim.colors (15),
          at= seq(min(grids$yhat),max(grids$yhat),l=16), main="Predicted y")

library(np)
bw = npregbw(y ~ x1 + x2, data = DATA)  #find the best bandwidth with CV
#bw = npregbw(y ~ x1 + x2, data = DATA,bws=c(500,500), bandwidth.compute=F)
model = npreg(bw)
grids$yhat = predict(model, newdata = grids)
levelplot(yhat~x1+x2, data=grids,  col.regions =tim.colors (15),
          at= seq(min(grids$yhat),max(grids$yhat),l=16), main="Predicted y")