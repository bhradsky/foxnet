rm(list=ls())

library(ggplot2)
library(plyr)
library(dplyr)
library(stringr)
options(scipen=999)

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

#load the output files
data.1 <- read.csv("carnarvon_bait/Carnarvon_bait-table_0305death_15rep.csv", skip = 6)
data.2 <- read.csv("carnarvon_bait/Carnarvon_bait-table_07death_15rep.csv", skip = 6)
data.3 <- read.csv("carnarvon_bait/Carnarvon_bait-table_030507death_15rep.csv", skip = 6)
data.all <- rbind(data.1, data.2, data.3)

data.all.baseline <- tbl_df(data.all)

summary.baseline <- data.all.baseline %>% group_by(Pr.die.if.exposed.100ha, X.step., year, week.of.year) %>%
  summarise_at(vars(all.fox.but.cub.density), funs(mean, median, sd, min, max, n()))
summary.baseline$step <- paste0(summary.baseline$year, "_", summary.baseline$week.of.year)
summary.baseline$step2 <- ((summary.baseline$X.step. - 1) / 13 ) + 1

prebait.density <- summary.baseline[summary.baseline$step == "16_29",]
prebait.density.0.3 <- prebait.density[prebait.density$Pr.die.if.exposed.100ha == 0.3,]
mean.prebait.density.0.3 <- prebait.density.0.3$mean

prebait.density <- summary.baseline[summary.baseline$step == "16_29",]
prebait.density.0.5 <- prebait.density[prebait.density$Pr.die.if.exposed.100ha == 0.5,]
mean.prebait.density.0.5 <- prebait.density.0.5$mean

prebait.density <- summary.baseline[summary.baseline$step == "16_29",]
prebait.density.0.7 <- prebait.density[prebait.density$Pr.die.if.exposed.100ha == 0.7,]
mean.prebait.density.0.7 <- prebait.density.0.7$mean

summary.baseline$plot.mean <- ifelse(summary.baseline$Pr.die.if.exposed.100ha == 0.3,
                                        summary.baseline$mean /  mean.prebait.density.0.3,
                                     ifelse(summary.baseline$Pr.die.if.exposed.100ha == 0.5,
                                            summary.baseline$mean /  mean.prebait.density.0.5,
                                     summary.baseline$mean /  mean.prebait.density.0.7))

summary.baseline$plot.min <- ifelse(summary.baseline$Pr.die.if.exposed.100ha == 0.3,
                                     summary.baseline$min /  mean.prebait.density.0.3,
                                     ifelse(summary.baseline$Pr.die.if.exposed.100ha == 0.5,
                                            summary.baseline$min /  mean.prebait.density.0.5,
                                            summary.baseline$min /  mean.prebait.density.0.7))

summary.baseline$plot.max <- ifelse(summary.baseline$Pr.die.if.exposed.100ha == 0.3,
                                     summary.baseline$max /  mean.prebait.density.0.3,
                                     ifelse(summary.baseline$Pr.die.if.exposed.100ha == 0.5,
                                            summary.baseline$max /  mean.prebait.density.0.5,
                                            summary.baseline$max /  mean.prebait.density.0.7))

summary.baiting <- summary.baseline[summary.baseline$step2 > 16.5,]
summary.baiting <- summary.baiting[summary.baiting$step2 < 18.5,]
summary.baiting$weeksafter <- rep(seq(-4, 96, 4), 3)

#import data from Thomson et al 2000
thomson <- read.csv("carnarvon_bait/DatafromGetGraph.csv")
thomson.core <- thomson[thomson$Line == 2,]

summary.baiting$Pr.die.if.exposed.100ha <- as.character(summary.baiting$Pr.die.if.exposed.100ha)

fox.plot <- ggplot(summary.baiting)
plot.av <- geom_line(aes(x = weeksafter, y = plot.mean * 100, group = Pr.die.if.exposed.100ha, linetype = Pr.die.if.exposed.100ha))
plot.minmax <- geom_ribbon(aes(x = weeksafter, ymin = plot.min * 100, ymax = plot.max * 100, group = Pr.die.if.exposed.100ha, fill = Pr.die.if.exposed.100ha, alpha = Pr.die.if.exposed.100ha)) 

Fig4.Carnavon.bait <- fox.plot + 
  plot.minmax + plot.av + 
  theme_classic() +
  scale_y_continuous(limits = c(0,110), expand = c(0, 0), breaks=seq(0, 100, 20)) +
  scale_x_continuous(limits = c(-6,96), expand = c(0, 0), breaks=seq(0, 96, 12)) +
  scale_linetype_manual(values = c("dotted", "dashed", "solid")) +
  scale_fill_manual(values = c("darkgrey", "darkgrey", "darkgrey")) +
  scale_alpha_manual(values = c(0.4, 0.4, 0.4)) +
  labs(title="", y="% of original population", x="Weeks post-baiting") +
  theme(legend.position = "none") +
  geom_segment(aes(x=40, xend=40,y=108, yend=98), 
               arrow = arrow(length = unit(0.2, "cm"))) +
  geom_segment(aes(x=76, xend=76, y=108, yend=98), 
               arrow = arrow(length = unit(0.2, "cm"))) +
  geom_segment(aes(x=92, xend=92, y=108, yend=98), 
               arrow = arrow(length = unit(0.2, "cm"))) +
  geom_point(data = thomson.core, aes(x = t.x, y = t.y, group = Line), size = 2)



tiff(paste0("figures/Fig4_Carnarvon_bait.tiff"),
     width=7, height=7, units = 'cm', res = 300)

Fig4.Carnavon.bait

dev.off()
