
library(snowfall)

# SPECIFY NUMBER OF ITERATIONS OF EACH MODEL AND NUMBER OF CORES
number.iterations <- 30
number.cores <- 15
modelrun <-function(corename)
  
{
  # set values that you want to vary in experiment
  experiment.values <- c("custom", "none")
    
  for (i in experiment.values)
  
  {    
    # LOAD THE RELEVANT PACKAGES
    require(rJava)
    .jinit(options(java.parameters=c("-server","-Xmx6000m")), force.init	= TRUE) #this may be required for some computers
    require(RNetLogo)
    
    # SPECIFY PATHS FOR NETLOGO SOFTWARE AND FOXNET FOLDER
    computersetup <- "laptop" #"boab" #loads appropriate file paths depending on computer
    
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
    NLStart(netlogo.path, gui = FALSE, nl.jarname = "netlogo-6.0.2.jar", 
            nl.obj = corename)
    # ignore the Warning about error code 5 and "Unable to locate empty model: /system/empty.nlogo"
    # it only occurs when gui (the visual interface) = TRUE and doesn't affect anything
    
    # LOAD FOXNET MODELLING PLATFORM  
    NLLoadModel(paste0(foxnet.path, "/foxnet_model/foxnet.nlogo"),  
                nl.obj = corename)
    
    NLCommand(
      # WORLD CONFIGURATION
      "set working-directory", paste0("\"", foxnet.path, "\""),
      "set weeks-per-timestep 2",
      "set cell-dimension 100", 
      "set landscape-source \"import raster\"", 
      "set landscape-size 0",   
      "set region-size 0",
      "set landscape-raster \"gis_layers/glenelg/mtclay_landscape.asc\"",
      "set uninhabitable-raster-value 2",
      "set second-habitat-raster-value 0",
      "set hab2:hab1 1",
      "set region-shp \"gis_layers/glenelg/mtclay_region.shp\"",
      "set region2-shp \"\"",
      "set survey-transect-shp \"\"",
      "set survey-transect2-shp \"\"", 
      
      # FOX PARAMETERS
      "set initial-fox-density 2",
      
      # ranging behaviour
      "set range-calculation \"1 kernel, 1 mean\"",
      "set home-range-area \"[2.14]\"",
      "set kernel-percent \"[95]\"",
      
      # survival
      "set fox-mortality true",
      "set less1y-survival 0.39",
      "set from1yto2y-survival 0.65",
      "set from2yto3y-survival 0.92",
      "set more3y-survival 0.18",
      
      # reproduction
      "set cub-birth-season 37",
      "set number-of-cubs 3.74",
      "set propn-cubs-female 0.5",
      "set age-at-independence 12",
      
      # dispersal
      "set dispersal-season-begins 9",
      "set dispersal-season-ends 21",
      "set female-dispersers 0.7",
      "set male-dispersers 0.999",
     
      # BAITING PARAMETERS
      "set bait-layout", paste0("\"", i, "\""),
      "set bait-density 0", 
      "set bait-layout-shp \"gis_layers/glenelg/mtclay_baits.shp\"",
      "set bait-frequency \"fortnightly*\"",
      "set custom-bait-weeks \"[]\"",
      "set Pr-die-if-exposed-100ha 0.3", 
      "set commence-baiting-year 16",
      "set commence-baiting-week 1",
      
      "set price-per-bait 1", 
      "set person-days-per-baiting-round 0",
      "set cost-per-person-day 0",
      "set km-per-baiting-round 0",
      "set cost-per-km-travel 0",
      
      # MONITORING
      "set plot? false",
      "set age-structure false",
      "set bait-consumption true", 
      "set count-neighbours false", 
      "set density true",
      "set dispersal-distances false",
      "set family-density false",
      "set foxes-on-transect false",
      "set popn-structure false",
      "set range-size false", # this won't work from R as it requires calling R

    nl.obj = corename)
  
   NLCommand("setup", nl.obj = corename)   
    # NLCommand("go", nl.obj = corename)     
  

   # RUN MODEL
   timesteps <- 702 # number of ticks
   output.parameters <- c("year", 
                          "week-of-year", 
                          "total-fox-density",
                          "all-fox-but-cub-density",
                          "bait-take", 
                          "bait-cost"
   )
   
   output <- NLDoReport(timesteps, "go", output.parameters,
                        as.data.frame = TRUE,
                        df.col.names=output.parameters,
                        nl.obj = corename)
   
   output$baited <- i

   write.csv(output, paste0(foxnet.path, "/outputs/mtclay/mtclay_baseline_baited_", i, "_", corename,"_test.csv"))
   
   NLQuit(nl.obj = corename)
  }
}


cpunames <- paste0("headless", 1:number.iterations) 

sfInit(cpus=number.cores, parallel=T) #number of CPUS

sfLapply(cpunames, modelrun)

sfStop()


