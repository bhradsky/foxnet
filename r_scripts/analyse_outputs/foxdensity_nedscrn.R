rm(list=ls())

library(ggplot2)
library(plyr)
library(dplyr)
library(stringr)
options(scipen=999)

setwd("C:/Users/hradskyb/Dropbox/personal/bron/ibm/foxnet_github")

data.all <- read.csv("outputs/nedscrn/foxnet_neds_monthly_simple.csv")
# BASELINE DATA

# import dataframes

data.all$year.scaled <- (data.all$X.step - 1)/ 26 + 1

# Calculate mean, min, max values for each time point for baited and unbaited scenarios

summary.baseline <- data.all %>% group_by(year, week.of.year, year.scaled) %>%
  summarise_at(vars(all.fox.but.cub.density), list(mean = mean, min = min, max = max)) %>%
  filter(year < 23)

summary.baseline$comparison <- rep(summary.baseline$mean[235:260], 22)

summary.baseline$diff <- ((summary.baseline$mean - summary.baseline$comparison ) / summary.baseline$comparison)  * 100

#make trajectory plot

fox.plot <- ggplot(summary.baseline)
plot.av <- geom_line(aes(x = year.scaled, y = mean))
plot.minmax <- geom_ribbon(aes(x = year.scaled, ymin = min, ymax = max), fill = "grey" )

densityplot <- fox.plot + 
  plot.minmax + plot.av  +
  scale_y_continuous(limits = c(0,2.7), expand = c(0, 0), breaks=seq(0, 2.5, 0.5)) +
  scale_x_continuous(limits = c(8,24), expand = c(0, 0), breaks=seq(6, 23, 2)) +
  #scale_alpha_manual(values = c( 0.2)) +
  labs(title="a) Fox density", y=expression("Fox density (individuals km "^-{2}* ")"), x="Year") +
  theme_classic() +
  theme(legend.position = "none") +
  geom_vline(xintercept = 11, linetype = 2) + 
  geom_vline(xintercept = 17, linetype = 2)

densityplot

# plot of difference
 fox.plot <- ggplot(summary.baseline)
 plot.diff <- geom_line(aes(x = year.scaled, y = diff))
 plot.minmax <- geom_ribbon(aes(x = year.scaled, ymin = min, ymax = max), fill = "grey" )
 
diffplot <-  fox.plot + 
   plot.diff +
   scale_y_continuous(limits = c(-80, 5), expand = c(0, 0), breaks=seq(-80, 0, 20)) +
   scale_x_continuous(limits = c(8,24), expand = c(0, 0), breaks=seq(6, 23, 2)) +
   labs(title="b) Difference in density", y=expression("% difference"), x="Year") +
   theme_classic() +
   theme(legend.position = "none") +
   geom_vline(xintercept = 11, linetype = 2) + 
   geom_vline(xintercept = 17, linetype = 2)
 
diffplot
# COMPILE PLOT
library(gridExtra)

tiff(paste0("outputs/nedscrn/baiting_monthly.tiff"),
     width=15, height=8, units = 'cm', res = 300)

grid.arrange(densityplot, diffplot,
             ncol=2, nrow=1)


dev.off()



# calculate summary statistics for 10 years of baiting
data.10 <- summary.baseline[summary.baseline$year == 10,]
summary(data.10)
data.16 <- summary.baseline[summary.baseline$year == 16,]

data.22 <- summary.baseline[summary.baseline$year == 22,]
