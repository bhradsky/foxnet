rm(list=ls())

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

# BRISTOL

data.demog <- data.frame()

for (i in 1:30) 
{
  data.one <- read.csv(paste0("bristol_popstructure/Bristol_demography_headless", i, ".csv"))
  data.one$run <- i
  data.demog <- rbind(data.demog, data.one)
}

write.csv(data.demog, paste0("bristol_popstructure/Bristol_demography.csv"))

#View(data.demog)
# data.demog$density <- data.demog$no.foxes / 196 #density in foxes / km2.  Note actual region size was 196km2, not 200km2
# data.demog$density.adult <- (data.demog$no.foxes - data.demog$foxes.less1) / 196 #density in foxes / km2.  Note actual region size was 196km2, not 200km2
# 
# data.demog$prop.less.1 <- data.demog$foxes.less1 / data.demog$no.foxes
# data.demog$prop.1.2 <- data.demog$foxes.1.2 / data.demog$no.foxes
# data.demog$prop.2.3 <- data.demog$foxes.2.3 / data.demog$no.foxes
# data.demog$prop.3.4 <- data.demog$foxes.3.4 / data.demog$no.foxes
# data.demog$prop.4.5 <- data.demog$foxes.4.5 / data.demog$no.foxes
# data.demog$prop.5.6 <- data.demog$foxes.5.6 / data.demog$no.foxes
# data.demog$prop.6.7 <- data.demog$foxes.6.7 / data.demog$no.foxes
# data.demog$prop.more7 <- data.demog$foxes.more7 / data.demog$no.foxes

data.y16w13 <- data.demog[data.demog$year == 16,]
data.y16w13 <- data.y16w13[data.y16w13$week == 13,]

output <- data.frame()
correction.factor <- 116 / 112.36 # because real square sampling area was only 112.36
variables <- c("fox.families", "fox.cubs", "fox.bred.females", "fox.sub.females",
               "fox.alpha.males", "fox.sub.males", "fox.disp.females", "fox.disp.males",
               "no.foxes")#, "disp.fem.mean.nosub", "disp.fem.max","disp.male.mean.nosub","disp.male.max" 
               
               #)

for (i in variables)

{
  i.mean <- mean(data.y16w13[[i]]) * correction.factor
  i.min <-  min(data.y16w13[[i]]) * correction.factor
  i.max <-  max(data.y16w13[[i]]) * correction.factor

  i.output <- cbind(i.mean, i.min, i.max)
  i.output <- as.data.frame(i.output)
  i.output$group <- i 
  
  output <- rbind(output, i.output)
}

bristol.standard.output <- output
bristol.standard.output$model <- "standard"
#####################################################################################################
# BRISTOL EXTRA MORT

data.demog <- data.frame()

for (i in 1:30) 
{
  data.one <- read.csv(paste0("bristol_popstructure/Bristol_demog_extramortality_headless", i, ".csv"))
  data.one$run <- i
  data.demog <- rbind(data.demog, data.one)
}

write.csv(data.demog, paste0("bristol_popstructure/Bristol_demography_extramortality.csv"))

data.y16w13 <- data.demog[data.demog$year == 16,]
data.y16w13 <- data.y16w13[data.y16w13$week == 13,]

output <- data.frame()

variables <- c("fox.families", "fox.cubs", "fox.bred.females", "fox.sub.females",
               "fox.alpha.males", "fox.sub.males", "fox.disp.females", "fox.disp.males",
               "no.foxes")#, "disp.fem.mean.nosub", "disp.fem.max","disp.male.mean.nosub","disp.male.max" 
               
#)

for (i in variables)
  
{
  i.mean <- mean(data.y16w13[[i]]) * correction.factor
  i.min <-  min(data.y16w13[[i]]) * correction.factor
  i.max <-  max(data.y16w13[[i]]) * correction.factor
  
  i.output <- cbind(i.mean, i.min, i.max)
  i.output <- as.data.frame(i.output)
  i.output$group <- i 
  
  output <- rbind(output, i.output)
}

bristol.extramort.output <- output
bristol.extramort.output$model <- "extra mortality"

bristoldata <- data.frame("group" = variables)
bristoldata$i.mean <- c(211, 897, 190, 143, 211, 44, 0, 128, 1613)
bristoldata$i.min <- NA
bristoldata$i.max <- NA
bristoldata$model <- "field"
finaloutput <- rbind(bristoldata, bristol.standard.output, bristol.extramort.output)

write.csv(finaloutput, "bristol_popstructure/Bristol_demography_summary.csv")

library(reshape2)

library(ggplot2)
p <- ggplot(data = finaloutput, aes(x = group, y = i.mean, fill = model)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_errorbar(aes(x = group, ymin=i.min, ymax=i.max),
                width=.2,                  # Width of the error bars
                position=position_dodge(.9))