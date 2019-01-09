rm(list=ls())

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

# CARNARVON

data.age <- data.frame()

for (i in 1:30) 
{
  data.oneHR <- read.csv(paste0("carnarvon_age/Carnarvon_agestructure_HR5_headless", i, ".csv"))
  data.oneHR$run <- i
  data.oneHR$HRsize <- 500
  data.age <- rbind(data.age, data.oneHR)
}

write.csv(data.age, paste0("carnarvon_age/Carnarvon_agestructure_HR5.csv"))

#View(data.age)
data.age$density <- data.age$no.foxes / 196 #density in foxes / km2.  Note actual region size was 196km2, not 200km2
data.age$density.adult <- (data.age$no.foxes - data.age$foxes.less1) / 196 #density in foxes / km2.  Note actual region size was 196km2, not 200km2

data.age$prop.less.1 <- data.age$foxes.less1 / data.age$no.foxes
data.age$prop.1.2 <- data.age$foxes.1.2 / data.age$no.foxes
data.age$prop.2.3 <- data.age$foxes.2.3 / data.age$no.foxes
data.age$prop.3.4 <- data.age$foxes.3.4 / data.age$no.foxes
data.age$prop.4.5 <- data.age$foxes.4.5 / data.age$no.foxes
data.age$prop.5.6 <- data.age$foxes.5.6 / data.age$no.foxes
data.age$prop.6.7 <- data.age$foxes.6.7 / data.age$no.foxes
data.age$prop.more7 <- data.age$foxes.more7 / data.age$no.foxes

data.y16w49 <- data.age[data.age$year == 16,]
data.y16w49 <- data.y16w49[data.y16w49$week == 49,]

output <- data.frame()

variables <- c("prop.less.1", "prop.1.2", "prop.2.3", "prop.3.4", "prop.4.5", "prop.5.6", "prop.6.7", "prop.more7")

for (i in variables)

{
  i.mean <- format(round(mean(data.y16w49[[i]]) * 100, 1), nsmall = 1)
  i.min <-  format(round(min(data.y16w49[[i]])* 100, 1), nsmall = 1)
  i.max <- format(round(max(data.y16w49[[i]])* 100, 1), nsmall = 1)

  i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
  i.output <- as.data.frame(i.output)
  i.output$year <- i 
  
  output <- rbind(output, i.output)
}

i <- "density.adult"
i.mean <- format(round(mean(data.y16w49[[i]]), 2), nsmall = 2)
i.min <-  format(round(min(data.y16w49[[i]]), 2), nsmall = 2)
i.max <- format(round(max(data.y16w49[[i]]), 2), nsmall = 2)

i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
i.output <- as.data.frame(i.output)
i.output$year <- i 

output <- rbind(output, i.output)

carnarvon.output <- output

#####################################################################################################

# BRISTOL

data.age <- data.frame()

for (i in c(1:30) )
{
  data.oneHR <- read.csv(paste0("bristol_pop_age_structure/Bristol_pop_age_structure_45ha_headless", i, ".csv"))
  data.oneHR$run <- i
  data.oneHR$HRsize <- 45
  data.age <- rbind(data.age, data.oneHR)
}

write.csv(data.age, paste0("bristol_pop_age_structure/Bristol_age_structure_all.csv"))

#View(data.age)

data.age$density <- data.age$no.foxes / 114.49 #density in foxes / km2, adjusted for actual region size (114.49km2)
data.age$density.adult <- (data.age$no.foxes - data.age$foxes.less1) / 114.49 

data.age$prop.less.1 <- data.age$foxes.less1 / data.age$no.foxes
data.age$prop.1.2 <- data.age$foxes.1.2 / data.age$no.foxes
data.age$prop.2.3 <- data.age$foxes.2.3 / data.age$no.foxes
data.age$prop.3.4 <- data.age$foxes.3.4 / data.age$no.foxes
data.age$prop.4.5 <- data.age$foxes.4.5 / data.age$no.foxes
data.age$prop.5.6 <- data.age$foxes.5.6 / data.age$no.foxes
data.age$prop.6.7 <- data.age$foxes.6.7 / data.age$no.foxes
data.age$prop.more7 <- data.age$foxes.more7 / data.age$no.foxes

