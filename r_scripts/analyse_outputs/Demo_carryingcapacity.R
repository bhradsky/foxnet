library(reshape)
library(dplyr)
library(ggplot2)
setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs/demo")

k <- read.csv("carrying_capacity_45ha_1rep.csv", skip = 6)
k$year.scaled <- (k$X.step. - 1)/ 52 + 1
k$initial.fox.density <- as.factor(k$initial.fox.density)

plot.density <- ggplot(k) +
  geom_line(aes(x = year.scaled, y = total.fox.density, group = initial.fox.density, col = initial.fox.density)) +
  scale_y_continuous(limits = c(0,20), expand = c(0, 0), breaks=seq(0, 20, 2)) +
  scale_x_continuous(limits = c(0.97, 21), expand = c(0, 0), breaks=seq(0, 20, 5)) +
  labs(title="(a) high carrying capacity", y=expression("Fox density (individuals km"^-{2}* ")"), x="Year") +
  theme_classic() +
  theme(legend.position = "none") #c(0.8, 0.2)


k2 <- read.csv("carrying_capacity_214ha_1rep.csv", skip = 6)
k2$year.scaled <- (k2$X.step. - 1)/ 52 + 1
k2$initial.fox.density <- as.factor(k2$initial.fox.density)

plot.density2 <- ggplot(k2) +
  geom_line(aes(x = year.scaled, y = total.fox.density, group = initial.fox.density, col = initial.fox.density)) +
  scale_y_continuous(limits = c(0,20), expand = c(0, 0), breaks=seq(0, 20, 2)) +
  scale_x_continuous(limits = c(0.97, 21), expand = c(0, 0), breaks=seq(0, 20, 5)) +
  labs(title="(b) low carrying capacity", y=expression("Fox density (individuals km"^-{2}* ")"), x="Year") +
  theme_classic() +
  theme(legend.position = "none") #c(0.8, 0.2)


library(gridExtra)

png(paste0("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/user_guide/figures/demo/carryingcapacity_demo.png"),
     width=15, height=15, units = 'cm', res = 300)

grid.arrange(plot.density, plot.density2,
             ncol=1, nrow=2)


dev.off()
