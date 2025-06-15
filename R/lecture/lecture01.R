#lecture from 中興⼤學統計學研究所 曾聖澧
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

library(gstat)
vg_cloud <- variogram( y ~ 1, loc = ~x1 + x2, data = DATA, cloud = TRUE)
plot(vg_cloud)
bins=cut(vg_cloud$dist, breaks = seq(0, max(vg_cloud$dist), l = 40))
boxplot(vg_cloud$gamma ~ bins, xlab = "", ylab = "Semivariance" ,las=2)

vg_cloud <- variogram( y ~ 1, loc = ~x1 + x2, data = DATA, 
                       cressie=TRUE, cloud = TRUE)
plot(vg_cloud)
boxplot(vg_cloud$gamma ~ bins, xlab = "", ylab = "Semivariance" ,las=2)

sDATA = DATA
coordinates(sDATA) = ~x1+x2
evgm = variogram(y~1, ~x1+x2, DATA)
v1 = fit.variogram(evgm, vgm("Sph")) 
v2 = fit.variogram(evgm, vgm("Exp"))
v3 = fit.variogram(evgm, vgm("Gau")) 
v4 = fit.variogram(evgm, vgm(model="Mat", kappa=2, nugget=0.1))
plot(evgm, v1); plot(evgm, v2); plot(evgm, v3); plot(evgm, v4)

sDATA=DATA
coordinates(sDATA) = ~x1+x2
sgrid = grids [,c("x1","x2")]
coordinates(sgrid) = ~x1+x2
sk <- krige(y ~ 1, location=~x1+x2, data=DATA, 
            newdata=sgrid, model = v4, beta=1.0)
# predicted value
grids$yhat=sk$var1.pred          
levelplot(yhat~x1+x2, data=grids, col.regions =tim.colors (15),
          at= seq(min(grids$yhat),max(grids$yhat),l=16), main="Predicted y")            
# square root of MSPE
grids$sigma=sqrt(sk$var1.var)  
levelplot(sigma~x1+x2, data=grids, col.regions =tim.colors (15),
          at= seq(min(grids$sigma),max(grids$sigma),l=16), main="Rooted MSPE")

sDATA=DATA
coordinates(sDATA) = ~x1+x2
sgrid = grids [,c("x1","x2")]
coordinates(sgrid) = ~x1+x2
ok <- krige(y ~ 1, location=~x1+x2, data=DATA, 
            newdata=sgrid, model = v4)
# predicted value
grids$yhat=ok$var1.pred          
levelplot(yhat~x1+x2, data=grids, col.regions =tim.colors (15),
          at= seq(min(grids$yhat),max(grids$yhat),l=16), main="Predicted y")            
# square root of MSPE
grids$sigma=sqrt(ok$var1.var)  
levelplot(sigma~x1+x2, data=grids, col.regions =tim.colors (15),
          at= seq(min(grids$sigma),max(grids$sigma),l=16), main="Rooted MSPE") 

# Example R code concept from source [70]
library(automap)
sDATA=DATA
coordinates(sDATA) = ~x1+x2 # Define spatial coordinates
fit = autoKrige(y~1, sDATA, sgrid) # Perform ordinary kriging 
#variogrm
plot(fit$exp_var,fit$var_model)
#predicted value
automapPlot(fit$krige_output, zcol = "var1.pred", col=tim.colors(15),
            sp.layout = list("sp.points", sDATA, col="white"), colorkey =TRUE)      
#rooted MSPE
automapPlot(fit$krige_output, zcol = "var1.stdev", col=tim.colors(15),  
            sp.layout = list("sp.points", sDATA, col="white") , colorkey =TRUE)