data.y16w13 <- data.age[data.age$year == 16,]
data.y16w13 <- data.y16w13[data.y16w13$week.of.year == 13,]

output <- data.frame()

variables <- c("prop.less.1", "prop.1.2", "prop.2.3", "prop.3.4", "prop.4.5", "prop.5.6", "prop.6.7", "prop.more7")

for (i in variables)
  
{
  i.mean <- format(round(mean(data.y16w13[[i]]) * 100, 1), nsmall = 1)
  i.min <-  format(round(min(data.y16w13[[i]])* 100, 1), nsmall = 1)
  i.max <- format(round(max(data.y16w13[[i]])* 100, 1), nsmall = 1)
  
  i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
  i.output <- as.data.frame(i.output)
  i.output$year <- i 
  
  output <- rbind(output, i.output)
}

i <- "density.adult"

i.mean <- format(round(mean(data.y16w13[[i]]), 2), nsmall = 2)
i.min <-  format(round(min(data.y16w13[[i]]), 2), nsmall = 2)
i.max <- format(round(max(data.y16w13[[i]]), 2), nsmall = 2)

i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
i.output <- as.data.frame(i.output)
i.output$year <- i 

output <- rbind(output, i.output)

bristol.output <- output

##########################


# BRISTOL - extra mortl

data.age <- data.frame()

for (i in c(1:30) )
{
  data.oneHR <- read.csv(paste0("bristol_pop_age_structure/Bristol_pop_age_structure_extramort_45ha_headless", i, ".csv"))
  data.oneHR$run <- i
  data.oneHR$HRsize <- 45
  data.age <- rbind(data.age, data.oneHR)
}

write.csv(data.age, paste0("bristol_pop_age_structure/Bristol_age_structure_extramort_all.csv"))

#View(data.age)

data.age$density <- data.age$no.foxes / 114.49 #density in foxes / km2, adjusted for actual region size (114.49km2)
data.age$density.adult <- (data.age$no.foxes - data.age$foxes.less1) / 114.49 

data.age$prop.less.1 <- data.age$foxes.less1 / data.age$no.foxes
data.age$prop.1.2 <- data.age$foxes.1.2 / data.age$no.foxes
data.age$prop.2.3 <- data.age$foxes.2.3 / data.age$no.foxes
data.age$prop.3.4 <- data.age$foxes.3.4 / data.age$no.foxes
data.age$prop.4.5 <- data.age$foxes.4.5 / data.age$no.foxes
data.age$prop.5.6 <- data.age$foxes.5.6 / data.age$no.foxes
data.age$prop.6.7 <- data.age$foxes.6.7 / data.age$no.foxes
data.age$prop.more7 <- data.age$foxes.more7 / data.age$no.foxes

data.y16w13 <- data.age[data.age$year == 16,]
data.y16w13 <- data.y16w13[data.y16w13$week.of.year == 13,]

output <- data.frame()

variables <- c("prop.less.1", "prop.1.2", "prop.2.3", "prop.3.4", "prop.4.5", "prop.5.6", "prop.6.7", "prop.more7")

for (i in variables)
  
{
  i.mean <- format(round(mean(data.y16w13[[i]]) * 100, 1), nsmall = 1)
  i.min <-  format(round(min(data.y16w13[[i]])* 100, 1), nsmall = 1)
  i.max <- format(round(max(data.y16w13[[i]])* 100, 1), nsmall = 1)
  
  i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
  i.output <- as.data.frame(i.output)
  i.output$year <- i 
  
  output <- rbind(output, i.output)
}

i <- "density.adult"

i.mean <- format(round(mean(data.y16w13[[i]]), 2), nsmall = 2)
i.min <-  format(round(min(data.y16w13[[i]]), 2), nsmall = 2)
i.max <- format(round(max(data.y16w13[[i]]), 2), nsmall = 2)

i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
i.output <- as.data.frame(i.output)
i.output$year <- i 

output <- rbind(output, i.output)

bristol.output.extramort <- output

finaloutput <- cbind(bristol.output, bristol.output.extramort$i.output, carnarvon.output$i.output)
write.csv(finaloutput, "bristol_pop_age_structure/summary_bristol_carnarvon_agestructure.csv")
