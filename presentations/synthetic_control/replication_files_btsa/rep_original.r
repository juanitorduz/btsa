## Replication Code for
# A. Abadie, A. Diamond, and J. Hainmueller. 2014.
# Comparative Politics and the Synthetic Control Method
# American Journal of Political Science.

rm(list=ls())
library(foreign)
library("Synth")
library(xtable)

# Load Data 
d <- read.dta("repgermany.dta")

## Table 1 & 2, Figure 1, 2, & 3

## pick v by cross-validation
# data setup for training model
dataprep.out <-
  dataprep(
           foo = d,
           predictors    = c("gdp","trade","infrate"),
           dependent     = "gdp",
           unit.variable = 1,
           time.variable = 3,
           special.predictors = list(
            list("industry", 1971:1980, c("mean")),
            list("schooling",c(1970,1975), c("mean")),
            list("invest70" ,1980, c("mean"))
           ),
           treatment.identifier = 7,
           controls.identifier = unique(d$index)[-7],
           time.predictors.prior = 1971:1980,
           time.optimize.ssr = 1981:1990,
           unit.names.variable = 2,
           time.plot = 1960:2003
         )

# fit training model
synth.out <- 
  synth(
        data.prep.obj=dataprep.out,
        Margin.ipop=.005,Sigf.ipop=7,Bound.ipop=6
        )

# data prep for main model
dataprep.out <-
 dataprep(
  foo = d,
  predictors    = c("gdp","trade","infrate"),
  dependent     = "gdp",
  unit.variable = 1,
  time.variable = 3,
  special.predictors = list(
    list("industry" ,1981:1990, c("mean")),
    list("schooling",c(1980,1985), c("mean")),
    list("invest80" ,1980, c("mean"))
  ),
  treatment.identifier = 7,
  controls.identifier = unique(d$index)[-7],
  time.predictors.prior = 1981:1990,
  time.optimize.ssr = 1960:1989,
  unit.names.variable = 2,
  time.plot = 1960:2003
)

# fit main model with v from training model
synth.out <- synth(
  data.prep.obj=dataprep.out,
  custom.v=as.numeric(synth.out$solution.v)
  )

#### Table 2
synth.tables <- synth.tab(
                          dataprep.res = dataprep.out,
                          synth.res = synth.out
                          ); synth.tables
                      
# Replace means for OECD sample (computed externally using proper pop weighting)
synth.tables$tab.pred[,3]          <- c(8021.1,31.9,7.4,34.2,44.1,25.9)
colnames(synth.tables$tab.pred)[3] <- "Rest of OECD Sample"
rownames(synth.tables$tab.pred) <- c("GDP per-capita","Trade openness",
                                     "Inflation rate","Industry share",
                                     "Schooling","Investment rate")

xtable(round(synth.tables$tab.pred,1),digits=1)

#### Table 1
# synth weights
tab1 <- data.frame(synth.tables$tab.w)
tab1[,1] <- round(tab1[,1],2) 
# regression weights
X0 <- cbind(1,t(dataprep.out$X0))
X1 <- as.matrix(c(1,dataprep.out$X1))
W     <- X0%*%solve(t(X0)%*%X0)%*%X1
Wdat  <- data.frame(unit.numbers=as.numeric(rownames(X0)),
                    regression.w=round(W,2))
tab1  <- merge(tab1,Wdat,by="unit.numbers")
tab1  <- tab1[order(tab1[,3]),]

xtable(cbind(tab1[1:9,c(3,2,4)],
             tab1[10:18,c(3,2,4)]
             )
       )

#### Figure 1: Trends in Per-Capita GDP: West Germany vs. Rest of the OECD Sample
Text.height <- 23000
Cex.set <- .8
#pdf(file = "ger_vs_oecd.pdf", width = 5.5, height = 5.5, family = "Times",pointsize = 12)
plot(1960:2003,dataprep.out$Y1plot,
     type="l",ylim=c(0,33000),col="black",lty="solid",
     ylab ="per-capita GDP (PPP, 2002 USD)",
     xlab ="year",
     xaxs = "i", yaxs = "i",
     lwd=2
     )
