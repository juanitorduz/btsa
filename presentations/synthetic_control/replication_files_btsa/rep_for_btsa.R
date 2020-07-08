## Replication Code for
# A. Abadie, A. Diamond, and J. Hainmueller. 2014.
# Comparative Politics and the Synthetic Control Method
# American Journal of Political Science.
# Original source for the code and the data:
# https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/24714
# This version for the Berlin Time Series Analysis Meet-up

library(foreign)
library("Synth")
library(xtable)
library(ggplot2)
library(scales)
library(tidyverse)
# Load Data 
d <- read.dta("repgermany.dta")


# Data set-up
  countrytosynthetise <- 7
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
             treatment.identifier = countrytosynthetise,
             controls.identifier = unique(d$index)[-which(unique(d$index) %in% countrytosynthetise)],
             time.predictors.prior = 1971:1989,
             time.optimize.ssr = 1971:1990,
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
  treatment.identifier = countrytosynthetise,
  controls.identifier = unique(d$index)[-which(unique(d$index) %in% countrytosynthetise)],
  time.predictors.prior = 1960:1989,
  time.optimize.ssr = 1960:1990,
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


# Table 1
xtable(cbind(tab1[1:9,c(3,2,4)],
             tab1[10:18,c(3,2,4)]
             )
       )

#### Figures 1, 2 and 3
data.to.plot <- data.frame(year = rownames(dataprep.out$Y1plot), 
                           west.germany = dataprep.out$Y1plot[, 1])

data.to.plot <- as.data.frame(d[,c("gdp","country", "year" )])
data.to.plot$west.germany <- ifelse(data.to.plot$country  == "West Germany", "West Germany", "Not West Germany")
data.to.plot$west.germany.size <- ifelse(data.to.plot$west.germany  == "West Germany", "1","2")
graphcolors <- c("#999999", "#ef8a62")


table(data.to.plot$country, data.to.plot$west.germany.size)


