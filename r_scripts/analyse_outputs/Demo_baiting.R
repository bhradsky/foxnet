library(reshape)
library(dplyr)
library(ggplot2)
setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs/demo")

# BAIT EFFICACY

bait.efficacy <- read.csv("bait_efficacy.csv")
bait.efficacy.melt <- melt(bait.efficacy[2:ncol(bait.efficacy)])

summary <- bait.efficacy.melt %>% group_by(variable) %>%
  summarise_at(vars(value), funs(mean, min, max))
summary$variable.x <- as.numeric(substr(summary$variable, 2, 5))

plot.base <- ggplot(summary)
plot.av <- geom_point(aes(x = variable.x, y = mean))
plot.errorbar <-  geom_errorbar(aes(x = variable.x, ymin=min, ymax=max), width=.03)

plot.efficacy <- plot.base + 
  plot.av +
  plot.errorbar +
  scale_y_continuous(limits = c(0,103), expand = c(0, 0), breaks=seq(0, 100, 20)) +
  scale_x_continuous(limits = c(0, 1.03), expand = c(0, 0), breaks=seq(0, 1, 0.2)) +
  labs(title="(a) Bait efficacy", y=expression("Fox died (%)"), x="Pr-die-exposed-100ha") +
  theme_classic() +
  theme(legend.position = "none")

#############################################

# BAIT DENSITY

bait<- read.csv("bait_density.csv")
bait.melt <- melt(bait[2:ncol(bait)])

summary <- bait.melt %>% group_by(variable) %>%
  summarise_at(vars(value), funs(mean, min, max))
summary$variable.x <- as.numeric(substr(summary$variable, 2, 5))

plot.base <- ggplot(summary)
plot.av <- geom_point(aes(x = variable.x, y = mean))
plot.errorbar <-  geom_errorbar(aes(x = variable.x, ymin=min, ymax=max), width=.3)

plot.density <- plot.base + 
  plot.av +
  plot.errorbar +
  scale_y_continuous(limits = c(0,103), expand = c(0, 0), breaks=seq(0, 100, 20)) +
  scale_x_continuous(limits = c(0, 17), expand = c(0, 0), breaks=seq(0, 16, 2)) +
  labs(title="(b) Bait density", y=expression("Fox died (%)"), x = expression("Bait density (baits km"^-{2}* ")")) +
  theme_classic() +
  theme(legend.position = "none")

#############################################

# HR AREA


bait<- read.csv("bait_hrarea.csv")
bait.melt <- melt(bait[2:ncol(bait)])

summary <- bait.melt %>% group_by(variable) %>%
  summarise_at(vars(value), funs(mean, min, max))
summary$variable.x <- as.numeric(substr(summary$variable, 2, 5))

plot.base <- ggplot(summary)
plot.av <- geom_point(aes(x = variable.x, y = mean))
plot.errorbar <-  geom_errorbar(aes(x = variable.x, ymin=min, ymax=max), width=.1)

plot.hr <- plot.base + 
  plot.av +
  plot.errorbar +
  scale_y_continuous(limits = c(0,103), expand = c(0, 0), breaks=seq(0, 100, 20)) +
  scale_x_continuous(limits = c(0, 9.5), expand = c(0, 0), breaks=seq(0, 9, 1)) +
  labs(title="(c) Home range size", y=expression("Fox died (%)"), x = expression("Home range area (km"^{2}* ")")) +
  theme_classic() +
  theme(legend.position = "none")



# family size

bait<- read.csv("bait_familysize.csv")
bait.melt <- melt(bait[2:ncol(bait)])

summary <- bait.melt %>% group_by(variable) %>%
  summarise_at(vars(value), funs(mean, min, max))
summary$variable.x <- as.numeric(substr(summary$variable, 2, 5))

bait2<- read.csv("bait_familysize_100efficacy.csv")
bait2.melt <- melt(bait2[2:ncol(bait2)])

summary2 <- bait2.melt %>% group_by(variable) %>%
  summarise_at(vars(value), funs(mean, min, max))
summary2$variable.x <- as.numeric(substr(summary2$variable, 2, 5))
summary2$variable.x  <- summary2$variable.x - 0.1

plot.base <- ggplot(summary)
plot.av <- geom_point(aes(x = variable.x, y = mean), col = "dimgrey")
plot.errorbar <-  geom_errorbar(aes(x = variable.x, ymin=min, ymax=max), width=.1, col = "dimgrey")

plot.av.100 <- geom_point(aes(x = variable.x, y = mean), data = summary2)
plot.errorbar.100 <- geom_errorbar(aes(x = variable.x, ymin=min, ymax=max), width=.1, data = summary2)

plot.familysize <- plot.base + 
  plot.av +
  plot.errorbar +
  plot.av.100 +
  plot.errorbar.100 +
  scale_y_continuous(limits = c(0,103), expand = c(0, 0), breaks=seq(0, 100, 20)) +
  scale_x_continuous(limits = c(0, 5.1), expand = c(0, 0), breaks=seq(0, 5, 1)) +
  labs(title="(d) Family size", y=expression("Fox died (%)"), x = expression("Number of foxes in fox-family")) +
  theme_classic() #+
  #theme(legend.position = "none")


# COMPILE PLOT
library(gridExtra)

png(paste0("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/user_guide/figures/demo/bait_demo.png"),
     width=15, height=15, units = 'cm', res = 300)

grid.arrange(plot.efficacy, plot.density, plot.hr, plot.familysize,
             ncol=2, nrow=2)


dev.off()
