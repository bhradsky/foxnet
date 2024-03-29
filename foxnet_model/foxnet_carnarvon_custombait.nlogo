; ## FOX NET MODEL
; ## BRONWYN HRADSKY
; ## UNIVERSITY OF MELBOURNE
; ## last updated 2018/06/28


;##################################################################
;################# MODEL COMPONENTS ###############################
;##################################################################

__includes["setup_routines.nls" "fox_birthdeath_routines.nls" "fox_territory_routines.nls" "monitoring_routines.nls" "bait_routines_carnarvon.nls" "demo_routines.nls"  ]  ; "bait_routines.nls"

extensions [profiler gis]

breed [foxes fox]
breed [fox-families fox-family]
breed [vacancies vacant ]

breed [bait-stations bait-station]

globals
[
; SCENARIO-RELATED PARAMETERS
  year
  week-of-year
  kms-to-cells
  km2-to-cells
  cells-to-km2
  available-landscape
  available-landscape-size
  landscape-data

  region-of-interest-data
  region-of-interest
  region-of-interest-size
  region-of-interest2-data
  region-of-interest2
  region-of-interest2-size

  baitsite-data
  baits-are-toxic

  survey-line
  my-survey-transect
  foxes-overlapping-transect

  survey-line2
  my-survey-transect2
  foxes-overlapping-transect2

; FOX-RELATED PARAMETERS
  real-fox-hr

  fox-hr-percentiles
  fox-hr-areas

  home-range-100perc

  adult-fox-metabolic-min-daily-food
  min-productivity-for-metabolic-rate; territory fails if it doesn't provide this food
  adult-fox-daily-food
  adult-fox-timestep-food; cells are added to a territory until it reaches this amount

  mean-productivity-intercept
  mean-productivity-decay

  territory-perception-radius
  dispersal-duration
  maximum-territory-update-area

; MONITORING GLOBALS
  my-seed
  number-of-neighbours; the number of neighbouring territories surround a fox territory
  territory-size; the number of cells in a fox's territory
  count-baits-laid
  bait-take
  bait-cost
  foxes-in-region-of-interest
  fox-family-density
  total-fox-density
  alpha-fox-density
  cub-fox-density
  subordinate-fox-density
  disperser-fox-density
  all-fox-but-cub-density
  fox-family-density2
  total-fox-density2
  alpha-fox-density2
  cub-fox-density2
  subordinate-fox-density2
  disperser-fox-density2
  all-fox-but-cub-density2

  home-range-sizes

  no-fox-families
  no-foxes
  no-cub-foxes
  no-breeding-females
  no-suboordinate-females
  no-disperser-females
  no-alpha-males
  no-suboordinate-males
  no-disperser-males

  max-all-female-dispersal-dist
  female-dispersal-dist
  mean-no-sub-female-dispersal-dist
  max-all-male-dispersal-dist
  male-dispersal-dist
  mean-no-sub-male-dispersal-dist

  foxes.less1
  foxes.1.2
  foxes.2.3
  foxes.3.4
  foxes.4.5
  foxes.5.6
  foxes.6.7
  foxes.more7

 ]

patches-own
[
  habitat-type
  available-to-foxes
  part-of-region-of-interest
  part-of-region-of-interest2

  true-productivity
  current-productivity
  true-color

  checked-already
  fox-family-owner
  cell-relative-productivity
  cell-relative-use
  cell-relative-use-foxes
  cell-relative-use-foxes2

 ]

foxes-own
[ age
  sex
  status
  natal-id
  natal-cell
  family-id
  my-dispersal-distance
  distance-from-natal
  my-dispersal-duration; number of time-steps it took the fox to find a new territory
  collared
  failed-territory-id
]

fox-families-own
[
  family-members
  my-territory
  territory-productivity
  vacancy-score
]

bait-stations-own
[
  bait-present
  Pr-death-bait-scaled

]

vacancies-own
[
  relative-productivity
]


;##################################################################
;################# THE MAIN ROUTINES ##############################
;##################################################################

