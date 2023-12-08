##################################################
### EXAMPLE CODES FOR RUNNING FOXNET FROM NLRX ###
##################################################

# NOTE: for this code to run, you need to set your path to Java correctly.
# For a Windows machine, see: https://javatutorial.net/set-java-home-windows-10/ although I had to set them as user variables rather than system variables for it to work
# To check your Java path
# Sys.getenv("JAVA_HOME")


### "go if ticks = 647 [export-fox-density-map]", 

# OPEN PACKAGE

library(nlrx)

# DEFINE FILE PATHWAYS (adjust as needed)

netlogopath <- file.path("C:/Program Files/NetLogo 6.3.0")

workingdirectory <- "C:/Users/hradskyb/Dropbox/personal/bron/ibm/foxnet_github/"

modelpath <- file.path(paste0(workingdirectory, "foxnet_model/foxnet_nedscrn_custom.nlogo"))

outpath <- file.path(paste0(workingdirectory, "outputs/nedscrn")) # outputs will be written here


# LOAD NETLOGO

nl <- nl(nlversion = "6.3.0",
         nlpath = netlogopath,
         modelpath = modelpath,
         jvmmem = 1024)

#--------------------------------------------------------
# SET UP A SINGLE RUN (all inputs constant)

nl@experiment <- experiment(
  expname = "foxnet_neds_test", # name of output file
  outpath=outpath, # location where output will be saved
  repetition = 1, #30 #number of repeat model runs (each with a new random seed, set within FoxNet)
  tickmetrics = "true",
  idsetup = "setup",
  idgo = "go",
  runtime = 575, #22 years at fortnightly intervals # number of time-steps (ticks)
  evalticks = seq(1,575), #seq(1,26), #seq(1,702), # time-steps that outputs will be written
  
  # metrics you want to monitor
  metrics = c("my-seed",
              "year", 
              "week-of-year", 
              "total-fox-density",
              "all-fox-but-cub-density",
              "bait-take", 
              "bait-cost"),
  
  # inputs that you want to change as part of your experiment, in this case - none.
  variables = list(),
  
  # the inputs that you want to remain constant throughout the experiment
  constants = list(
  "working-directory" = paste0("\"", workingdirectory, "\""),
  "weeks-per-timestep" = 2,
  "cell-dimension" = 100, 
  "landscape-source" = "\"import raster\"", 
  "landscape-size" = 0,   
  "region-size" = 0,
  "landscape-raster" = "\"gis_layers/nedscrn/brp051.asc\"",
  "uninhabitable-raster-value" = 0,
  "second-habitat-raster-value" = 2,
  "hab2:hab1" = 1,
  "third-habitat-raster-value" = 100,
  "hab3:hab1" = 1,
  "survey-transect-shp" = "\"\"",
  "survey-transect2-shp" = "\"\"", 
  "region-shp" = "\"gis_layers/nedscrn/BRP051_RoI.shp\"",
  "region2-shp" = "\"\"",
  "region3-shp" = "\"\"",
  "region4-shp" = "\"\"",
  "region5-shp" = "\"\"",
  "region6-shp" = "\"\"",
  "barrier-shp" = "\"gis_layers/nedscrn/MurrayRiver.shp\"",
  "propn-permeable-barrier" = 0,
  "barrier-shp-2" = "\"\"",
  "propn-permeable-barrier-2" = 0,

  # FOX PARAMETERS
  "initial-fox-density" = 2.2,
  
  # ranging behaviour
  "range-calculation" = "\"1 kernel, 1 mean\"",
  "home-range-area" = "\"[2.14]\"",
  "kernel-percent" = "\"[95]\"",
  
  # survival
  "fox-mortality" = "true",
  "less1y-survival" = 0.39,
  "from1yto2y-survival" =  0.65,
  "from2yto3y-survival" =  0.92,
  "more3y-survival" =  0.18,
  
  # reproduction
  "cub-birth-season" = 37,
  "number-of-cubs" = 3.74,
  "propn-cubs-female" = 0.5,
  "age-at-independence" = 12,
  
  # dispersal
  "dispersal-season-begins" = 9,
  "dispersal-season-ends" = 21,
  "female-dispersers" = 0.7,
  "male-dispersers" = 0.999,
  
  # BAITING PARAMETERS
  "Pr-die-if-exposed-100ha" = 0.15, 
  "bait-layout" = "\"custom\"", 
  "bait-density" = 0, 
  "bait-layout-shp" = "\"gis_layers/nedscrn/FoxStations_Total_20Apr2022_GDA94.shp\"",
  "bait-frequency" = "\"custom*\"",
  "commence-baiting-year" = 10,
  "commence-baiting-week" = 1,
  "custom-bait-years" = "\"[]\"",
  "custom-bait-weeks" = "\"[]\"",

  "annual-baseline-cost" = 1000,
  "price-per-bait" = 2, 
  "person-days-per-baiting-round" = 1,
  "cost-per-person-day" = 250,
  "km-per-baiting-round" = 420,
  "cost-per-km-travel" = 0.67,
  
  # MONITORING
  "plot?" = "false",
  "age-structure" = "false",
  "bait-consumption" = "true", 
  "count-neighbours" = "false", 
  "density" = "true",
  "dispersal-distances" = "false",
  "family-density" = "false",
  "foxes-on-transect" = "false",
  "popn-structure" = "false",
  "range-size" = "false"))