lines(1960:2003,aggregate(d[,c("gdp")],by=list(d$year),mean,na.rm=T)[,2]
      ,col="black",lty="dashed",lwd=2) # mean 2
abline(v=1990,lty="dotted")
legend(x="bottomright",
       legend=c("West Germany","rest of the OECD sample")
      ,lty=c("solid","dashed"),col=c("black","black")
      ,cex=.8,bg="white",lwd=c(2,2))
arrows(1987,Text.height,1989,Text.height,col="black",length=.1)
text(1982.5,Text.height,"reunification",cex=Cex.set)
#dev.off()

#### Figure 2: Trends in Per-Capita GDP: West Germany vs. Synthetic West Germany
#pdf(file = "ger_vs_synthger2.pdf", width = 5.5, height = 5.5, family = "Times",pointsize = 12)
synthY0 <- (dataprep.out$Y0%*%synth.out$solution.w)
plot(1960:2003,dataprep.out$Y1plot,
     type="l",ylim=c(0,33000),col="black",lty="solid",
     ylab ="per-capita GDP (PPP, 2002 USD)",
     xlab ="year",
     xaxs = "i", yaxs = "i",
     lwd=2
     )
lines(1960:2003,synthY0,col="black",lty="dashed",lwd=2)
abline(v=1990,lty="dotted")
legend(x="bottomright",
       legend=c("West Germany","synthetic West Germany")
      ,lty=c("solid","dashed"),col=c("black","black")
      ,cex=.8,bg="white",lwd=c(2,2))
arrows(1987,Text.height,1989,Text.height,col="black",length=.1)
text(1982.5,Text.height,"reunification",cex=Cex.set)
#dev.off()

### Figure 3: Per-Capita GDP Gap Between West Germany and Synthetic West Germany
#pdf(file = "ger_vs_synthger_gaps2.pdf", width = 5.5, height = 5.5, family = "Times",pointsize = 12)
gap <- dataprep.out$Y1-(dataprep.out$Y0%*%synth.out$solution.w)
plot(1960:2003,gap,
     type="l",ylim=c(-4500,4500),col="black",lty="solid",
     ylab =c("gap in per-capita GDP (PPP, 2002 USD)"),
     xlab ="year",
     xaxs = "i", yaxs = "i",
     lwd=2
     )
abline(v=1990,lty="dotted")
abline(h=0,lty="dotted")
arrows(1987,1000,1989,1000,col="black",length=.1)
text(1982.5,1000,"reunification",cex=Cex.set)
#dev.off()

### Figure 4: Placebo Reunification 1975 - Trends in Per-Capita GDP: West Germany vs. Synthetic West Germany

# data prep for training model
dataprep.out <-
  dataprep(
    foo = d,
    predictors    = c("gdp","trade","infrate"),
    dependent     = "gdp",
    unit.variable = 1,
    time.variable = 3,
    special.predictors = list(
      list("industry",1971, c("mean")),
      list("schooling",c(1960,1965), c("mean")),
      list("invest60" ,1980, c("mean"))
    ),
    treatment.identifier = 7,
    controls.identifier = unique(d$index)[-7],
    time.predictors.prior = 1960:1964,
    time.optimize.ssr = 1965:1975,
    unit.names.variable = 2,
    time.plot = 1960:1990
  )

# fit training model
synth.out <- synth(
  data.prep.obj=dataprep.out,
  Margin.ipop=.005,Sigf.ipop=7,Bound.ipop=6
)