to setup ; all these routines can be found in 'setup_routines.nls'

  clear-all

  set my-seed new-seed
  random-seed my-seed ; you can use this to control randomness -  the program always will do the same thing if you use the same seed value

  set-current-directory working-directory; specify the folder where FoxNet is stored

  check-for-errors; check that input parameters are logical

  calculate-conversion-factors; calculate factors for converting between kms and cell-units

  set-fox-parameters; set constant parameters relating to foxes and derive others

  create-world; create world of appropriate size

  identify-region-of-interest; identify part of world where you want to monitor fox and prey populations

  set-landscape-productivity ; calculate distribution of productivity values across landscape from average fox home range size

  if bait-layout != "none" [set-up-bait-stations]; set up sites for poison baiting (if applicable)

  set-up-survey-transect; set up linear survey transect (if applicable)

  ask patches [set pcolor true-color]; so that you can check landscape configuration is correct

  set-up-foxes; set up fox population

  update-monitors; update monitors for parameters of interest

  reset-ticks

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  set year floor (ticks * weeks-per-timestep / 52) + 1; Model commences in 'year 1'
  set week-of-year (ticks * weeks-per-timestep + 1) MOD 52; Model commences in 'week 1'
  if week-of-year = 0 [set week-of-year 52]; prevents model showing 'week 0' for last week of year, when 'weeks-per-timestep' is 1

 if initial-fox-density > 0

 [
   update-fox-age-and-status; see 'fox_birthdeath_routines.nls'. Foxes get older each tick. Cubs that have reached the 'age-of-independence' become subordinates. If it's dispersal season, a proportion of subordinate foxes become dispersers

   fox-natal-succession; see 'fox_birthdeath_routines.nls'. Foxes that are subordinates become alphas of the same family if the appropriate parent is missing

   fox-families-check-territories; see 'fox_territory_routines'. Fox-families check if there is any new/better territory they can acquire

   if bait-layout != "none" [bait-if-applicable] ; see 'bait_routines'. Baits are laid at bait-stations if it's the correct timestep

   foxes-disperse; see 'fox_territory_routines'. Dispersers try to join a family.  If not successful, they try to found an new territory

   if week-of-year = cub-birth-season
   [
     fox-families-breed; see 'fox_birthdeath_routines.nls'. Breeding happens annually
   ]

   foxes-die; see 'fox_birthdeath_routines.nls'.  This is the background rate, purely based on age.

   remove-defunct-fox-families; ; see 'fox_birthdeath_routines.nls'. fox families with no adult members are removed and cubs die

 ]


 update-monitors; see 'monitoring_routines'

 remove-all-baits ; see 'bait_routines'

 tick

