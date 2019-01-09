library(snowfall)

# SPECIFY NUMBER OF ITERATIONS OF EACH MODEL AND NUMBER OF CORES
number.iterations <- 30
number.cores <- 2

modelrun <-function(corename)
  
{

  # LOAD THE RELEVANT PACKAGES
  #require(rJava)
  # .jinit(options(java.parameters=c("-server","-Xmx3000m")), force.init	= TRUE) #this may be required for some computers
  require(RNetLogo)
   
  # SPECIFY PATHS FOR NETLOGO SOFTWARE AND FOXNET FOLDER
  computersetup <- "laptop" #"laptop" #loads appropriate file paths depending on computer
  
  if (computersetup == "laptop") {
        netlogo.path <- "C:/Program Files/NetLogo 6.0.2/app"
        foxnet.path <- "C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet"
        }
  
  if (computersetup == "boab")  {
        netlogo.path <- "/home/bhradsky/NetLogo_6.0.2/app"
        foxnet.path <- "/home/bhradsky/foxnet"
        }
  
  # FOR A WITHIN-LOOP TEST ITERATION
  # corename <- "headless1"
  
  # LOAD NETLOGO (make sure version number is correct)
  NLStart(netlogo.path, gui = FALSE,  nl.jarname = "netlogo-6.0.2.jar",
          nl.obj = corename)
  # ignore the Warning about error code 5 and "Unable to locate empty model: /system/empty.nlogo"
  # it only occurs when gui (the visual interface) = TRUE and doesn't affect anything

  # LOAD FOXNET MODELLING PLATFORM  
  NLLoadModel(paste0(foxnet.path, "/foxnet_model/foxnet.nlogo"),  nl.obj = corename)
 
  # SPECIFY MODEL PARAMETERS
  NLCommand(
    # WORLD CONFIGURATION
    "set working-directory", paste0("\"", "\""),
    "set weeks-per-timestep 4",
    "set cell-dimension 100", 
    "set landscape-source \"generate\"", 
    "set landscape-size 1600",   
    "set region-size 200",
    "set landscape-raster \"\"",
    "set uninhabitable-raster-value 0",
    "set second-habitat-raster-value 0",
    "set hab2:hab1 1",
    "set region-shp \"\"",
    "set region2-shp \"\"",
    "set survey-transect-shp \"\"",
    "set survey-transect2-shp \"\"", 
    
    # FOX PARAMETERS
    "set initial-fox-density 1",
    
    # ranging behaviour
    "set range-calculation \"1 kernel, 1 mean\"",
    "set home-range-area \"[5]\"",
    "set kernel-percent \"[95]\"",
    
    # survival
    "set fox-mortality true",
    "set less1y-survival 0.39",
    "set from1yto2y-survival 0.65",
    "set from2yto3y-survival 0.92",
    "set more3y-survival 0.18",
    
    # reproduction
    "set cub-birth-season 33",
    "set number-of-cubs 3.2",
    "set propn-cubs-female 0.5",
    "set age-at-independence 12",
    
    # dispersal
    "set dispersal-season-begins 9",
    "set dispersal-season-ends 21",
    "set female-dispersers 0.999",
    "set male-dispersers 0.999",

    # BAITING PARAMETERS
    "set bait-layout \"none\"",
    "set bait-density 0", 
    "set bait-layout-shp \"\"",
    "set bait-frequency \"custom*\"",
    "set custom-bait-weeks \"[]\"",
    "set Pr-die-if-exposed-100ha 0",
    "set commence-baiting-year 0",
    "set commence-baiting-week 0",

    "set price-per-bait 0", 
    "set person-days-per-baiting-round 0",
    "set cost-per-person-day 0",
    "set km-per-baiting-round 0",
    "set cost-per-km-travel 0",

    # MONITORING
    "set plot? false",
    "set age-structure true",
    "set bait-consumption false", 
    "set count-neighbours false", 
    "set density false",
    "set dispersal-distances false",
    "set family-density false",
    "set foxes-on-transect false",
    "set popn-structure false",
    "set range-size false", # this won't work from R as it requires calling R

    nl.obj = corename)
  
  # SETUP MODEL  
  NLCommand("setup", nl.obj = corename)   

  # RUN MODEL
  timesteps <- 208 # number of ticks
  output.parameters <- c("year",
                         "week-of-year",
                         "no-foxes",
                         "foxes.less1",
                         "foxes.1.2",
                         "foxes.2.3",
                         "foxes.3.4",
                         "foxes.4.5",
                         "foxes.5.6",
                         "foxes.6.7",
                         "foxes.more7")
  
  output <- NLDoReport(timesteps, "go", output.parameters,
                       as.data.frame = TRUE,
                       df.col.names=output.parameters,
                       nl.obj = corename)
  
  write.csv(output, paste0(foxnet.path, "/outputs/carnarvon_age/Carnarvon_agestructure_HR5_", corename, ".csv"))

  NLQuit(nl.obj = corename)
}

  
cpunames <- paste0("headless", 1:number.iterations) 
  
sfInit(cpus=number.cores, parallel=T) #number of CPUS
  
sfLapply(cpunames, modelrun)
  
sfStop()
  
  