# data prep for main model
dataprep.out <-
  dataprep(
    foo = d,
    predictors    = c("gdp","trade","infrate"),
    dependent     = "gdp",
    unit.variable = 1,
    time.variable = 3,
    special.predictors = list(
      list("industry" ,1971:1975, c("mean")),
      list("schooling",c(1970,1975), c("mean")),
      list("invest70" ,1980, c("mean"))
    ),
    treatment.identifier = 7,
    controls.identifier = unique(d$index)[-7],
    time.predictors.prior = 1965:1975,
    time.optimize.ssr = 1960:1975,
    unit.names.variable = 2,
    time.plot = 1960:1990
  )

# fit main model
synth.out <- synth(
  data.prep.obj=dataprep.out,
  custom.v=as.numeric(synth.out$solution.v)
)

Cex.set <- 1
#pdf(file = "2intimeplacebo1975.pdf", width = 5.5, height = 5.5, family = "Times",pointsize = 12)
plot(1960:1990,dataprep.out$Y1plot,
     type="l",ylim=c(0,33000),col="black",lty="solid",
     ylab ="per-capita GDP (PPP, 2002 USD)",
     xlab ="year",
     xaxs = "i", yaxs = "i",
     lwd=2
     )
lines(1960:1990,(dataprep.out$Y0%*%synth.out$solution.w),col="black",lty="dashed",lwd=2)
abline(v=1975,lty="dotted")
legend(x="bottomright",
       legend=c("West Germany","synthetic West Germany")
      ,lty=c("solid","dashed"),col=c("black","black")
      ,cex=.8,bg="white",lwd=c(2,2))
arrows(1973,20000,1974.5,20000,col="black",length=.1)
text(1967.5,20000,"placebo reunification",cex=Cex.set)
#dev.off()


### Figure 5: Ratio of post-reunification RMSPE to pre-reunification RMSPE: West Germany and control countries.

# loop across control units
storegaps <- 
  matrix(NA,
        length(1960:2003),
        length(unique(d$index))-1
        )
rownames(storegaps) <- 1960:2003
i <- 1
co <- unique(d$index)

for(k in unique(d$index)[-7]){
  
  # data prep for training model
  dataprep.out <-
    dataprep(
      foo = d,
      predictors    = c("gdp","trade","infrate"),
      dependent     = "gdp",
      unit.variable = 1,
      time.variable = 3,
      special.predictors = list(
        list("industry",1971:1980, c("mean")),
        list("schooling"   ,c(1970,1975), c("mean")),
        list("invest70" ,1980, c("mean"))
      ),
      treatment.identifier = k,
      controls.identifier = co[-which(co==k)],
      time.predictors.prior = 1971:1980,
      time.optimize.ssr = 1981:1990,
      unit.names.variable = 2,
      time.plot = 1960:2003
    )

  # fit training model
  synth.out <-
   synth(
    data.prep.obj=dataprep.out,
    Margin.ipop=.005,Sigf.ipop=7,Bound.ipop=6
   )

  # data prep for main model
dataprep.out <-
    dataprep(
      foo = d,
      predictors    = c("gdp","trade","infrate"),
      dependent     = "gdp",
      unit.variable = 1,
      time.variable = 3,
      special.predictors = list(
        list("industry" ,1981:1990, c("mean")),
        list("schooling",c(1980,1985), c("mean")),
        list("invest80" ,1980, c("mean"))
      ),
      treatment.identifier = k,
      controls.identifier = co[-which(co==k)],
      time.predictors.prior = 1981:1990,
      time.optimize.ssr = 1960:1989,
      unit.names.variable = 2,
      time.plot = 1960:2003
    )

# fit main model
synth.out <- synth(
   data.prep.obj=dataprep.out,
   custom.v=as.numeric(synth.out$solution.v)
  )

 storegaps[,i] <-  
   dataprep.out$Y1-
   (dataprep.out$Y0%*%synth.out$solution.w)
 i <- i + 1
} # close loop over control units
d <- d[order(d$index,d$year),]
colnames(storegaps) <- unique(d$country)[-7]
storegaps <- cbind(gap,storegaps)
colnames(storegaps)[1] <- c("West Germany")