; if initial-fox-density > 0 and count foxes = 0 [type "all foxes extinct at " type "year " type year type " week " print week-of-year stop] ; stop model if all foxes are dead

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; EXAMPLE  SCENARIOS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to territory-demo

  set weeks-per-timestep	4
  set cell-dimension		100
  set landscape-source		"generate"
  set landscape-size		10
  set region-size 		10
  set initial-fox-density 	0.00001
  set range-calculation		"1 kernel, 1 mean"
  set kernel-percent		"[100]"
  set home-range-area		"[2]"

  set fox-mortality	false
  set less1y-survival		0.48
  set from1yto2y-survival	0.54
  set from2yto3y-survival	0.53
  set more3y-survival		0.51

  set cub-birth-season		13
  set number-of-cubs		4.72
  set propn-cubs-female	0.5
  set age-at-independence	9
  set dispersal-season-begins 	37
  set dispersal-season-ends	9
  set female-dispersers		0.378
  set male-dispersers		0.758
  set bait-layout		"none"

  set landscape-raster ""
  set uninhabitable-raster-value 0
  set second-habitat-raster-value 0
  set hab2:hab1 1
  set region-shp ""
  set region2-shp ""
  set survey-transect-shp ""

  set bait-layout "none"

  set plot? true
  set age-structure false
  set count-neighbours false
  set density true
  set dispersal-distances false
  set family-density false
  set foxes-on-transect false
  set popn-structure false
  set range-size false

  setup

  set-patch-size 10


  print ""
  print "STARTING THE TERRITORY DEMO"

  wait 1

  create-foxes 1
    [
    set status "disperser"; 'disperser' refers to a fox that is not a cub and is looking for a territory
    set size 6
    set age (36 + random 130 ) ; initial foxes are given an age between 9 months and 3 years
    set sex "female" set color yellow + 4
    set family-id nobody
    set natal-id nobody
    set failed-territory-id [0]
    setxy 10 10
    set natal-cell patch-here
    set territory-perception-radius 0
    try-to-establish-new-territory
    ]

  print ""
  type "This is an alpha female fox with a " ask fox-families [type count my-territory * cells-to-km2] print " km2 territory in a homogeneous landscape."


  wait 3

  ask patches with [pxcor > 10]
  [
    set current-productivity current-productivity * 4
    set true-color true-color + 4
    if fox-family-owner = nobody [ set pcolor true-color]
  ]

  print ""
  print "The lighter-coloured cells have quadrupled in productivity..."

  wait 3

  fox-families-check-territories

  print ""
  type "...and the female moves to the more productive area. Her territory is now only " ask fox-families [type count my-territory * cells-to-km2] print " km2."


  wait 3

  ask n-of 200 patches with [pxcor > 10]
  [
    set current-productivity current-productivity * 1.5
    set true-color white
    if fox-family-owner = nobody [ set pcolor true-color]
  ]

  print ""
  print "The white cells have doubled in productivity again..."


  wait 3

  fox-families-check-territories

  print ""
  type "...and the female responds by selecting for the more productive cells, creating an asymmetric territory " ask fox-families [type precision (count my-territory * cells-to-km2) 2 ] print " km2 in size."


  wait 3

  ask patches
  [
    set current-productivity true-productivity * 2
    set true-color 7
    if fox-family-owner = nobody [ set pcolor true-color]
  ]

  print ""
  print "Now the landscape is homogeneous with twice its original productivity..."

  wait 3

  fox-families-check-territories

  print ""
  type "...causing the female to adjust her territory again.  It is now  " ask fox-families [type count my-territory * cells-to-km2] print " km2"


    wait 3

  print ""
  print "Let's introduce another female fox..."


  set territory-perception-radius (sqrt (home-range-100perc / pi )) * 3  ; (in km)

  create-foxes 1
    [
    set status "disperser"; 'disperser' refers to a fox that is not a cub and is looking for a territory
    set size 6
    set age (36 + random 130 ) ; initial foxes are given an age between 9 months and 3 years
    set sex "female" set color yellow + 4
    set family-id nobody
    set natal-id nobody
    set failed-territory-id [0]
    setxy 20 20
    set natal-cell patch-here
    ]

  wait 3

  foxes-disperse

  print ""
  print "...she also establishes a territory."


  wait 3

  print ""
  print "Three male foxes are added..."

    create-foxes 3
    [
    set status "disperser"; 'disperser' refers to a fox that is not a cub and is looking for a territory
    set size 6
    set age (36 + random 130 ) ; initial foxes are given an age between 9 months and 3 years
    set sex "male" set color yellow
    set family-id nobody
    set natal-id nobody
    set failed-territory-id [0]
    setxy random-xcor random-ycor
    set natal-cell patch-here

    ]

  wait 3

  foxes-disperse

  print " "
  print "...two join the existing females as their alpha male mates, one sets up a new territory on his own."


  wait 3

  set fox-mortality	true

  print " "
  print "Now the model runs as normal for 20 years, with foxes breeding, dispersing and dying.  The processes are stochastic, so if all the foxes die, try running the 'territory-demo' again."
  wait 3
  print "Alpha foxes are red (female) and blue (male).  Offspring, subordinate adults and dispersers are cream (female) and yellow (male)."


  repeat 248
  [
    ifelse count foxes > 0
    [go wait 0.1]
    [type "all foxes extinct at " type "year " type year type " week " print week-of-year stop]
  ]