## PLOT WITH ONLY WEST GERMANY
ggplot(data = data.to.plot[data.to.plot$west.germany == "West Germany",], aes(x = year, y = gdp, 
                                group = country, 
                                color = west.germany, 
                                linetype = west.germany.size)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  guides(linetype = FALSE, color = FALSE)  +
  theme_bw(base_size = 15) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="\nReunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = c("#ef8a62")) +
  coord_cartesian(ylim = c(0, 30000)) #+
  #ggsave(paste0("figures/germany.pdf"),
  #       width = 15, height = 10, units = 'cm')



## PLOT WITH WEST GERMANY AND ALL THE OTHER COUNTRIES
ggplot(data = data.to.plot, aes(x = year, y = gdp, 
                                group = country, 
                                color = west.germany, 
                                linetype = west.germany.size)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  guides(linetype = FALSE)  +
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(0, 30000)) #+
  #ggsave(paste0("figures/germanynotgermany.pdf"),
  #       width = 15, height = 10, units = 'cm')


## PLOT WITH WEST GERMANY AND THE AVERAGE FROM OTHER COUNTRIES
data.to.plot.average <- data.to.plot %>%
  group_by(west.germany, year, west.germany.size) %>%
  summarise(GDP = mean(gdp))
  
ggplot(data = data.to.plot.average, 
       aes(x = year, y = GDP, 
           group = west.germany, 
           color = west.germany)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(0, 30000)) #+
  #ggsave(paste0("figures/germanyaverage.pdf"),
  #       width = 15, height = 10, units = 'cm')



data.to.plot.average$west.germany[data.to.plot.average$west.germany == "Not West Germany"] <- "Average of Other OECD Countries" 

ggplot(data = data.to.plot.average, 
       aes(x = year, y = GDP, 
           group = west.germany, 
           color = west.germany)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(0, 30000)) #+
  #ggsave(paste0("figures/germanyaverage2.pdf"),
  #       width = 15, height = 10, units = 'cm')
  
  
  

# SYNTHETIC UNIT - Weights
# Figure 4
data.to.plot.synthetic <- data.to.plot.average

synthY0 <- (dataprep.out$Y0%*%synth.out$solution.w)
data.to.plot.synthetic$GDP[data.to.plot.synthetic$west.germany == "Average of Other OECD Countries"] <- (dataprep.out$Y0%*%synth.out$solution.w)
data.to.plot.synthetic$west.germany[data.to.plot.synthetic$west.germany == "Average of Other OECD Countries"] <- "Synthetic West Germany"


ggplot(data = data.to.plot.synthetic, 
       aes(x = year, y = GDP, 
           group = west.germany, 
           color = west.germany)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(0, 30000)) #+
  #ggsave(paste0("figures/germanysynth.pdf"),
  #       width = 15, height = 10, units = 'cm')



# SYNTHETIC UNIT - Regression
# Figure 8
data.to.plot.synth.reg <- data.to.plot.average

synthY0.reg <- (dataprep.out$Y0%*%W)
data.to.plot.synth.reg$GDP[data.to.plot.synth.reg$west.germany == "Average of Other OECD Countries"] <- (dataprep.out$Y0%*%W)
data.to.plot.synth.reg$west.germany[data.to.plot.synth.reg$west.germany == "Average of Other OECD Countries"] <- "Synthetic West Germany"


ggplot(data = data.to.plot.synth.reg, 
       aes(x = year, y = GDP, 
           group = west.germany, 
           color = west.germany)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(0, 30000)) #+
  #ggsave(paste0("figures/germanysynthreg.pdf"),
  #       width = 15, height = 10, units = 'cm')



# Gap
# Figure 5
gap <- dataprep.out$Y1-(dataprep.out$Y0%*%synth.out$solution.w)

data.to.plot.gap <- data.to.plot.synthetic
data.to.plot.gap$GDP[data.to.plot.gap$west.germany == "West Germany"] <- dataprep.out$Y1-(dataprep.out$Y0%*%synth.out$solution.w)

data.to.plot.gap$GDP[data.to.plot.gap$west.germany == "Synthetic West Germany"] <- 0


ggplot(data = data.to.plot.gap, 
       aes(x = year, y = GDP, 
           group = west.germany, 
           color = west.germany)) + 
  geom_line(size = 1.5) + 
  labs(color = "West Germany?")+
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 1000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="Gap in per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(-5000, 5000)) #+
  #ggsave(paste0("figures/germanygap.pdf"),
  #       width = 15, height = 10, units = 'cm')




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
      time.predictors.prior = 1971:1989,
      time.optimize.ssr = 1971:1990,
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
      time.predictors.prior = 1960:1990,
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



# Placebo gaps
# Figure 6
sgaps <- as.data.frame(storegaps)
sgaps$year <- rownames(sgaps)
sgaps <- reshape2::melt(sgaps,id.vars = "year")


sgaps$west.germany <- ifelse(sgaps$variable  == "West Germany", "West Germany", "Not West Germany")
sgaps$west.germany.size <- ifelse(sgaps$west.germany  == "West Germany", "1","2")

sgaps$year <- as.numeric(sgaps$year)

data.to.plot$west.germany <- ifelse(data.to.plot$country  == "West Germany", "West Germany", "Not West Germany")
ggplot(data = sgaps, aes(x = year, y = value, 
                                group = variable, 
                                color = west.germany, 
                                linetype = west.germany.size)) + 
  geom_line() + 
  labs(color = "West Germany?")+
  guides(linetype = FALSE)  +
  theme_bw(base_size = 10) +
  theme(legend.position = "bottom") +
  geom_vline(xintercept = 1990,
             color = "#88419d") + 
  annotate("text", x = 1985, 
           label="Reunification", y = 4000,
           colour = "#88419d", alpha = 0.8, angle = 0) + 
  scale_y_continuous(name="Gap in per-capita GDP (PPP, 2002 USD)",
                     labels = comma_format(big.mark = ",",
                                           decimal.mark = ".")) +
  scale_color_manual(values = graphcolors) +
  coord_cartesian(ylim = c(-5000, 5000)) #+
  #ggsave(paste0("figures/allrmspe.pdf"),
  #       width = 15, height = 10, units = 'cm')







# Figure 7
# compute ratio of post-reunification RMSPE 
# to pre-reunification RMSPE                                                  
rmse <- function(x){sqrt(mean(x^2))}
preloss <- apply(storegaps[1:30,],2,rmse)
postloss <- apply(storegaps[31:44,],2,rmse)
prepost <- sort(postloss/preloss)
prepost <- t(t(prepost))

prepost <- data.frame(Country = rownames(prepost), RMSPE = prepost)
rownames(prepost) <- NULL
prepost$Country <- factor(prepost$Country, 
                          levels = prepost$Country[order(prepost$RMSPE)])


prepost$west.germany <- ifelse(prepost$Country== "West Germany", "West Germany", "Not West Germany")

ggplot(prepost, aes(x = Country, y = RMSPE)) + 
  geom_point(stat = 'identity', size = 6, aes(color = west.germany))  +
  theme_bw(base_size = 10) + 
  coord_flip() +
  ylab("Post-Period RMSE / Pre-Period RMSE") +
  scale_color_manual(values = graphcolors) +
  guides(color = FALSE) #+
  #ggsave(paste0("figures/RMSPERatio.pdf"),
  #       width = 15, height = 10, units = 'cm')





