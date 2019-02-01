library(reshape2, lib = "C:/Rlib")
library(ggplot2, lib = "C:/Rlib")
library(dplyr)

rm(list=ls())

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet/outputs")

#import model outputs
mydata <- data.frame()
experiment <- c(0.45, 0.7, 1, 2, 3, 6, 9.6 )
data.one <- for (n in experiment)
{
  for (i in 1:30) 
  {
    data.one <- read.csv(paste0("hr_density/HR_", n, "_headless", i, ".csv"))
    mydata <- rbind(mydata, data.one)
  }
}

#calculate average (min, max) density
density.final <- mydata[mydata$year == 5 & mydata$week.of.year == 49,]
data.mean <- aggregate(mydata$fox.family.density~mydata$HR, FUN=max)

data.mean <- density.final %>% group_by(HRsize) %>%
  summarise_at(vars(fox.family.density), funs(mean, min, max))

names(data.mean) <- c("HR", "family.density", "density.min", "density.max")
mine <- subset(data.mean, select =c("family.density", "HR", "density.min", "density.max") )
mine$source <- "model"

# fit curve and make predictions
model.curve <- lm(family.density ~ I(1/HR), data = data.mean)
newdat <- data.frame(HR = seq(0.45, 9.60, 0.05))
foxnet.prediction <- as.data.frame(predict.lm(model.curve, newdat, se.fit = TRUE))
foxnet.prediction$lcl <- foxnet.prediction$fit - 1.96 * foxnet.prediction$se.fit
foxnet.prediction$ucl <- foxnet.prediction$fit + 1.96 * foxnet.prediction$se.fit
foxnet.prediction <- cbind(newdat, foxnet.prediction)



#import Trewhella data
Trewhelladata <- read.csv("hr_density/TrewhellaData.csv")
Trewhelladata$HR <- Trewhelladata$Home.range.size
Trew.curve <- lm(family.density ~ I(1/HR), data=Trewhelladata)
Trew.prediction <- as.data.frame(predict.lm(Trew.curve, se.fit = TRUE, newdata = newdat))
Trew.prediction$T.lcl <- Trew.prediction$fit - 1.96 * Trew.prediction$se.fit
Trew.prediction$T.ucl <- Trew.prediction$fit + 1.96 * Trew.prediction$se.fit
Trew.prediction <- cbind(newdat, Trew.prediction)

Trew <- subset(Trewhelladata, select = c("family.density", "HR"))
Trew$source <- "Trewhella"
Trew$density.min <- -1
Trew$density.max <- -1

#join datasets
alldata <- rbind(Trew, mine)

#make equation functions
eqn.Trew.curve <- function(x){ Trew.curve$coefficients[1] +  Trew.curve$coefficients[2] *(1/x)}
eqn.model.curve <- function(x){ model.curve$coefficients[1] +  model.curve$coefficients[2] *(1/x)}

Fig3 <- ggplot() +
  geom_point(data = alldata, aes(y = family.density, x = HR, group = source, shape = source )) +
  geom_errorbar(data = alldata, aes(x = HR, ymin=density.min, ymax=density.max), width=.2) +
  scale_shape_manual(values=c(16, 2), labels = c("FoxNet", "field")) +
  geom_ribbon(data = Trew.prediction, aes(x = HR, ymin = T.lcl, ymax = T.ucl), alpha=0.3) + 
  geom_ribbon(data = foxnet.prediction, aes(x = HR, ymin = lcl, ymax = ucl), alpha=0.3) + 
  stat_function(data = alldata, fun = eqn.Trew.curve , linetype = "dotted") +
  stat_function(data = alldata, fun = eqn.model.curve , linetype = "dashed") +
  coord_cartesian(ylim = c(0, 2)) +
  coord_cartesian(xlim = c(0, 10)) +
  scale_y_continuous(limits = c(0,2), expand = c(0, 0), breaks=seq(0, 2, 0.5)) +
  scale_x_continuous(expand = c(0, 0), breaks=seq(0, 10, 2)) +
  theme_classic() +
  theme(legend.title=element_blank()) +
  theme(legend.position = c(0.85, 0.9)) +
  theme(legend.text = element_text(size = 8)) +
  labs(title="", y=expression("Fox density (families km"^-{2}* ")"), x=expression("Home range size (km"^{2}* ")")) 


tiff(paste0("figures/Fig3_hr_density.tiff"),
     width=7, height=7, units = 'cm', res = 300)

Fig3

dev.off()


#############################

#TEST WHETHER DATA SOURCE INFLUENCES COEFFICIENTS
test <- lm(family.density ~ source + source * I(1/HR), data=alldata)
summary(test)