end


to basic-model

  set-patch-size 2

  set weeks-per-timestep	1
  set cell-dimension		100
  set landscape-source		"generate"
  set landscape-size		400
  set region-size 		110
  set initial-fox-density 	0
  set range-calculation		"1 kernel, 1 mean"
  set kernel-percent		"[95]"
  set home-range-area		"[0.454]"

  set fox-mortality	true
  set less1y-survival		0.48
  set from1yto2y-survival	0.54
  set from2yto3y-survival	0.53
  set more3y-survival		0.51

  set cub-birth-season		13
  set number-of-cubs		4.72
  set propn-cubs-female	0.5
  set age-at-independence	9
  set dispersal-season-begins 	37
  set dispersal-season-ends	9
  set female-dispersers		0.378
  set male-dispersers		0.758
  set bait-layout		"none"

  set landscape-raster ""
  set uninhabitable-raster-value 0
  set second-habitat-raster-value 0
  set hab2:hab1 1
  set region-shp ""
  set region2-shp ""
  set survey-transect-shp ""

  set bait-layout "none"
  set bait-density 0
  set bait-frequency "4-weeks"
  set bait-layout-shp ""
  set custom-bait-weeks "[]"
  set Pr-die-if-exposed-100ha 0
  set commence-baiting-year 1
  set commence-baiting-week 1
  set price-per-bait 0
  set person-days-per-baiting-round 0
  set cost-per-person-day 0
  set km-per-baiting-round 0
  set cost-per-km-travel 0

  set plot? true
  set age-structure false
  set count-neighbours false
  set density true
  set dispersal-distances false
  set family-density false
  set foxes-on-transect false
  set popn-structure false
  set range-size false

  setup


end

to Glenelg-model
  set-patch-size 0.5
  set weeks-per-timestep	4
  set cell-dimension		100
  set landscape-source		"import raster"
  set landscape-size		400
  set region-size 		200
  set initial-fox-density 	0.5
  set range-calculation		"1 kernel, 1 mean"
  set kernel-percent		"[95]"
  set home-range-area		"[2.14]"

  set fox-mortality	true
  set less1y-survival		0.39
  set from1yto2y-survival	0.65
  set from2yto3y-survival	0.92
  set more3y-survival		0.18

  set cub-birth-season		33
  set number-of-cubs		3.2
  set propn-cubs-female	0.5
  set age-at-independence	9
  set dispersal-season-begins 	9
  set dispersal-season-ends	21
  set female-dispersers		0.700
  set male-dispersers		0.999
  set bait-layout		"none"

  set landscape-raster "gis_layers/glenelg/mtclay_landscape.asc"
  set uninhabitable-raster-value 2
  set second-habitat-raster-value 0
  set hab2:hab1 3
  set region-shp "gis_layers/glenelg/mtclay_region.shp"
  set region2-shp "gis_layers/glenelg/annya_region.shp"
  set survey-transect-shp "gis_layers/glenelg/mtclay_transect.shp"
  set survey-transect2-shp ""

  set bait-layout "custom"
  set bait-density 1
  set bait-frequency "4-weeks"
  set bait-layout-shp "gis_layers/glenelg/mtclay_baits.shp"
  set custom-bait-weeks "[]"
  set Pr-die-if-exposed-100ha 0.3
  set commence-baiting-year 3
  set commence-baiting-week 13
  set price-per-bait 2
  set person-days-per-baiting-round 3
  set cost-per-person-day 250
  set km-per-baiting-round 420
  set cost-per-km-travel 0.67

  set plot? true
  set age-structure false
  set count-neighbours false
  set density true
  set dispersal-distances false
  set family-density false
  set foxes-on-transect false
  set popn-structure false
  set range-size false

  setup

end
@#$#@#$#@
GRAPHICS-WINDOW
520
125
1583
1416
-1
-1
0.5
1
10
1
1
1
0
0
0
1
0
1062
0
1281
0
0
1
ticks
30.0