# compute ratio of post-reunification RMSPE 
# to pre-reunification RMSPE                                                  
rmse <- function(x){sqrt(mean(x^2))}
preloss <- apply(storegaps[1:30,],2,rmse)
postloss <- apply(storegaps[31:44,],2,rmse)

#pdf("2ratio_post_to_preperiod_rmse2a.pdf")
dotchart(sort(postloss/preloss),
         xlab="Post-Period RMSE / Pre-Period RMSE",
         pch=19)
#dev.off()

### Figure 6: Leave-one-out distribution of the synthetic control for West Germany

# loop over leave one outs
storegaps <- 
  matrix(NA,
        length(1960:2003),
        5)
colnames(storegaps) <- c(1,3,9,12,14)
co <- unique(d$index)[-7]

for(k in 1:5){

# data prep for training model
omit <- c(1,3,9,12,14)[k]  
  dataprep.out <-
    dataprep(
      foo = d,
      predictors    = c("gdp","trade","infrate"),
      dependent     = "gdp",
      unit.variable = 1,
      time.variable = 3,
      special.predictors = list(
        list("industry",1971:1980, c("mean")),
        list("schooling"   ,c(1970,1975), c("mean")),
        list("invest70" ,1980, c("mean"))
      ),
      treatment.identifier = 7,
      controls.identifier = co[-which(co==omit)],
      time.predictors.prior = 1971:1980,
      time.optimize.ssr = 1981:1990,
      unit.names.variable = 2,
      time.plot = 1960:2003
    )
  
  # fit training model
  synth.out <- synth(
    data.prep.obj=dataprep.out,
    Margin.ipop=.005,Sigf.ipop=7,Bound.ipop=6
  )
  
# data prep for main model
dataprep.out <-
  dataprep(
    foo = d,
    predictors    = c("gdp","trade","infrate"),
    dependent     = "gdp",
    unit.variable = 1,
    time.variable = 3,
    special.predictors = list(
      list("industry" ,1981:1990, c("mean")),
      list("schooling",c(1980,1985), c("mean")),
      list("invest80" ,1980, c("mean"))
    ),
    treatment.identifier = 7,
    controls.identifier = co[-which(co==omit)],
    time.predictors.prior = 1981:1990,
    time.optimize.ssr = 1960:1989,
    unit.names.variable = 2,
    time.plot = 1960:2003
  )
  
  # fit main model 
  synth.out <- synth(
    data.prep.obj=dataprep.out,
    custom.v=as.numeric(synth.out$solution.v)
  )
  storegaps[,k] <- (dataprep.out$Y0%*%synth.out$solution.w)
} # close loop over leave one outs

Text.height <- 23000
Cex.set <- .8
#pdf(file = "1jackknife2.pdf", width = 5.5, height = 5.5, family = "Times",pointsize = 12)
plot(1960:2003,dataprep.out$Y1plot,
     type="l",ylim=c(0,33000),col="black",lty="solid",
     ylab ="per-capita GDP (PPP, 2002 USD)",
     xlab ="year",
     xaxs = "i", yaxs = "i",lwd=2
     )

abline(v=1990,lty="dotted")
arrows(1987,23000,1989,23000,col="black",length=.1)
 for(i in 1:5){
  lines(1960:2003,storegaps[,i],col="darkgrey",lty="solid")
  }
lines(1960:2003,synthY0,col="black",lty="dashed",lwd=2)
lines(1960:2003,dataprep.out$Y1plot,col="black",lty="solid",lwd=2)
text(1982.5,23000,"reunification",cex=.8)
legend(x="bottomright",
       legend=c("West Germany",
                "synthetic West Germany",
                "synthetic West Germany (leave-one-out)")
      ,lty=c("solid","dashed","solid"),
      col=c("black","black","darkgrey")
      ,cex=.8,bg="white",lwdc(2,2,1))
#dev.off()


