par(mfrow=c(4,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

set.seed(2024) #try other random seed

n = 100    # sample size
tt = 1:n   # set index t as the regressor 
mu = -5 + 0.1*tt  # trend  
ss = sin(2*pi*tt/12) # seasonality
e = 0.5*rnorm(n)     # noise   

y = mu+ss+e

#pdf(file="sim1.pdf")
par(mfrow=c(4,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))
ts.plot(y, lwd=2)
ts.plot(mu, ylim=range(y), lwd=2)
ts.plot(ss, ylim=range(y), lwd=2)
ts.plot(e, ylim=range(y), lwd=2)

par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))
fit = lm(y~tt)
summary(fit)

ts.plot(y, lwd=2)
abline(fit, lwd=2, col=4)

ts.plot(fit$resid, lwd=2)
abline(h=0, lty=2)
fit1 = lm(fit$resid~ss)
lines(tt,fit1$fitted, lwd=2, col=3)
summary(fit1)

ts.plot(fit1$resid, lwd=2)
abline(h=0, lty=2)

# differencing can remove trend
d1 = diff(y)
ts.plot(d1, lwd=2) 
abline(h=0, lty=2)

d2 = diff(y, lag=12) 
ts.plot(d2, lwd=2)
abline(h=0, lty=2)

par(mfcol=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))
acf(y, 24)
acf(fit$resid, 24)
acf(fit1$resid, 24)

x1 = cos(2*pi*tt/12)
x2 = sin(2*pi*tt/12)
fit2 = lm(y~tt+x1+x2)

summary(fit2) 

fit1a = lm(y~tt+ss)
summary(fit1a)

ts.plot(y, lwd=2)
lines(tt, fit1a$fitted, lwd=2, col=2)
lines(tt, fit2$fitted, lwd=2, col=3)

par(mfrow=c(2,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))
set.seed(2024)

n = 100
sigma.eta = 1
sigma.eps = 1

eta = sigma.eta*rnorm(100) 
mu = cumsum(eta)
y1 = mu+ sigma.eps*rnorm(100)


ts.plot(y1, lwd=2)
lines(1:n, mu, col=3, lwd=2)
legend("topright", legend=c("y(t)","mu(t)"), col=c(1,3), lty=1, lwd=2, bty="n")

acf(y1)