BUTTON
620
10
683
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
620
50
683
83
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
620
88
683
121
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
620
125
684
158
profiler
setup                  ;; set up the model\nprofiler:start         ;; start profiling\n;repeat 10 [setup]\nrepeat 26 [go]       ;; run something you want to measure\nprofiler:stop          ;; stop profiling\nprint profiler:report  ;; view the results\nprofiler:reset         ;; clear the data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1025
10
1135
63
landscape (km2)
available-landscape-size
2
1
13

MONITOR
810
10
910
63
random seed
my-seed
0
1
13

SWITCH
190
335
395
368
fox-mortality
fox-mortality
0
1
-1000

SLIDER
190
95
395
128
initial-fox-density
initial-fox-density
0
8
1.0
0.5
1
/km2
HORIZONTAL

SLIDER
405
145
610
178
bait-density
bait-density
0
5
0.0
0.5
1
/km2
HORIZONTAL

SLIDER
405
420
610
453
Pr-die-if-exposed-100ha
Pr-die-if-exposed-100ha
0
1
0.7
0.05
1
NIL
HORIZONTAL

CHOOSER
403
95
608
140
bait-layout
bait-layout
"none" "grid" "random-scatter" "custom"
1

TEXTBOX
405
185
634
219
bait-density only affects 'grid' and 'random-scatter' bait-layout options
13
0.0
1

TEXTBOX
405
75
616
93
BAITING PARAMETERS
13
0.0
1

TEXTBOX
195
75
345
93
FOX PARAMETERS
13
0.0
1

INPUTBOX
190
250
395
310
kernel-percent
[95]
1
0
String (reporter)

INPUTBOX
190
185
395
245
home-range-area
[5]
1
0
String (reporter)

CHOOSER
5
95
170
140
weeks-per-timestep
weeks-per-timestep
1 2 4
2

CHOOSER
405
305
610
350
bait-frequency
bait-frequency
"weekly*" "fortnightly*" "4-weeks" "custom*"
3

INPUTBOX
405
355
617
415
custom-bait-weeks
[]
1
0
String

MONITOR
915
10
965
63
NIL
year
1
1
13

CHOOSER
5
185
170
230
landscape-source
landscape-source
"generate" "import raster"
1

TEXTBOX
10
75
155
106
LANDSCAPE SETUP
13
0.0
1

SLIDER
5
145
170
178
cell-dimension
cell-dimension
20
100
100.0
10
1
m
HORIZONTAL

SLIDER
5
235
170
268
landscape-size
landscape-size
10
12000
0.0
5
1
km2
HORIZONTAL

INPUTBOX
5
335
170
410
landscape-raster
gis_layers/carnarvon/carn_landscape.asc
1
1
String

TEXTBOX
190
315
340
333
Survival
13
0.0
1

SLIDER
190
370
395
403
less1y-survival
less1y-survival
0
1
0.39
0.01
1
propn.
HORIZONTAL

SLIDER
190
405
395
438
from1yto2y-survival
from1yto2y-survival
0
1
0.65
0.01
1
propn.
HORIZONTAL

SLIDER
190
440
395
473
from2yto3y-survival
from2yto3y-survival
0
1
0.92
0.01
1
propn.
HORIZONTAL

SLIDER
190
475
395
508
more3y-survival
more3y-survival
0
1
0.18
0.01
1
propn.
HORIZONTAL

TEXTBOX
190
685
340
703
Dispersal\n
13
0.0
1

TEXTBOX
190
515
340
533
Reproduction
13
0.0
1

SLIDER
190
535
395
568
cub-birth-season
cub-birth-season
1
52
33.0
1
1
week
HORIZONTAL

SLIDER
190
605
395
638
propn-cubs-female
propn-cubs-female
0
1
0.5
0.01
1
propn.
HORIZONTAL

SLIDER
190
570
395
603
number-of-cubs
number-of-cubs
0
8
3.2
0.01
1
NIL
HORIZONTAL

SLIDER
190
640
395
673
age-at-independence
age-at-independence
0
52
12.0
1
1
weeks
HORIZONTAL

