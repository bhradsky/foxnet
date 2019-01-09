rm(list=ls())

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

# BRISTOL

data.age <- data.frame()

for (i in c(1:30) )
{
  data.oneHR <- read.csv(paste0("bristol_pop_age_structure/Bristol_pop_age_structure_45ha_headless", i, ".csv"))
  data.oneHR$run <- i
  data.oneHR$HRsize <- 45
  data.age <- rbind(data.age, data.oneHR)
}

#write.csv(data.age, paste0("bristol_pop_age_structure/Bristol_age_structure_all.csv"))

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
  i.mean <- mean(data.y16w13[[i]]) * 100
  i.min <-  min(data.y16w13[[i]])* 100
  i.max <- max(data.y16w13[[i]])* 100
  
  i.output <- cbind(i.mean, i.min, i.max)
  i.output <- as.data.frame(i.output)
  i.output$group <- i 
  
  output <- rbind(output, i.output)
}

output$model <- "FoxNet"
bristol.Foxnet <- output

#----------------------

# Bristol model with extra mortality 

data.age <- data.frame()

for (i in c(1:30) )
{
  data.oneHR <- read.csv(paste0("bristol_pop_age_structure/Bristol_pop_age_structure_extramort_45ha_headless", i, ".csv"))
  data.oneHR$run <- i
  data.oneHR$HRsize <- 45
  data.age <- rbind(data.age, data.oneHR)
}

#write.csv(data.age, paste0("bristol_pop_age_structure/Bristol_age_structure_extramort_all.csv"))

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
  i.mean <- mean(data.y16w13[[i]]) * 100
  i.min <-  min(data.y16w13[[i]])* 100
  i.max <- max(data.y16w13[[i]])* 100
  
  i.output <- cbind(i.mean, i.min, i.max)
  i.output <- as.data.frame(i.output)
  i.output$group <- i 
  
  output <- rbind(output, i.output)
}

output$model <- "FoxNet (extra mortality)"

bristol.extramort <- output

#------------
# field observations

Bristol.Harris.1987 <-  data.frame("group" = variables)
Bristol.Harris.1987$i.mean <- c(49.8, 23.7, 12.8, 6.8, 3.9, 1.7, 0.7, 0.7)
Bristol.Harris.1987$i.min <- NA
Bristol.Harris.1987$i.max <- NA
Bristol.Harris.1987$model <- "Harris & Smith (1987)"


final.bristol <- rbind(bristol.Foxnet, bristol.extramort, Bristol.Harris.1987) #
final.bristol$cat <- c(0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7)

#final.bristol$model <- factor(final.bristol$model, levels = c("Harris & Smith (1987)", "FoxNet" )) #"FoxNet (extra mortality)"

library(ggplot2)




bristol <- ggplot(data = final.bristol, aes(x = cat, y = i.mean, group = model)) +
  geom_line(aes(linetype = model), color = "black") +
  geom_errorbar(aes(x = cat, ymin=i.min, ymax=i.max),
                width=.1, color = "darkgrey") +
  geom_point(aes(shape = model)) +
  labs(title="a) Bristol", y = "Population (%)", x="Age (years)") +   
  theme_classic() +
  theme(legend.position = c(0.7, 0.9)) +
  theme(legend.title=element_blank()) +
  scale_y_continuous(expand = c(0, 0), breaks=seq(0, 50, 10)) +
  scale_x_continuous(expand = c(0, 0), breaks=seq(0, 8, 1))


###################


#rm(list=ls())

#setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

# CARNARVON

data.age <- data.frame()

for (i in 1:30) 
{
  data.oneHR <- read.csv(paste0("carnarvon_age/Carnarvon_agestructure_HR5_headless", i, ".csv"))
  data.oneHR$run <- i
  data.oneHR$HRsize <- 500
  data.age <- rbind(data.age, data.oneHR)
}

#write.csv(data.age, paste0("carnarvon_age/Carnarvon_agestructure_HR5.csv"))

#View(data.age)
data.age$density <- data.age$no.foxes / 198.81 #density in foxes / km2.  Note actual region size was 198.81km2, not 200km2
data.age$density.adult <- (data.age$no.foxes - data.age$foxes.less1) / 198.81 #density in foxes / km2.  Note actual region size was 196km2, not 200km2

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
  i.mean <- mean(data.y16w49[[i]]) * 100
  i.min <-  min(data.y16w49[[i]])* 100
  i.max <- max(data.y16w49[[i]])* 100
  
  i.output <- cbind(i.mean, i.min, i.max)
  i.output <- as.data.frame(i.output)
  i.output$group <- i 
  
  output <- rbind(output, i.output)
}

output$model <- "FoxNet"
Carnarvon.Foxnet <- output

Carnavon.Marlowetal.2000 <-  data.frame("group" = variables)
Carnavon.Marlowetal.2000$i.mean <- c(53.9, 14.2, 11.3, 16.2, 2.0, 1.0, 1.0, 0.5)
Carnavon.Marlowetal.2000$i.min <- NA
Carnavon.Marlowetal.2000$i.max <- NA
Carnavon.Marlowetal.2000$model <- "Marlow et al. (2000)"


final.carnarvon <- rbind(Carnarvon.Foxnet, Carnavon.Marlowetal.2000)
final.carnarvon$cat <- c(0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7)

library(ggplot2)

carnarvon <- ggplot(data = final.carnarvon, aes(x = cat, y = i.mean, group = model)) +
  geom_errorbar(aes(x = cat, ymin=i.min, ymax=i.max),
                width=.1, color = "darkgrey") +
  geom_point(aes(shape = model), color = "black") +
  geom_line(aes(linetype = model), color = "black") +
  labs(title="b) Carnarvon", y = "", x="Age (years)") +   
  theme_classic() +
  theme(legend.position = c(0.7, 0.9)) +
  theme(legend.title=element_blank()) +
  scale_y_continuous(expand = c(0, 0), breaks=seq(0, 50, 10)) +
  scale_x_continuous(expand = c(0, 0), breaks=seq(0, 8, 1))


# COMPILE PLOT
library(gridExtra)

tiff(paste0("figures/Fig2_agestructure.tiff"),
     width=15, height=7.5, units = 'cm', res = 300)

grid.arrange(bristol, carnarvon,
             ncol=2, nrow=1)


dev.off()



######################################################

# TEST WHETHER RELATIONSHIPS ARE 1:1
bristol.test <- lm(bristol.Foxnet$i.mean ~ Bristol.Harris.1987$i.mean)
summary(bristol.test)

extra.mort.test<- lm(bristol.extramort$i.mean ~ Bristol.Harris.1987$i.mean)
summary(extra.mort.test)
plot(bristol.extramort$i.mean ~ Bristol.Harris.1987$i.mean)

carnarvon.test <- lm(Carnarvon.Foxnet$i.mean ~ Carnavon.Marlowetal.2000$i.mean)
summary(carnarvon.test)

#####

# CARNAVON DENSITY

i <- "density.adult"
i.mean <- format(round(mean(data.y16w49[[i]]), 2), nsmall = 2)
i.min <-  format(round(min(data.y16w49[[i]]), 2), nsmall = 2)
i.max <- format(round(max(data.y16w49[[i]]), 2), nsmall = 2)

i.output <- paste0(i.mean, " (", i.min,", ", i.max, ")")
i.output <- as.data.frame(i.output)
i.output$year <- i 

####