library(astsa)
par(mfrow=c(2,3), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

gtemp = gtemp_land
ts.plot(gtemp); title("gtemp")

acf(gtemp) # acf(gtemp, 50)
title("ACF of gtemp")

#remove trend by regression (linear in time index)
fit1g = lm(gtemp~time(gtemp)) 

summary(fit1g)
names(fit1g)

t1 = time(gtemp)
t2 = t1^2
fit2g = lm(gtemp~t1+t2) 
#fit2 = lm(gtemp~t1+I(t1^2)) 
summary(fit2g)

fit3g = lm(gtemp~t1+I(t1^2)+I(t1^3)) 
summary(fit3g)
c(sd(gtemp), sd(fit1g$resid), sd(fit2g$resid), sd(fit3g$resid))

qq = 5 #smoothing window (bandwidth)
ma.5 = filter(gtemp,filter=rep(1,2*qq+1)/(2*qq+1), sides=2)

qq = 20
ma.20 = filter(gtemp,filter=rep(1,2*qq+1)/(2*qq+1), sides=2)

par(mfrow=c(1,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))
plot(gtemp, lwd=2)
lines(c(t1),ma.5,col=2,lwd=2) 
lines(c(t1),ma.20,col=3,lwd=2) 
legend("topleft", legend=c("bandwidth=5", "bandwidth=20"), col=2:3, lty=1, lwd=2, bty="n")

#try 1-sided moving average (more practical for forecasting):
qq = 5
ma.oneside.5 = filter(gtemp,filter=c(0,rep(1,qq)/(qq)), sides=1)
plot(gtemp, ylab="Global Temperature Deviation")
lines(c(t1), ma.5, col=2, lwd=2) 
lines(c(t1), ma.oneside.5, col=3, lwd=2) #prediction pattern is delayed! 

#try 1-sided kernel weights:
b = 3           #corresponding to bandwidth
w = dnorm(0:10,mean=0, sd=b)
norm.oneside = filter(gtemp,filter=c(0,w)/sum(w), sides=1)
lines(c(t1), norm.oneside, col=4, lwd=2)   #you can still see delay

legend("topleft", legend=c("ma.5", "ma.oneside.5", "norm.onside.3"), col=2:4, lty=1, lwd=2, bty="n")

#try smoothing with different kernels (2-sided):

sm.1 = ksmooth(c(t1),gtemp,kernel="box", bandwidth=5)
sm.2 = ksmooth(c(t1),gtemp,kernel="box", bandwidth=10)
sm.3 = ksmooth(c(t1),gtemp,kernel="normal", bandwidth=10)

plot(gtemp, ylab="Global Temperature Deviation")
lines(sm.1,col=2,lwd=2) 
lines(sm.2,col=3,lwd=2) 
lines(sm.3,col=4,lwd=2) 
legend("topleft", legend=c("box.5", "box.10", "norm.10"), col=2:4, lty=1, lwd=2, bty="n")

par(mfrow=c(2,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

set.seed(2024) #try other random seed

n = 100     # sample size
phi_1 = 0.8  #phi_1 (try different parameter value)

y2 = matrix(0,n,2)
for (i in 1:2){
  y2[,i] = arima.sim(n,model=list(ar=phi_1))
  ts.plot(y2[,i]); title(paste("simulation AR(1) series",i))
}

a = ARMAacf(ar=phi_1, lag.max=10)
a

par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

plot(0:10, a, type="h", ylim=c(-0.2,1)); 
abline(h=0, col="gray"); 
title("model true ACF")

for (i in 1:2){
  acf(y2[,1], 10, ylim=c(-0.2,1)); title(paste("simulation AR(1) series",i))
}

b = ARMAacf(ar=phi_1, lag.max=10, pacf=T)
b #PACF reported for lag 1 to 10

par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

plot(b, type="h", ylim=c(-0.2,1)); 
abline(h=0, col="gray"); 
title("model true PACF")

for (i in 1:2){
  acf(y2[,1], 10, type="partial", ylim=c(-0.2,1)); title(paste("simulation AR(1) series",i))
}

#AR(2)
# (1−ϕ1−ϕ2B2)Xt=ϵt, where ϵt∼N(0,1)
# AR polynomial with two distinct real roots
par(mfrow=c(2,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

n = 100     # sample size
phi = c(0.3, 0.4)  #(phi_1,phi_2) 
y3 = matrix(0,n,2)
for (i in 1:2){
  y3[,i] = arima.sim(n,model=list(ar=phi))
  ts.plot(y3[,i]); title(paste("simulation AR(2) series",i))
}

a2 = ARMAacf(ar=phi, lag.max=10)
a2

par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

plot(0:10, a2, type="h", ylim=c(-0.2,1)); 
abline(h=0, col="gray"); 
title("model true ACF")

for (i in 1:2){
  acf(y3[,1], 10, ylim=c(-0.2,1)); title(paste("simulation AR(2) series",i))
}

b2 = ARMAacf(ar=phi, lag.max=10, pacf=T)
b2 #PACF reported for lag 1 to 10

par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

plot(b2, type="h", ylim=c(-0.2,1)); 
abline(h=0, col="gray"); 
title("model true PACF")

for (i in 1:2){
  acf(y3[,1], 10, type="partial", ylim=c(-0.2,1)); title(paste("simulation AR(1) series",i))
}

par(mfrow=c(2,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

n = 100     
d = 12      #period
r = 0.8     #dependence decay rate
phi = c(2*r*cos(2*pi/d), -r^2)  #(phi_1,phi_2) 

y4 = matrix(0,n,2)
for (i in 1:2){
  y4[,i] = arima.sim(n,model=list(ar=phi))
  ts.plot(y4[,i]); title(paste("simulation AR(2) series",i))
}

a3 = ARMAacf(ar=phi, lag.max=24)
a3
par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

plot(0:24, a3, type="h", ylim=c(-0.2,1)); 
abline(h=0, col="gray"); 
abline(v=c(12,24), col=3, lty=2)
title("model true ACF")


for (i in 1:2){
  acf(y4[,1], 24, ylim=c(-0.2,1)); title(paste("simulation AR(2) series",i))
}

b3 = ARMAacf(ar=phi, lag.max=10, pacf=T)
b3 #PACF reported for lag 1 to 10

par(mfrow=c(3,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

plot(b3, type="h", ylim=c(-0.8,1)); 
abline(h=0, col="gray"); 
title("model true PACF")

for (i in 1:2){
  acf(y4[,1], 10, type="partial", ylim=c(-0.8,1)); title(paste("simulation AR(1) series",i))
}

#ARMA(1,1)
# (1−ϕ1B)Xt=(1+θ1B)ϵt
par(mfrow=c(2,1), mar=c(2,2.5,1,0)+.5, mgp=c(1.6,.6,0))

n = 100   
phi = 0.8      #phi_1
theta = c(-0.5) #theta_1 

y5 = matrix(0,n,2)
for (i in 1:2){
  y5[,i] = arima.sim(n,model=list(ar=phi, ma=0.5))
  ts.plot(y5[,i]); title(paste("simulation ARMA(1,1) series",i))
}

#data generation
n = 100

y6 = rnorm(n, sin((1:n)/10), 0.5)
ts.plot(y6)
# y = arima.sim(n, model=list(ar=0.8))
# EDA
acf(y6)

fit1 = arima(y6, order=c(1,0,0)) #fit AR(1)
fit1$coef
#View(fit1)
ts.plot(y6)
lines(1:n, y6-fit1$resid, col="blue", lwd=2)

#1-step and 2-step forecast 
ypred1 = predict(fit1, n.ahead=2) #predict function for arima fitting object
ypred1

acf(diff(y6)) 

fit2 = arima(y6, order=c(0,1,1)) #fit IMA(1)
fit2$coef

ts.plot(y6)
lines(1:n, y6-fit2$resid, col=2, lwd=2)
legend("bottomright", legend=c("Data", "IMA(1) Forecast"), col=c(1,2), lty=1, lwd=2, bty="n")

# install.packages("qcc") #providing tools for ewma 
library(qcc)

idx = 1:n #set time index
pred1 = ewmaSmooth(idx,y6,lambda=1+fit2$coef) #apply EWMA forecast based on the lambda value obtained from the IMA fitting

ts.plot(y6)
lines(2:(n+1),pred1$y, col=4, lwd=2) 
legend("bottomright", legend=c("Data", "EWMA Forecast"), col=c(1,4), lty=1, lwd=2, bty="n")

pred2 = ewmaSmooth(idx,y6,lambda=0.1) #user specified lambda (try different lambda's)

ts.plot(y6)
lines(1:n, y6-fit2$resid, col=2, lwd=2)
lines(2:(n+1),pred1$y, col=4, lwd=2) 
lines(2:(n+1),pred2$y, col=5, lwd=2) 
legend("bottomright", legend=c("Data", "IMA BLP", "EWMA(estimated lambda)", "EWAM(lambda=0.1)"), col=c(1,2,4,5), lty=1, lwd=2, bty="n")

library('astsa')
par(mfrow = c(2,1), mar=c(1.5,2,1,0)+.5, mgp=c(1.6,.6,0), cex.main=1.05)
x = arima.sim(list(order=c(1,0,0), ar=.9), n=100) #try other parameter value
plot(x, ylab="x", xlab="", main=(expression(AR(1)~~~phi==+.9)), type='n')
lines(x)

x = arima.sim(list(order=c(1,0,0), ar=-.9), n=100)
plot(x, ylab="x",  xlab="",  main=(expression(AR(1)~~~phi==-.9)), type='n')
lines(x)
mtext('Time', side=1, line=1)

#MA(1)
par(mfrow = c(2,1), mar=c(1.5,2,1,0)+.5, mgp=c(1.6,.6,0), cex.main=1.05)
set.seed(101010)
x = arima.sim(list(order=c(0,0,1), ma=.9), n=100)
plot(x, ylab="x", xlab="", main=(expression(MA(1)~~~theta==+.9)), type='n')
lines(x)

x=arima.sim(list(order=c(0,0,1), ma=-.9), n=100)
plot(x, ylab="x", xlab='', main=(expression(MA(1)~~~theta==-.9)), type='n')
lines(x)
mtext('Time', side=1, line=1)

#AR(2)
par(mfrow = c(3,1), mar=c(1.5,2,1,0)+.5, mgp=c(1.6,.6,0), cex.main=1.05)
x = arima.sim(list(order=c(2,0,0), ar=c(1.5,-.75)), n = 144)
plot(x, axes=FALSE, xlab="Time", type='n') 
axis(2);  axis(1, at=seq(0,144,by=12));  box()
abline(v=seq(0,144,by=12), lty=2)
abline(h=c(-5,0,5), lty=1, col=gray(.9))
lines(x)

acf(x)
acf(x, type="partial")

#Real Data: recruitment data series (monthly data)
par(mfrow = c(3,1), mar=c(1.5,2,1,0)+.5, mgp=c(1.6,.6,0), cex.main=1.05)
ts.plot(rec)
acf(rec)
acf(rec, type="partial")

#Estimation for recruitment data series using regression
regr = ar.ols(rec, order=2, demean=FALSE, intercept=TRUE)
regr

fore = predict(regr, n.ahead=24) 
fore

#Prediction with prediction interval (±1 s.e.)
par(mar=c(2.5,2.5,0,0)+.5, mgp=c(1.6,.6,0))
ts.plot(rec, fore$pred, col=1:2, xlim=c(1980,1990), ylab="Recruitment", type='n')
par(new=TRUE)
ts.plot(rec, fore$pred, col=1:2, xlim=c(1980,1990), ylab="Recruitment")
U = fore$pred+fore$se
L = fore$pred-fore$se   
xx = c(time(U), rev(time(U)))
yy = c(L, rev(U))
polygon(xx, yy, border = 8, col = gray(0.6, alpha = 0.2))
lines(fore$pred, type="p", col=2)

#Estimation for real data series
# YW estimation: ‘ar.yw’
# MLE: ‘arima’
fit = ar.yw(rec, order=2, demean=TRUE)
fit
names(fit)
fit$asy.var.coef # variance matrix (V) of YW estimator
#Residual checking
par(mfrow = c(3,1), mar=c(1.5,2,1,0)+.5, mgp=c(1.6,.6,0), cex.main=1.05)
ts.plot(fit$resid)
acf(fit$resid, na.action = na.pass) #the first 2 residuals are NA
acf(fit$resid, type="partial", na.action = na.pass)

#White noise test
Box.test(fit$resid) # lag=1
Box.test(fit$resid, lag=6, fitdf=2) #adjust df due to AR(2) fit
Box.test(fit$resid, lag=6, type="Ljung-Box", fitdf=2) #default type = "Box-Pierce"  
Box.test(fit$resid, lag=12, type="Ljung-Box", fitdf=2) 
#McLeod and Li test:
Box.test(fit$resid^2-mean(fit$resid^2,na.rm=T), lag=12, fitdf=2)
#Diagnostic (residual) plots for time series fits
fit = arima(rec, order=c(2,0,0), include.mean=TRUE)
fit
par(mfrow = c(3,1), mar=c(1.5,2,1,0)+.5, mgp=c(1.6,.6,0), cex.main=1.0)
tsdiag(fit, gof.lag=24)
#More data series to try: lynx dataset
x = lynx 
ts.plot(x)
acf(x)
acf(x, type="partial")

fit1 = arima(x, order=c(2,0,0)) #Try AR(2) fitting
fit1

xi = polyroot(c(1, -fit1$coef[1:2])) #check roots for AR polynomial
Mod(xi)
## [1] 1.291269 1.291269
2*pi/Arg(xi) 
## [1]  8.531142 -8.531142
pred1 = predict(fit1, n.ahead=10)
names(pred1)
## [1] "pred" "se"
ts.plot(cbind(x,x-fit1$residuals), col=1:2, lwd=2) #compare observation and 1-step-ahead prediction
#model diagnostics:
acf(fit1$residuals)
tsdiag(fit1, gof.lag=24) 

fit2 = ar.yw(x)
fit2 = arima(x, order=c(8,0,0)) #Try AR(8) fitting
fit2

xi = polyroot(c(1, -fit2$coef[1:2])) #check roots for AR polynomial

Mod(xi)
## [1] 1.260088 1.260088
2*pi/Arg(xi) 
## [1]  7.450365 -7.450365
pred2 = predict(fit2, n.ahead=10)

ts.plot(cbind(x,x-fit1$residuals,x-fit2$residuals), col=c(1,2,4), lwd=2) #compare observation and 1-step-ahead predictions from AR(2) fitting and AR(8) fitting
legend("topright", legend=c("observation", "AR(2) fit", "AR(8) fit"), col=c(1,2,4), lwd=2, lty=1, bty="n")
tsdiag(fit2, gof.lag=24) 

#Try ARMA
fit3 = arima(x, order=c(2,0,1)) 
fit3
## 
## Call:
## arima(x = x, order = c(2, 0, 1))
## 
## Coefficients:
##          ar1      ar2      ma1  intercept
##       1.3129  -0.7128  -0.2759  1546.5600
## s.e.  0.1607   0.1121   0.2660   149.1229
## 
## sigma^2 estimated as 764086:  log likelihood = -934.73,  aic = 1879.46
xi = polyroot(c(1, -fit3$coef[1:2])) #check roots for AR polynomial

Mod(xi)
## [1] 1.18448 1.18448
2*pi/Arg(xi) 
## [1]  9.239002 -9.239002
pred3 = predict(fit3, n.ahead=10)

ts.plot(cbind(x,x-fit1$residuals,x-fit3$residuals), col=c(1,2,5), lwd=2) #compare observation and 1-step-ahead predictions from AR(2) fitting and AR(8) fitting
legend("topright", legend=c("observation", "AR(2) fit", "ARMA(2,1) fit"), col=c(1,2,5), lwd=2, lty=1, bty="n")

# Demo for ACF structures of SARIMA models
# Parameter setting:
phi1 = 0.8 
phi12 = 0.5
theta1 = 0.6
theta12 = 0.3 
# AR(1) or SARIMA(1,0,0)*(0,0,0)_{12}
par(mfcol=c(2,2))
ar = phi1  #(1-phi1 B)
b = ARMAacf(ar=ar, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(1,0,0)x(0,0,0)")
b = ARMAacf(ar=ar, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="PACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar))
ts.plot(x)
acf(x,24)

#SARIMA(0,0,0)*(1,0,0)_{12}
par(mfrow=c(2,2))
ar = c(rep(0,11),phi12) #(1-phi12 B^{12})
b = ARMAacf(ar=ar, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(0,0,0)x(1,0,0)")
b = ARMAacf(ar=ar, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="PACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar))
ts.plot(x)
acf(x,24)

#SARIMA(1,0,0)*(1,0,0)_{12}
par(mfrow=c(2,2))
ar = c(phi1,rep(0,10),phi12,-phi1*phi12) #(1-phi1 B)(1-phi12 B^{12})
b = ARMAacf(ar=ar, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(1,0,0)x(1,0,0)")
b = ARMAacf(ar=ar, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="PACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar))
ts.plot(x)
acf(x,24)

#MA(1) or SARIMA(0,0,1)x(0,0,0)_{12}
par(mfrow=c(2,2))
ma = theta1 
b = ARMAacf(ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(0,0,1)x(0,0,0)")
b = ARMAacf(ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="PACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar))
x = arima.sim(n=100, model=list(ma=ma))
ts.plot(x)
acf(x,24)

#SARIMA(0,0,0)*(0,0,1)_{12}
par(mfrow=c(2,2))
ma = c(rep(0,11),theta12)
b = ARMAacf(ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(0,0,0)x(0,0,1)")
b = ARMAacf(ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="PACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar))
x = arima.sim(n=100, model=list(ma=ma))
ts.plot(x)
acf(x,24)

#SARIMA(0,0,1)*(0,0,1)_{12}
par(mfrow=c(2,2))
ma = c(theta1,rep(0,10),theta12,theta1*theta12)
b = ARMAacf(ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(0,0,1)x(0,0,1)")
b = ARMAacf(ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="PACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar))
x = arima.sim(n=100, model=list(ma=ma))
ts.plot(x)
acf(x,24)

#ARMA(1,1) or SARIMA(1,0,1)*(0,0,0)_{12}
par(mfrow=c(2,2))
ar = phi1
ma = theta1
b = ARMAacf(ar=ar, ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(1,0,1)x(0,0,0)")
b = ARMAacf(ar=ar, ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar,ma=ma))
ts.plot(x)
acf(x,24)

#SARIMA(1,0,0)*(0,0,1)_{12}
par(mfrow=c(2,2))
ar = phi1
ma = c(rep(0,11),theta12)
b = ARMAacf(ar=ar, ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(1,0,0)x(0,0,1)")
b = ARMAacf(ar=ar, ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar,ma=ma))
ts.plot(x)
acf(x,24)

#SARIMA(1,0,1)*(0,0,1)_{12}
par(mfrow=c(2,2))
ar = phi1
ma = c(theta1,rep(0,10),theta12,theta1*theta12)
b = ARMAacf(ar=ar, ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(1,0,1)x(0,0,1)")
b = ARMAacf(ar=ar, ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar,ma=ma))
ts.plot(x)
acf(x,24)

#SARIMA(1,0,1)*(1,0,1)_{12}
par(mfrow=c(2,2))
ar = c(phi1,rep(0,10),phi12,-phi1*phi12) 
ma = c(theta1,rep(0,10),theta12,theta1*theta12)

b = ARMAacf(ar=ar, ma=ma, lag.max=24)
plot(0:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
title("SARIMA(1,0,1)x(1,0,1)")
b = ARMAacf(ar=ar, ma=ma, lag.max=24, pacf=TRUE)
plot(1:24,b,type="h", xlab="Lag", ylab="ACF",lwd=2)
x = arima.sim(n=100, model=list(ar=ar,ma=ma))
ts.plot(x)
acf(x,24)