nl@simdesign <- simdesign_simple(nl = nl, nseeds = 15) # a new random seed is set each model setup run from within FoxNet, so you don't need to set here

# run model with progress monitoring - only useful if nseeds > 1 or input variations
#progressr::handlers("progress")
#results <- progressr::with_progress(run_nl_all(nl))

library(future)
plan(multisession)
results <- run_nl_all(nl = nl)


# OR run model without progress monitoring
results <- run_nl_all(nl = nl)

# Attach results to nl object:
setsim(nl, "simoutput") <- results

# Write output to outpath of experiment within nl
write_simoutput(nl)

#------------------------------------------------------

# COMPARE BAITED TO UNBAITED SCENARIO (categorical input variable)
# using 'distinct parameter combinations' approach in nlrx

nl@experiment <- experiment(
  expname = "foxnet_baitedvunbaited", # name of output file
  outpath=outpath, #location where output will be saved
  repetition = 30, #number of repeat model runs (each with a new random seed, set within FoxNet)
  tickmetrics = "true",
  idsetup = "setup",
  idgo = "go",
  runtime = 702, # the number of time-steps (ticks)
  evalticks = seq(1,702), # time-steps that outputs will be written
  
  # metrics you want to monitor
  metrics = c("my-seed",
              "year", 
              "week-of-year", 
              "total-fox-density",
              "all-fox-but-cub-density",
              "bait-take", 
              "bait-cost"),
  
  # inputs that you want to change as part of your experiment
  variables = list('bait-layout' = list(values = c("\"none\"", "\"custom\""))),
                   
  # the inputs that you want to remain constant throughout the experiment
  constants = list(
    "working-directory" = paste0("\"", workingdirectory, "\""),
    "weeks-per-timestep" = 2,
    "cell-dimension" = 100, 
    "landscape-source" = "\"import raster\"", 
    "landscape-size" = 0,   
    "region-size" = 0,
    "landscape-raster" = "\"gis_layers/glenelg/mtclay_landscape.asc\"",
    "uninhabitable-raster-value" = 2,
    "second-habitat-raster-value" = 0,
    "hab2:hab1" = 1,
    "third-habitat-raster-value" = 100,
    "hab3:hab1" = 1,
    "survey-transect-shp" = "\"gis_layers/glenelg/mtclay_region.shp\"",
    "survey-transect2-shp" = "\"\"", 
    "region-shp" = "\"gis_layers/glenelg/mtclay_region.shp\"",
    "region2-shp" = "\"gis_layers/glenelg/annya_region.shp\"",
    "region3-shp" = "\"\"",
    "region4-shp" = "\"\"",
    "region5-shp" = "\"\"",
    "region6-shp" = "\"\"",
    "barrier-shp" = "\"gis_layers/glenelg/fence.shp\"",
    "propn-permeable-barrier" = 0,
    "barrier-shp-2" = "\"gis_layers/glenelg/fence.shp\"",
    "propn-permeable-barrier-2" = 0,
    
    # FOX PARAMETERS
    "initial-fox-density" = 2,
    
    # ranging behaviour
    "range-calculation" = "\"1 kernel, 1 mean\"",
    "home-range-area" = "\"[2.14]\"",
    "kernel-percent" = "\"[95]\"",
    
    # survival
    "fox-mortality" = "true",
    "less1y-survival" = 0.39,
    "from1yto2y-survival" =  0.65,
    "from2yto3y-survival" =  0.92,
    "more3y-survival" =  0.18,
    
    # reproduction
    "cub-birth-season" = 37,
    "number-of-cubs" = 3.74,
    "propn-cubs-female" = 0.5,
    "age-at-independence" = 12,
    
    # dispersal
    "dispersal-season-begins" = 9,
    "dispersal-season-ends" = 21,
    "female-dispersers" = 0.7,
    "male-dispersers" = 0.999,
    
    # BAITING PARAMETERS
    "Pr-die-if-exposed-100ha" = 0.3,
    "bait-density" = 0, 
    "bait-layout-shp" = "\"gis_layers/glenelg/mtclay_baits.shp\"",
    "bait-frequency" = "\"fortnightly*\"",
    "commence-baiting-year" = 16,
    "commence-baiting-week" = 1,
    "custom-bait-years" = "\"[]\"",
    "custom-bait-weeks" = "\"[]\"",
    
    "annual-baseline-cost" = 1000,
    "price-per-bait" = 2, 
    "person-days-per-baiting-round" = 1,
    "cost-per-person-day" = 250,
    "km-per-baiting-round" = 420,
    "cost-per-km-travel" = 0.67,
    
    # MONITORING
    "plot?" = "false",
    "age-structure" = "false",
    "bait-consumption" = "true", 
    "count-neighbours" = "false", 
    "density" = "true",
    "dispersal-distances" = "false",
    "family-density" = "false",
    "foxes-on-transect" = "false",
    "popn-structure" = "false",
    "range-size" = "false")) 

nl@simdesign <- simdesign_distinct(nl = nl, nseeds = 1)

# run model with progress monitoring - only useful if you've got more than one run
progressr::handlers("progress")
results <- progressr::with_progress(run_nl_all(nl))

# OR run without progress monitoring
# results <- run_nl_all(nl = nl)

# Attach results to nl object
setsim(nl, "simoutput") <- results

# Write output csv to outpath of experiment within nl
write_simoutput(nl)

# Do further analysis
analyze_nl(nl)
#--------------------------------------------