### Table 3: Synthetic Weights from Combinations of Control Countries
rm(list=ls())
library(gtools)
library(kernlab)

# data prep for training model
d <- read.dta("repgermany.dta")
dataprep.out <-
  dataprep(
    foo = d,
    predictors    = c("gdp","trade","infrate"),
    dependent     = "gdp",
    unit.variable = 1,
    time.variable = 3,
    special.predictors = list(
      list("industry", 1971:1980, c("mean")),
      list("schooling",c(1970,1975), c("mean")),
      list("invest70" ,1980, c("mean"))
    ),
    treatment.identifier = 7,
    controls.identifier = unique(d$index)[-7],
    time.predictors.prior = 1971:1980,
    time.optimize.ssr = 1981:1990,
    unit.names.variable = 2,
    time.plot = 1960:2003
  )

# fit training model
synth.out <- 
  synth(
    data.prep.obj=dataprep.out,
    Margin.ipop=.005,Sigf.ipop=7,Bound.ipop=6
  )

# data prep for main model
dataprep.out <-
  dataprep(
    foo = d,
    predictors    = c("gdp","trade","infrate"),
    dependent     = "gdp",
    unit.variable = 1,
    time.variable = 3,
    special.predictors = list(
      list("industry" ,1981:1990, c("mean")),
      list("schooling",c(1980,1985), c("mean")),
      list("invest80" ,1980, c("mean"))
    ),
    treatment.identifier = 7,
    controls.identifier = unique(d$index)[-7],
    time.predictors.prior = 1981:1990,
    time.optimize.ssr = 1960:1989,
    unit.names.variable = 2,
    time.plot = 1960:2003
  )

# fit main model with v from training model
synth.out <- synth(
  data.prep.obj=dataprep.out,
  custom.v=as.numeric(synth.out$solution.v)
)

synth.tables <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res = synth.out
)

table3 <- list()
synth.tables$tab.w[,1] <- round(synth.tables$tab.w[,1],2)
table3[[5]] <-synth.tables$tab.w[order(-1*synth.tables$tab.w[,1]),2:1][1:5,]

# compute loss for all combinations 
# of 4, 3, 2, 1 sized donor pools

# get W and v
solution.w <- round(synth.out$solution.w,3)
V <- diag(as.numeric(synth.out$solution.v))

# compute scaled Xs
nvarsV <- dim(dataprep.out$X0)[1]
big.dataframe <- cbind(dataprep.out$X0, dataprep.out$X1)
divisor <- sqrt(apply(big.dataframe, 1, var))
scaled.matrix <-
  t(t(big.dataframe) %*% ( 1/(divisor) *
  diag(rep(dim(big.dataframe)[1], 1)) ))
X0.scaled <- scaled.matrix[,c(1:(dim(dataprep.out$X0)[2]))]
X1.scaled <- as.matrix(scaled.matrix[,dim(scaled.matrix)[2]])

dn <- d[d$year==1970,c("country","index")]
dn <- dn[order(dn$index),]
dn <- dn[-7,]

table2store <- matrix(NA,nrow(dataprep.out$X1),4)
fig7store   <- matrix(NA,length(1960:2003),4)  

