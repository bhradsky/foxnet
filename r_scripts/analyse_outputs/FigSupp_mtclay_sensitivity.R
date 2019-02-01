rm(list=ls())

library(ggplot2)
library(plyr)
library(dplyr)
library(stringr)
options(scipen=999)

theme <- theme(axis.line = element_line(colour = "black"),
               panel.grid.major = element_blank(),
               panel.grid.minor = element_blank(),
               panel.border = element_blank(),
               panel.background = element_blank())

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

#load the baseline datafiles

#current regime
data.currentbait <- data.frame()
data.one <- for (i in 1:30) 
{
  data.one <- read.csv(paste0("mtclay/MtClay_baseline/MtClay_baseline_baited_custom_headless", i, "_test.csv"))
  data.one$run <- i
  data.currentbait<- rbind(data.currentbait, data.one)
}
data.currentbait$current <- 1

# fecundity
data.fecundity <- data.frame()
experiment <- c(1.87, 2.992, 4.488, 5.61)
data.one <- for (n in experiment)
{
  for (i in 1:30) 
  {
  data.one <- read.csv(paste0("mtclay/MtClay_sensitivity/Littersize/MtClay_sensitivity_litter_", n, "_headless", i, ".csv"))
  data.one$run <- i
  data.fecundity <- rbind(data.fecundity, data.one)
  }
}

# home range size
data.hr <- data.frame()
experiment <- c(107, 171, 257, 321 ) # , 
data.one <- for (n in experiment)
{
  for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_sensitivity/HRsize/MtClay_sensitivity_HR_", n, "_headless", i, ".csv"))
    data.one$run <- i
    data.one$HRsize <- n
    data.hr <- rbind(data.hr, data.one)
  }
}

#xtabs(~data.hr$HRsize)

#female dispersers
data.fdisperser <- data.frame()
experiment <- c(0.35, 0.56, 0.84, 0.999 )
data.one <- for (n in experiment)
{
  for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_sensitivity/fdispersers/MtClay_sensitivity_fdisp_", n, "_headless", i, ".csv"))
    data.one$run <- i
    data.fdisperser <- rbind(data.fdisperser, data.one)
  }
}

#bait efficacy
data.efficacy <- data.frame()
experiment <- c(0.15, 0.24, 0.36, 0.45)
data.one <- for (n in experiment)
{
  for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_sensitivity/efficacy/MtClay_sensitivity_baitefficacy_", n, "_headless", i, ".csv"))
    data.one$run <- i
    data.efficacy <- rbind(data.efficacy, data.one)
  }
}

#productivity
data.productivity <- data.frame()
experiment <- c(0.5, 0.8, 1.2, 1.5)
data.one <- for (n in experiment)
{
  for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_sensitivity/productivity/MtClay_sensitivity_farmforest_", n, "_headless", i, ".csv"))
    data.one$run <- i
    data.productivity <- rbind(data.productivity, data.one)
  }
}

# CALCULATE BASELINE AVERAGE
data.current.18.27 <- data.currentbait[data.currentbait$year > 17 & data.currentbait$year < 28,]

years18.27.current <- data.current.18.27  %>% group_by(current, run) %>%
  summarise_at(vars(all.fox.but.cub.density), funs(mean, sd, min, max))

years18.27.current$max.d <- years18.27.current$max
years18.27.current.max <- years18.27.current %>% group_by(current) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

meanfoxdensity <- years18.27.current.max$mean[1] # average max fox density post-baiting

#RESPONSES TO BAITING

output.table <- data.frame()

variable <- c("current", "littersize", "HRsize", "baitefficacy", "fdisperse", "farmforest")

for (v in variable)
{
  
  
  if (v == "current") {mydata <- data.currentbait }
  if (v == "current") {baseline.value <- 1}
  
  if (v == "littersize") {mydata <- data.fecundity }
  if (v == "littersize") {baseline.value <- 3.74}

  if (v == "HRsize") {mydata <- data.hr}
  if (v == "HRsize") {baseline.value <- 214}
  
  if (v == "baitefficacy") {mydata <- data.efficacy}
  if (v == "baitefficacy") {baseline.value <- 0.3}

  if (v == "farmforest") {mydata <- data.productivity}
  if (v == "farmforest") {baseline.value <- 100}
  
  if (v == "fdisperse") {mydata <- data.fdisperser}
  if (v == "fdisperse") {baseline.value <- 0.7}

  
postbaiting.treatment <- mydata[mydata$year > 17 &mydata$year < 28,]

#treatment <- postbaiting.treatment[postbaiting.treatment[v] != baseline.value, ]

treatment <- tbl_df(postbaiting.treatment)
#treatment.group <- group_by_(treatment, .dots = v)
#summary.treatment <- summarize(treatment.group, counts = n(), density.mean = mean(total.fox.density, na.rm = T), density.min = min(total.fox.density, na.rm = T), density.max =max(total.fox.density, na.rm = T))
#summary.treatment.df <- as.data.frame(summary.treatment)

summary.treatment <- treatment %>% group_by_("run", .dots = v) %>%
  summarise_at(vars(all.fox.but.cub.density), funs(mean, median, sd, min, max))

summary.treatment$max.d <- summary.treatment$max
summary.treatment.max <- summary.treatment %>% group_by_(.dots = v) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

summary.treatment.df <- as.data.frame(summary.treatment.max )

summary.treatment.df$proportion <- summary.treatment.df[,1] / baseline.value
summary.treatment.df$sensitivity <- (summary.treatment.df$mean - meanfoxdensity) / summary.treatment.df$proportion
summary.treatment.df$perc.change <- (summary.treatment.df$mean - meanfoxdensity) / meanfoxdensity
summary.treatment.df$variable <- v
names(summary.treatment.df) <- c("value", "maxdensity.mean", "maxdensity.sd", "maxdensity.min", "maxdensity.max", "proportion", "sensitivity", "perc.change", "variable")

#CORRECT FEMALE DISPERSERS WHERE PROPORTION IS 1.427 instead of 1.5
summary.treatment.df$proportion <- ifelse(summary.treatment.df$variable == "fdispersers" & summary.treatment.df$value == 0.99999, 1.5, summary.treatment.df$proportion)

output.table <- rbind(output.table, summary.treatment.df)
}