SLIDER
190
705
395
738
dispersal-season-begins
dispersal-season-begins
1
52
9.0
1
1
week
HORIZONTAL

SLIDER
190
740
395
773
dispersal-season-ends
dispersal-season-ends
1
52
21.0
1
1
week
HORIZONTAL

SLIDER
190
775
395
808
female-dispersers
female-dispersers
0
0.999
0.999
0.001
1
propn.
HORIZONTAL

SLIDER
190
810
395
843
male-dispersers
male-dispersers
0
0.999
0.999
0.001
1
propn.
HORIZONTAL

INPUTBOX
405
230
610
300
bait-layout-shp
NIL
1
1
String

MONITOR
970
10
1020
63
week
week-of-year
0
1
13

SLIDER
405
455
610
488
commence-baiting-year
commence-baiting-year
1
50
1.0
1
1
year
HORIZONTAL

SLIDER
405
490
610
523
commence-baiting-week
commence-baiting-week
1
52
1.0
1
1
week
HORIZONTAL

INPUTBOX
5
585
170
655
region-shp
gis_layers/carnarvon/baited_core.shp
1
1
String

PLOT
1450
10
2030
225
fox density
time step
number per km2
0.0
10.0
0.0
3.0
true
true
"" ""
PENS
"Fox density - region 1" 1.0 0 -5298144 true "" ""
"Fox density - region 2" 1.0 0 -955883 true "" ""
"Fox-family density" 1.0 0 -7500403 true "" ""

PLOT
1235
230
1680
416
bait take
time step
proportion of baits
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
1235
740
1515
895
fox home range area (95% MCP)
area (ha)
number
0.0
100.0
0.0
10.0
true
false
"set-plot-x-range 0 max fox-hr-areas * 3" ""
PENS
"default" 1.0 1 -16777216 true "" ""

SLIDER
5
275
170
308
region-size
region-size
10
6000
0.0
10
1
km2
HORIZONTAL

SLIDER
5
545
170
578
hab2:hab1
hab2:hab1
0
10
1.0
0.05
1
x
HORIZONTAL

MONITOR
1685
230
1815
283
annual cost to-date
bait-cost
0
1
13

INPUTBOX
5
415
170
475
uninhabitable-raster-value
0.0
1
0
Number

PLOT
1235
585
1515
735
fox dispersal
dispersal distance (km)
freq
0.0
80.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

INPUTBOX
5
735
170
805
survey-transect-shp
NIL
1
1
String

INPUTBOX
5
480
170
540
second-habitat-raster-value
0.0
1
0
Number

MONITOR
1140
10
1225
63
region (km2)
(count region-of-interest  * cell-dimension * cell-dimension) / 1000000
17
1
13

INPUTBOX
5
10
560
70
working-directory
C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet
1
0
String

INPUTBOX
405
525
610
585
price-per-bait
0.0
1
0
Number

TEXTBOX
620
285
770
303
MONITORING
13
0.0
1

INPUTBOX
405
590
610
650
person-days-per-baiting-round
0.0
1
0
Number

INPUTBOX
405
720
610
780
km-per-baiting-round
0.0
1
0
Number

INPUTBOX
405
785
610
845
cost-per-km-travel
0.0
1
0
Number

INPUTBOX
405
655
610
715
cost-per-person-day
0.0
1
0
Number

INPUTBOX
5
660
170
730
region2-shp
NIL
1
1
String

TEXTBOX
10
315
160
333
for GIS-customisation
13
0.0
1

BUTTON
690
50
805
83
NIL
basic-model
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
690
90
805
123
NIL
Glenelg-model
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
690
130
810
271
For the Glenelg-model to work, you must set your working- directory to the location of your FoxNet folder e.g C:/Users/hradskyb/ foxnet
13
15.0
1

PLOT
1520
585
1815
735
number of neighbouring territories
time step
number
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"min" 1.0 0 -7500403 true "" ""
"mean" 1.0 0 -2674135 true "" ""
"max" 1.0 0 -7500403 true "" ""