# loop through number of controls
for(pp in 4:1){
  store       <- combinations(length(unique(d$index)[-7]),
                              r=pp, v=unique(d$index)[-7])
  store.loss  <- matrix(NA,nrow=nrow(store),1)
  store.w     <- matrix(NA,nrow=nrow(store),pp)
  store.c     <- store.w

# loop through combinations 
  for(k in 1:nrow(store)){
    # index positions of control units
    posvector <- c()
    for(i in 1:pp){
      posvector <- c(posvector,which(dn$index==store[k,i]))
    }
    
  # run quad optimization  
    X0temp <- X0.scaled[ , posvector ]
    H <- t(X0temp) %*% V %*% (X0temp)
    c <- -1*c(t(X1.scaled) %*% V %*% (X0temp) )

    if(pp == 1){
      solution.w <- matrix(1)
    } else {      
        res <- ipop(c = c, H = H, A = t(rep(1, length(c))),
                    b = 1, l = rep(0, length(c)),
                    u = rep(1, length(c)), r = 0,
                    margin = 0.005,sigf = 7, bound = 6)
        solution.w <- as.matrix(primal(res))
    }
    loss.w <- t(X1.scaled - X0temp %*% solution.w) %*% V %*% (X1.scaled - X0temp %*% solution.w)
    
    store.loss[k] <- loss.w
    store.w[k,]   <- t(solution.w)
    store.c[k,]   <- dn$country[posvector]
  } # close loop over combinations
  
# get best fitting combination
  dat <- data.frame(store.loss,
                    store,
                    store.c,
                    store.w
                    )
  colnames(dat) <- c("loss",
                     paste("CNo",1:pp,sep=""),
                     paste("CNa",1:pp,sep=""),
                     paste("W",1:pp,sep="")
                     )
  dat <- dat[order(dat$loss),]
  Countries <- dat[1,paste("CNo",1:pp,sep="")]
  Cweights  <- as.numeric(dat[1,paste("W",1:pp,sep="")])
 
  outdat <-  data.frame(unit.names=as.vector(
   (t(as.vector(dat[1,paste("CNa",1:pp,sep="")])))),
                    w.weights=round(Cweights,2))

table3[[pp]]<- outdat[order(-1*outdat$w.weights),]
  
 # get posvector for fitting
  posvector <- c()
  if(pp == 1 ){
    posvector <- c(posvector,which(dn$index==Countries))
  } else {
    for(i in 1:pp){
      posvector <- c(posvector,which(dn$index==Countries[1,i]))
    }
  }
   
  X0t <- as.matrix(dataprep.out$X0[,posvector])%*% as.matrix(Cweights)
  table2store[,(4:1)[pp]] <- X0t

  fig7store[,(4:1)[pp]] <- 
   dataprep.out$Y0[,posvector]%*%as.matrix(Cweights)

} # close loop over number of countries

# Table 3
table3

# Table 4
synth.tables$tab.pred[,3] <- c(8021.1,31.9,7.4,34.2,44.1,25.9)
table4 <- round(
  cbind(synth.tables$tab.pred[,1:2],
        table2store,
        synth.tables$tab.pred[,3]),1)
rownames(table4) <- c("GDP per-capita","Trade openness",
                      "Inflation rate","Industry share",
                      "Schooling","Investment rate")
colnames(table4)[2:7] <- c(5:1,"OECD Sample")
table4

## Figure 7: Per-Capita GDP Gaps Between West Germany and Sparse Synthetic Controls
Text.height <- 23000
Cex.set <- .8

par(mfrow=c(2,2)) 
for(pp in 4:1){
#pdf(file = paste("2ger_vs_synth","CValt",pp,".pdf",sep=""), width = 5.5, height = 5.5, family = "Times",pointsize = 12)
  plot(1960:2003,dataprep.out$Y1,
       type="l",ylim=c(0,33000),col="black",lty="solid",
       ylab ="per-capita GDP (PPP, 2002 USD)",
       xlab ="year",
       xaxs = "i", yaxs = "i",
       lwd=2,
       main=paste("No. of control countries: ",pp,sep="")
       )
  lines(1960:2003,fig7store[,c(4:1)[pp]],col="black",lty="dashed",lwd=2)
  abline(v=1990,lty="dotted")
  legend(x="bottomright",
         legend=c("West Germany","synthetic West Germany")
         ,lty=c("solid","dashed"),col=c("black","black")
         ,cex=.8,bg="white",lwd=c(2,2))
  arrows(1987,Text.height,1989,Text.height,col="black",length=.1)
  text(1982.5,Text.height,"reunification",cex=Cex.set)
  #dev.off()
}



