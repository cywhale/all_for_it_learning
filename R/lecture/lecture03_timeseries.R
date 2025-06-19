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


