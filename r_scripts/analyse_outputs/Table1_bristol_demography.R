rm(list=ls())

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

# BRISTOL

data.demog <- data.frame()

for (i in 1:30) 
{
  data.one <- read.csv(paste0("bristol_pop_age_structure/Bristol_pop_age_structure_45ha_headless", i, ".csv"))
  data.one$run <- i
  data.demog <- rbind(data.demog, data.one)
}

#write.csv(data.demog, paste0("bristol_pop_age_structure/Bristol_pop_age_structure_45.csv"))

data.y16w13 <- data.demog[data.demog$year == 16,]
data.y16w13 <- data.y16w13[data.y16w13$week == 13,]


variables <- c("no.fox.families", "no.breeding.females", "no.suboordinate.females",
               "no.alpha.males", "no.suboordinate.males", "no.cub.foxes", "no.disperser.females", "no.disperser.males",
               "no.foxes")

Harrisdata <- setNames(data.frame(matrix(ncol = 9, nrow = 1)), variables)
Harrisdata[1,] <- c(211, 190, 143, 211, 44, 897, 0, 128, 1613)

output <- data.frame()

correction.factor <- 116 / 114.49 # because real square sampling area was slightly less than 116km2

for (i in variables)

{
  i.mean <- format(round(mean(data.y16w13[[i]]) * correction.factor, 0), nsmall = 0)
  i.min <-  format(round(min(data.y16w13[[i]]) * correction.factor, 0), nsmall = 0)
  i.max <- format(round(max(data.y16w13[[i]]) * correction.factor, 0), nsmall = 0)

  i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
  i.output <- as.data.frame(i.output)
  i.output$year <- i 
  
 # i.output$p.means<- format(round (t.test(data.y16w13[[i]] * correction.factor, mu = Harrisdata[[i]])$p.value, 3), nsmall = 3)
  i.output$p.observ <- format(round (pnorm(Harrisdata[[i]], mean = mean(data.y16w13[[i]])* correction.factor, sd(data.y16w13[[i]])* correction.factor), 3), nsmall = 3)
  
  output <- rbind(output, i.output)
}

bristol.standard.output <- output

#####################################################################################################
# BRISTOL EXTRA MORT

data.demog <- data.frame()

for (i in 1:30) 
{
  data.one <- read.csv(paste0("bristol_pop_age_structure/Bristol_pop_age_structure_extramort_45ha_headless", i, ".csv"))
  data.one$run <- i
  data.demog <- rbind(data.demog, data.one)
}

#write.csv(data.demog, paste0("bristol_pop_age_structure/Bristol_demography_45ha_extramortality.csv"))

data.y16w13 <- data.demog[data.demog$year == 16,]
data.y16w13 <- data.y16w13[data.y16w13$week == 13,]

output <- data.frame()

variables <- c("no.fox.families", "no.cub.foxes", "no.breeding.females", "no.suboordinate.females",
               "no.alpha.males", "no.suboordinate.males", "no.disperser.females", "no.disperser.males",
               "no.foxes")

for (i in variables)
  
{
  i.mean <- format(round(mean(data.y16w13[[i]])* correction.factor, 0), nsmall = 0)
  i.min <-  format(round(min(data.y16w13[[i]])* correction.factor, 0), nsmall = 0)
  i.max <- format(round(max(data.y16w13[[i]])* correction.factor, 0), nsmall = 0)
  
  i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
  i.output <- as.data.frame(i.output)
  i.output$year <- i 
  
  i.output$p.means <- format(round (t.test(data.y16w13[[i]] * correction.factor, mu = Harrisdata[[i]])$p.value, 3), nsmall = 3)
  i.output$p.observ <- format(round (pnorm(Harrisdata[[i]], mean = mean(data.y16w13[[i]])* correction.factor, sd(data.y16w13[[i]])* correction.factor), 3), nsmall = 3)
  
  output <- rbind(output, i.output)
}

bristol.extramort.output <- output
finaloutput <- cbind(bristol.standard.output, bristol.extramort.output)
write.csv(output, "bristol_pop_age_structure/Bristol_demography_summary_45ha.csv")
