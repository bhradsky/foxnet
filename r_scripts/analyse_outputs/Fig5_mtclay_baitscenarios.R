rm(list=ls())

library(ggplot2)
library(plyr)
library(dplyr)
library(stringr)
options(scipen=999)

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

# BASELINE DATA

# import dataframes

data.baited <- data.frame()
data.one <- for (i in 1:30) 
{
  data.one <- read.csv(paste0("mtclay/MtClay_baseline/MtClay_baseline_baited_headless", i, ".csv"))
  data.one$run <- i
  data.baited <- rbind(data.baited, data.one)
}
data.baited$bait.layout <- "baited"

data.unbaited <- data.frame()
data.one <- for (i in 1:30) 
{
  data.one <- read.csv(paste0("mtclay/MtClay_baseline/MtClay_baseline_baited_none_headless_", i, ".csv"))
  data.one$run <- i
  data.unbaited <- rbind(data.unbaited, data.one)
}
data.unbaited$bait.layout <- "none"

data.all <- rbind(data.baited, data.unbaited)
data.all$year.scaled <- (data.all$X - 1)/ 26 + 1

# Calculate mean, min, max values for each time point for baited and unbaited scenarios
data.all.baseline <- tbl_df(data.all)
summary.baseline <- data.all.baseline %>% group_by(bait.layout, year, week, year.scaled) %>%
  summarise_at(vars(all.but.cub.density), funs(mean, min, max))

# extract data for plot
summary.baseline.plot <- summary.baseline[summary.baseline$year.scaled > 15.96 & summary.baseline$year.scaled < 28,] 

#make trajectory plot

fox.plot <- ggplot(summary.baseline.plot)
plot.av <- geom_line(aes(x = year.scaled, y = mean, group = bait.layout, linetype = bait.layout))
plot.minmax <- geom_ribbon(aes(x = year.scaled, ymin = min, ymax = max, group = bait.layout, alpha = bait.layout) )

plot.MtClay.baseline <- fox.plot + 
  plot.av + plot.minmax +
  scale_y_continuous(limits = c(0,3.1), expand = c(0, 0), breaks=seq(0, 3, 0.5)) +
  scale_x_continuous(limits = c(15.9,28), expand = c(0, 0), breaks=seq(16, 28, 2)) +
  scale_alpha_manual(values = c(0.3, 0.2)) +
  labs(title="a)", y=expression("Fox density (individuals km "^-{2}* ")"), x="Year") +
  theme_classic() +
  theme(legend.position = "none")

# calculate summary statistics for 10 years of baiting
data.all.18.27 <- data.all.baseline[data.all.baseline$year > 17 & data.all.baseline$year < 28,]
 
years18.27 <- data.all.18.27  %>% group_by(bait.layout, run) %>%
  summarise_at(vars(all.but.cub.density), funs(mean, sd, min, max))

years18.27$max.d <- years18.27$max
years18.27.max <- years18.27 %>% group_by(bait.layout) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

years18.27$min.d <- years18.27$min
years18.27.min <- years18.27 %>% group_by(bait.layout) %>% 
  summarise_at(vars(min.d), funs(mean, sd, min, max))

# perc.difference
(years18.27.max$mean[2] - years18.27.max$mean[1]) / years18.27.max$mean[2]


###################

# BAIT FREQUENCY DATA

# import experiment dataframes

data.freq <- data.frame()

baitfreq <- c("monthly", "quarterly", "summer", "autumn", "winter", "spring")

for (w in baitfreq)
{
  data.one <- for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_baiting/frequency/MtClay_baiting_freq_", w, "_headless_", i, ".csv"))
    data.one$run <- i
    data.freq <- rbind(data.freq, data.one)
  }
}

#check it's loaded correctly
xtabs(~data.freq$baitfreq + data.freq$run)


# add year variable
data.freq$year.scaled <- (data.freq$X - 1)/ 26 + 1

# calculate summary statistics for 10 years of baiting
data.freq.18.27 <- data.freq[data.freq$year > 17 & data.freq$year < 28,]

