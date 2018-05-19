# Open a nc file and use data.table::CJ, rbindlist to plot monthly environmental factors (Air temperature here)
# NC file here (ERSI): https://goo.gl/UGu7Sh use monthly mean 1979-2018 
# original question: https://www.ptt.cc/bbs/R_Language/M.1526309815.A.F20.html
# original reply: https://www.ptt.cc/bbs/R_Language/M.1526354622.A.065.html

library(data.table)
library(magrittr)
library(ncdf4)
#library(lubridate)
library(units)
library(ggplot2)

infile <- "D:/Env/air/air.2m.mon.mean.nc"
testB <- 4L

nx0 <- nc_open(infile)
print(nx0)

air <- ncvar_get(nx0, "air")
latx0<- ncvar_get(nx0, "lat")
lngx0<- ncvar_get(nx0, "lon")
time<- ncvar_get(nx0, "time") 
tattr <- ncatt_get(nx0, "time") 
units(time) <- make_unit(tattr$units)

datex<- as.POSIXct(time) %>%  as.Date(origin="1800-01-01 00:00") #:0.0") 
lvl <- ncvar_get(nx0, "level")

mair <- apply(air[,,1:testB],c(1,2),function(x) mean(x-273.15, na.rm=T)) #degK -> degC
zt=matrix(mair,ncol=length(latx0),nrow=length(lngx0),byrow=F)
   
image(x=lngx0-180,y=rev(latx0),z=zt[,ncol(zt):1], ## reverse lat to make it increasing
      col = colorRamps::blue2red(128)) #rainbow(128)[50:128])

tout <- rbindlist(lapply(seq_len(testB), function(i) {
  #zt=matrix(air[,,i],ncol=length(latx0),nrow=length(lngx0),byrow=F)
  cbind(CJ(lat=as.numeric(latx), lng=as.numeric(lngx0)-180), 
        airTemp=as.numeric(air[,,i])-273.15,
        date=datex[i])
}))

g1 <- ggplot(data=tout, aes(x=lng, y=lat)) + 
  facet_wrap(~date, ncol=2) +
  geom_tile(aes(fill=airTemp),color=NA) +
  stat_contour(aes(z=airTemp), binwidth=5, bins=10, color="darkgrey") +
  coord_equal() +
  coord_fixed(ratio = 1)+
  scale_fill_gradientn(colours = colorRamps::blue2red(128)) +
  theme(
    panel.background = element_rect(fill="white"),
    panel.border = element_rect(colour = "black", fill=NA, size=0.75),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    strip.background = element_blank(),
    strip.text.y = element_text(angle = 0),#,face = "italic"),
    axis.text.x  = element_text(family = "sans", size = 8),
    axis.title.x = element_blank(), #element_text(family = "sans", size=10),
    axis.title.y = element_blank(), #element_text(family = "sans", size=10, margin(r=0),vjust=0.6), 
    axis.text.y = element_text(family = "sans", size = 8), #element_blank(),
    axis.line.x = element_blank(), #element_line(colour = "black"), 
    axis.line.y = element_blank(),#element_line(colour = "black"), 
    legend.key = element_rect(fill = "transparent", colour = "transparent"),
    legend.text = element_text(family = "sans"), 
    legend.background = element_rect(fill = "transparent", colour = "transparent")#, #"white"),
    #legend.position = c(0.15,0.45)  
  )
  
g1

### use for-loop, 20180519
require(sp)
require(rnaturalearth)

par(mfrow=c(2,2))
for (i in seq_len(testB)) {
  zt=matrix(air[,,i],ncol=length(latx0),nrow=length(lngx0),byrow=F)
  
  image(x=lngx0-180,y=rev(latx0),z=zt[,ncol(zt):1], ## reverse lat to make it increasing
        col = colorRamps::blue2red(128)) #rainbow(128)[50:128])
  
  plot(rnaturalearth::ne_coastline(scale="medium"), add=TRUE)
}