output.table.sort <- output.table[order(output.table$perc.change),]

plot.data <- output.table

# fix up names
plot.data$variable <- ifelse(plot.data$variable == "current", "baseline", as.character(plot.data$variable))
plot.data$variable <- ifelse(plot.data$variable == "littersize", "litter size", as.character(plot.data$variable))
plot.data$variable <- ifelse(plot.data$variable == "HRsize", "range area", as.character(plot.data$variable))
plot.data$variable <- ifelse(plot.data$variable == "baitefficacy", "bait efficacy", as.character(plot.data$variable))
plot.data$variable <- ifelse(plot.data$variable == "farmforest", "farm:forest", as.character(plot.data$variable))
plot.data$variable <- ifelse(plot.data$variable == "fdisperse", "female dispersers", as.character(plot.data$variable))

plot.data$variable <- factor(plot.data$variable, levels = c("baseline", "litter size", "female dispersers", "range area", "farm:forest", "bait efficacy"))

plot.data <- plot.data[plot.data$variable != "baseline",]
#### -Make the plot- ####

plot.sensitivity <- ggplot(plot.data, aes(x = variable, y = maxdensity.mean,  group = proportion, col = as.factor(proportion))) +
  geom_hline(yintercept = output.table$maxdensity.mean[1], col = "darkgrey") +
  geom_hline(yintercept = output.table$maxdensity.min[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = output.table$maxdensity.max[1], col = "darkgrey", linetype = "dotted") +
  geom_point(size = 2.5, position = position_dodge(width = 0.5)) + 
  geom_errorbar(aes(ymin=maxdensity.min, ymax=maxdensity.max), width=.2, position = position_dodge(width = 0.5)) +
  labs(title="", y = expression("Maximum fox density (individuals km"^-{2}* ")"), x="Parameter") +   
  theme +
 # scale_y_continuous(limits = c(-0.05,1.5), expand = c(0, 0), breaks=seq(0, 1.5, 0.25)) +
  theme(legend.position = c(0.8, 0.9)) +
  scale_colour_grey(name  =" ", start = 0, end = .8,
                          breaks=c("0.5", "0.8", "1", "1.2", "1.5"),
                          labels=c("-50%", "-20%", "current", "+20%", "+50%")) +
  theme(legend.key=element_blank()) +
  guides(colour=guide_legend(ncol=2, nrow = 2))

tiff(paste0("figures/FigS4_MtClay_sensitivity.tiff"),
     width=15, height=10, units = 'cm', res = 300)
plot.sensitivity 

dev.off()


############################################################################

#FECUNDITY

# add year variable
data.fecundity$year.scaled <- (data.fecundity$X - 1)/ 26 + 1

# calculate summary statistics for 10 years of baiting
data.fecundity.15 <- data.fecundity[data.fecundity$year == 15,]

data.fecundity.15 <- data.fecundity.15  %>% group_by(littersize, run) %>%
  summarise_at(vars(all.fox.but.cub.density), funs(mean, sd, min, max))

data.fecundity.15$max.d <- data.fecundity.15$max

data.fecundity.15.max <- data.fecundity.15 %>% group_by(littersize) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))


# HOME RANGE SIZE
# add year variable
data.hr$year.scaled <- (data.hr$X - 1)/ 26 + 1

# calculate summary statistics for 10 years of baiting
data.hr.15 <- data.hr[data.hr$year == 15,]

data.hr.15 <- data.hr.15  %>% group_by(HRsize, run) %>%
  summarise_at(vars(all.fox.but.cub.density), funs(mean, sd, min, max))

data.hr.15$max.d <- data.hr.15$max

data.hr.15.max <- data.hr.15 %>% group_by(HRsize) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