freq.years18.27 <- data.freq.18.27  %>% group_by(baitfreq, run) %>%
  summarise_at(vars(all.but.cub.density), funs(mean, sd, min, max))

freq.years18.27$max.d <- freq.years18.27$max

freq.years18.27.max <- freq.years18.27 %>% group_by(baitfreq) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

# perc diff to current baiting scenario
freq.years18.27.max$diff <- (freq.years18.27.max$mean - years18.27.max$mean[1]) / years18.27.max$mean[1]
freq.years18.27.max$diff2 <- freq.years18.27.max$mean / years18.27.max$mean[1]

freq.years18.27.max$diff.unbaited <- 1 - (years18.27.max$mean[2] - freq.years18.27.max$mean ) / years18.27.max$mean[2]
freq.years18.27.max$diff.unbaited2 <- freq.years18.27.max$mean  / years18.27.max$mean[2]


freq.years18.27.max$freq <- ifelse(freq.years18.27.max$baitfreq == "monthly", "13",
                                (ifelse(freq.years18.27.max$baitfreq == "quarterly", "4",
                                        (ifelse(freq.years18.27.max$baitfreq == "summer", "1(Jan)",
                                                (ifelse(freq.years18.27.max$baitfreq == "autumn", "1(Apr)",
                                                        (ifelse(freq.years18.27.max$baitfreq == "winter", "1(Jul)",
                                                                (ifelse(freq.years18.27.max$baitfreq == "spring", "1(Sep)", "XXX")))))))))))

freq.years18.27.max$freq <- factor(freq.years18.27.max$freq,
                                           levels = c("13", "4", "1(Jan)", "1(Apr)", "1(Jul)", "1(Sep)"))


plot.baitfreq <- ggplot(freq.years18.27.max, aes(x = freq, y = mean)) +
  geom_hline(yintercept = years18.27.max$mean[1], col = "darkgrey") +
  geom_hline(yintercept = years18.27.max$min[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$max[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$mean[2], col = "darkgrey", linetype = "dashed") +
  geom_hline(yintercept = years18.27.max$min[2], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$max[2], col = "darkgrey", linetype = "dotted") +
  geom_point(size = 2) + 
  geom_errorbar(aes(ymin=min, ymax=max), width=.1) +
  labs(title="b)", y=expression("Max fox density (individuals km "^-{2}* ")"), x="Bait frequency (times per year)") +   
  theme_classic() +
  scale_y_continuous(limits = c(0,3.1), expand = c(0, 0), breaks=seq(0, 3, 0.5)) 



####################################################################

# BAIT DENSITY

# import experiment dataframes

data.density <- data.frame()

baitdensity <- c("0.5", "1")

for (w in baitdensity)
{
  data.one <- for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_baiting/density/MtClay_baiting_density_", w, "_headless2_", i, ".csv"))
    data.one$run <- i
    data.density <- rbind(data.density, data.one)
  }
}


baitdensity <- c("2", "4", "6", "8")

for (w in baitdensity)
{
  data.one <- for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_baiting/density/MtClay_baiting_density_", w, "_headless_", i, ".csv"))
    data.one$run <- i
    data.density <- rbind(data.density, data.one)
  }
}

#check it's loaded correctly
xtabs(~data.density$baitdensity + data.density$run)

# add year variable
data.density$year.scaled <- (data.density$X - 1)/ 26 + 1

# calculate summary statistics for 10 years of baiting
data.density.18.27 <- data.density[data.density$year > 17 & data.density$year < 28,]

density.years18.27 <- data.density.18.27  %>% group_by(baitdensity, run) %>%
  summarise_at(vars(all.but.cub.density), funs(mean, sd, min, max))

density.years18.27$max.d <- density.years18.27$max

density.years18.27.max <- density.years18.27 %>% group_by(baitdensity) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

# perc diff to current baiting scenario
density.years18.27.max$diff <- (years18.27.max$mean[1] - density.years18.27.max$mean) / years18.27.max$mean[1]
density.years18.27.max$diff2 <-  density.years18.27.max$mean / years18.27.max$mean[1]