PLOT
1520
740
1815
895
foxes overlapping transect
time step
number
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"transect1" 1.0 0 -2674135 true "" ""
"transect2" 1.0 0 -11085214 true "" ""

SWITCH
620
305
723
338
plot?
plot?
0
1
-1000

PLOT
1235
420
1515
580
age structure
Fox age (years)
Propn. foxes
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
1520
420
1885
580
population structure
group
propn. foxes
0.0
7.0
0.0
1.0
true
true
"" ""
PENS
"cubs" 1.0 1 -16777216 true "" ""
"F breed" 1.0 2 -2674135 true "" ""
"F subord" 1.0 2 -955883 true "" ""
"F disperse" 1.0 2 -1184463 true "" ""
"M breed" 1.0 2 -13345367 true "" ""
"M subord" 1.0 2 -11221820 true "" ""
"M disperse" 1.0 2 -13840069 true "" ""

BUTTON
690
10
805
43
NIL
territory-demo
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
620
445
785
478
density
density
0
1
-1000

SWITCH
620
340
785
373
age-structure
age-structure
1
1
-1000

SWITCH
620
515
785
548
family-density
family-density
1
1
-1000

SWITCH
620
585
785
618
popn-structure
popn-structure
1
1
-1000

SWITCH
620
480
785
513
dispersal-distances
dispersal-distances
1
1
-1000

SWITCH
620
550
785
583
foxes-on-transect
foxes-on-transect
1
1
-1000

SWITCH
620
620
785
653
range-size
range-size
1
1
-1000

SWITCH
620
410
785
443
count-neighbours
count-neighbours
1
1
-1000

INPUTBOX
5
810
170
890
survey-transect2-shp
NIL
1
1
String

SWITCH
620
375
785
408
bait-consumption
bait-consumption
1
1
-1000

CHOOSER
190
135
392
180
range-calculation
range-calculation
"1 kernel, 1 mean" "1 kernel, min and max" "multiple kernels, means"
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Carnarvon_baiting" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="260"/>
    <metric>year</metric>
    <metric>week-of-year</metric>
    <metric>all-fox-but-cub-density</metric>
    <enumeratedValueSet variable="working-directory">
      <value value="&quot;C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Pr-die-if-exposed-100ha">
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="count-neighbours">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survey-transect2-shp">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bait-layout">
      <value value="&quot;grid&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="from1yto2y-survival">
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="landscape-size">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="range-calculation">
      <value value="&quot;1 kernel, 1 mean&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="male-dispersers">
      <value value="0.999"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="range-size">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal-season-ends">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fox-mortality">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-at-independence">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="region-shp">
      <value value="&quot;gis_layers/carnarvon/baited_core.shp&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-fox-density">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female-dispersers">
      <value value="0.999"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weeks-per-timestep">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="region-size">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cub-birth-season">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal-season-begins">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="commence-baiting-week">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="kernel-percent">
      <value value="&quot;[95]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-km-travel">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="age-structure">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cell-dimension">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-per-bait">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="less1y-survival">
      <value value="0.39"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="person-days-per-baiting-round">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cost-per-person-day">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-cubs">
      <value value="3.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bait-frequency">
      <value value="&quot;custom*&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uninhabitable-raster-value">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="km-per-baiting-round">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="plot?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bait-layout-shp">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="more3y-survival">
      <value value="0.18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="commence-baiting-year">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second-habitat-raster-value">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="landscape-source">
      <value value="&quot;import raster&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hab2:hab1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="from2yto3y-survival">
      <value value="0.92"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bait-density">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="landscape-raster">
      <value value="&quot;gis_layers/carnarvon/carn_landscape.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bait-consumption">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="popn-structure">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="region2-shp">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="survey-transect-shp">
      <value value="&quot;&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersal-distances">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="home-range-area">
      <value value="&quot;[5]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foxes-on-transect">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="family-density">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="custom-bait-weeks">
      <value value="&quot;[]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="propn-cubs-female">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