plot.baitdensity <- ggplot(density.years18.27.max, aes(x = baitdensity, y = mean)) +
  geom_hline(yintercept = years18.27.max$mean[1], col = "darkgrey") +
  geom_hline(yintercept = years18.27.max$min[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$max[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$mean[2], col = "darkgrey", linetype = "dashed") +
  geom_hline(yintercept = years18.27.max$min[2], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$max[2], col = "darkgrey", linetype = "dotted") +
  geom_point(size = 2) + 
  geom_errorbar(aes(ymin=min, ymax=max), width=.1) +
  labs(title="c)", y=expression("Max fox density (individuals km "^-{2}* ")"), x=expression("Bait density (baits km "^-{2}* ")")) +   
  theme_classic() +
  scale_y_continuous(limits = c(0,3.1), expand = c(0, 0), breaks=seq(0, 3, 0.5)) +
  scale_x_continuous(limits = c(0,8.2), expand = c(0, 0), breaks=seq(0, 8, 1))

####################################################################
# BAITED BUFFER ZONE

# import experiment dataframes

data.buffer <- data.frame()

bufferwidths <- c(1000, 2000, 4000, 6000, 8000, 10000)

for (w in bufferwidths)
{
  data.one <- for (i in 1:30) 
  {
    data.one <- read.csv(paste0("mtclay/MtClay_baiting/buffer/MtClay_baiting_buffer_", w, "_headless_", i, ".csv"))
    data.one$run <- i
    data.buffer <- rbind(data.buffer, data.one)
  }
}

#check it's loaded correctly
xtabs(~data.buffer$bufferwidth + data.buffer$run)

# add year variable
data.buffer$year.scaled <- (data.buffer$X - 1)/ 26 + 1

# calculate summary statistics for 10 years of baiting
data.buffer.18.27 <- data.buffer[data.buffer$year > 17 & data.buffer$year < 28,]

buffer.years18.27 <- data.buffer.18.27  %>% group_by(bufferwidth, run) %>%
  summarise_at(vars(all.but.cub.density), funs(mean, sd, min, max))

buffer.years18.27$max.d <- buffer.years18.27$max

buffer.years18.27.max <- buffer.years18.27 %>% group_by(bufferwidth) %>% 
  summarise_at(vars(max.d), funs(mean, sd, min, max))

# add data for '0 buffer'
buffer.none <- density.years18.27.max[2,2:6]
buffer.none$bufferwidth <- 0

buffer.years18.27.max <- rbind(buffer.none, buffer.years18.27.max)

# perc diff to current baiting scenario
buffer.years18.27.max$diff <- (years18.27.max$mean[1] - buffer.years18.27.max$mean) / years18.27.max$mean[1]
buffer.years18.27.max$diff2 <- buffer.years18.27.max$mean / years18.27.max$mean[1]


plot.baitbuffer <- ggplot(buffer.years18.27.max, aes(x = bufferwidth / 1000, y = mean)) +
  geom_hline(yintercept = years18.27.max$mean[1], col = "darkgrey") +
  geom_hline(yintercept = years18.27.max$min[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$max[1], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$mean[2], col = "darkgrey", linetype = "dashed") +
  geom_hline(yintercept = years18.27.max$min[2], col = "darkgrey", linetype = "dotted") +
  geom_hline(yintercept = years18.27.max$max[2], col = "darkgrey", linetype = "dotted") +
  geom_point(size = 2) + 
  geom_errorbar(aes(ymin=min, ymax=max), width=.1) +
  labs(title="d)", y=expression("Max fox density (individuals km "^-{2}* ")"), x="Width of baited buffer (km)") +   
  theme_classic() +
  scale_y_continuous(limits = c(0,3.1), expand = c(0, 0), breaks=seq(0, 3, 0.5)) +
  scale_x_continuous(limits = c(-0.2,10.5), expand = c(0, 0), breaks=seq(0, 10, 2))


# COMPILE PLOT
library(gridExtra)

tiff(paste0("figures/Fig5_MtClay_baiting.tiff"),
     width=15, height=15, units = 'cm', res = 300)

grid.arrange(plot.MtClay.baseline, plot.baitfreq, plot.baitdensity, plot.baitbuffer,
             ncol=2, nrow=2)


dev.off()
