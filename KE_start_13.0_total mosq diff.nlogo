globals
[hatch-tick
water-patches
  air-patches
  surface-patches
  adults
  larvae
  hatch-event
  rho
  no-energy-larva-death
  no-energy-adult-death
  old-larva-death
  external-death
  average-e
  premort
  postmort
]

patches-own [
  food                 ;; amount of food on this patch
 ; eggs
  water
  air
  surface
  food-recolonize
]
turtles-own [
  mass
  life-stage
  energy
  metabolism
  can-lay-eggs
  egg
  JM1
  JM2
  hatch-time
  age
  eggs-produced
  instar-age
  eclosion-age
  eclosion-time

]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  reset-ticks
  set hatch-tick ticks
  setup-env
  add-turtles
  set hatch-event 1


end




to setup-env
  ask patches [ifelse is-water?
    [set food 2 set water true set pcolor blue ]
    [set food 0 set water false  ]
  ]
  ask patches [if pycor > 0 [set pcolor 87]]
  set water-patches sort patches with [water = true]
  ask patches  [ifelse is-air?
    [set air true ]
      [set air false]
    ]
  set air-patches sort patches with [air = true]
  ask patches  [ifelse is-surface?
      [set surface true]
      [set surface false]
    ]
  set surface-patches sort patches with [surface = true]

end

to-report is-water?
  ifelse (pycor < 0) and (pxcor > -15) and (pxcor < 15) and (pycor > -15) [report true] [report false]
end

to-report is-air?
  ifelse (pycor > 0) and (pxcor > -15) and (pxcor < 15) and (pycor < 15) [report true] [report false]
end

to-report is-surface?
  ifelse (pycor = 0) and (pxcor > -15) and (pxcor < 15)[report true] [report false]
end



to add-turtles
  let i 0
  while [(i < number)] [
    ask one-of patches with [water = true ] [
        sprout 1 [
          set size 1         ;; easier to see
          set color brown
          set shape "caterpillar"
          set mass 1
          set life-stage 1
          set energy random 10
          set can-lay-eggs false
          let water-start ycor < 0
          set metabolism (metabolism-rate * mass)
          set i i + 1
          set JM1 random-float 100
          set JM2 random-float 100
        ]
    ]
  ]
end

to logistic-growth
  ;how to make food spread from patches that already have food? or give it a time delay before growth
  if food = 0 [set food-recolonize random-float 10 ]
  if food = 0 and food-recolonize < food-recolonize-chance [set food 1 ]
  ifelse food > 0
      [set food (food + food-r * (food-k - food))]
      [set food 0]
end

;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;
;;;;;;;;;;;;;;;;;;;;;

to go  ;; forever button
  tick
  ask turtles
  [live ]
  ask patches with  [water = true] [grow-food]
  if time-to-hatch? [set hatch-event hatch-event + 1 ]
  ;output-show mosquito-info

end

to live
  wiggle
  eat-or-not
  mature
  reproduce
  mortality
  hatch-eggs
  juvenile-death
  get-older

end



to eat-or-not  ;; turtle procedure
  ifelse  age < 20 [
  set metabolism (metabolism-rate * mass)
  let food-acquired (energy + (0.5 * food * (1 - mass-to-energy-ratio)) - metabolism ) ;early instars can only acquire half the food available in a patch; 40% of food goes to energy
  let food-not-acquired (energy - metabolism)
  ifelse food > 0
  [ set mass mass + (0.5 * mass-to-energy-ratio * food ) ; 0.5 b/c only half the food in a patch is acquired; 60% of food goes to mass
    set food food * 0.5        ;; and reduce the food source
    set energy food-acquired
    stop ]
  [ set energy food-not-acquired
  ]

  ]

  [
  set metabolism (metabolism-rate * mass)
  let food-acquired (energy + (food  * (1 - mass-to-energy-ratio)) - metabolism ) ;40% of food goes to energy
  let food-not-acquired (energy - metabolism)
  ifelse food > 0
  [ set mass mass + (mass-to-energy-ratio * food ) ; 0.6 is a conversion factor for food to mass b/c 60% of food goes to mass
    set food 0        ;; and reduce the food source
    set energy food-acquired
    stop ]
  [ set energy food-not-acquired
  ]
    ]
end

;to-report mosquito-info
 ; report [(list self ticks energy mass)] of turtles
;end




to reproduce
  let reproduction-cost (metabolism + reproduction-energy)
  if can-lay-eggs and (energy > reproduction-cost)
  [lay-eggs]

end

to get-older
  set age ticks - hatch-time
end


to lay-eggs

  set energy (energy - metabolism - reproduction-energy)
  set eggs-produced (eggs-produced + 1)
    ask one-of patches with [surface = true ] [
        sprout 1 [
          set size 1         ;; easier to see
          set color white
          set shape "dot"
          set mass 0
          set life-stage 0
          set energy 0
          set can-lay-eggs false
          set metabolism 0
          set egg true
  ]
  ]
end


to wiggle;
  if  egg = true [ fd 0 ]
  if life-stage = 1 [
    stay-in-water
    fd 1
    get-older]
  if life-stage = 2 [
     stay-in-water
    fd 1
    get-older
  ]

 if life-stage = 3 [
    stay-in-air
    fd 1
  ]



end

to stay-in-water
  let nearby-patches patches in-radius 3
  face one-of nearby-patches with [water = true]
end

to stay-in-air
  let nearby-patches patches in-radius 3
  ifelse air
  [face one-of nearby-patches with [air = true] ]
  [move-to one-of patches with [air = true] ]
end

to-report in-water
  let nearby-patches  patches in-radius-nowrap 2
  report nearby-patches with [water = true]
end

to-report in-air
  let nearby-patches  patches in-radius-nowrap 2
  report nearby-patches with [air = true]
end

to hatch-eggs
  if time-to-hatch? and life-stage = 0 [set egg false set life-stage 1 set size 1 set shape "caterpillar" move-to one-of water-patches set color brown set can-lay-eggs false
                                           set mass 1 set energy random 10 set metabolism (metabolism-rate * mass) set JM1 random 100 set JM2 random 100  set hatch-time ticks set age 0]
end

to-report premort-initial
  if ticks = 350 [set premort total-mosquito-number]
end

to-report postmort-initial
  if ticks = 630 [set postmort total-mosquito-number]
end

to mature
  if life-stage = 1 and (hatch-time > 350 and hatch-time < 490) [ set premort premort + 1 ]
  if life-stage = 1 and (hatch-time > 630 and hatch-time < 770) [ set postmort postmort + 1 ]
  if life-stage = 1 and age > 20 [set life-stage 2 set size 2 set instar-age age]
  if life-stage = 2 and mass >= eclosion-mass [set egg false set life-stage 3 set size 1 set shape "mosquito 2" move-to one-of air-patches set can-lay-eggs true set JM1 101 set JM2 101
                                               set eclosion-age age set eclosion-time ticks

  ]
end

to mortality
  if energy < 0 and life-stage < 3 [
    set no-energy-larva-death no-energy-larva-death + 1
    die
  ]
  if energy < 0 and life-stage = 3
  [ set no-energy-adult-death no-energy-adult-death + 1
    die
  ]
  if life-stage = 2 and age > 100 [
    set old-larva-death old-larva-death + 1
    die
  ]
end

to juvenile-death
  if ticks > time-to-mortality [
    if life-stage = 1 and JM1 < early-juvenile-mortality [
      set external-death external-death + 1
      die]
  if life-stage = 2 and mass > 25 and JM2 < late-juvenile-mortality [
      set external-death external-death + 1
      die]
  ]
end



to grow-food
 logistic-growth
end



;;;;;;;;;;;;;;;;;;;;;
;;;  Hatch        ;;;
;;;;;;;;;;;;;;;;;;;;;


to-report time-to-hatch?
  ifelse ticks = (hatch-interval * hatch-event) [report true] [report false]
end



;;;;;;;;;;;;;;;;;;;;;
;;;  Reports      ;;;
;;;;;;;;;;;;;;;;;;;;;


to-report adult-number
  let a []
  set a (count turtles with [life-stage = 3])
  report a

end

to-report larvae-number
  let l []
  set l (count turtles with [life-stage = 1 or life-stage = 2])
  report l

end

to-report egg-number
  let ovi []
  set ovi (count turtles with [life-stage = 0])
  report ovi

end

to-report total-mosquito-number
  let total []
  set total (count turtles )
  report total
end

to-report premort-total
  report premort
end

to-report postmort-total
  report postmort
end



to-report zero-energy-larva-death
  report no-energy-larva-death
end

to-report zero-energy-adult-death
  report no-energy-adult-death
end


to-report too-old-larva-death
  report old-larva-death
  end


to-report external-mort-death
  report external-death
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
40
38
104
71
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
98
203
131
Number
Number
0
300
100.0
1
1
mosquito larvae
HORIZONTAL

BUTTON
123
39
186
72
Go
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
17
236
189
269
food-k
food-k
0
10
7.0
0.5
1
NIL
HORIZONTAL

SLIDER
17
285
189
318
food-r
food-r
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
19
430
191
463
reproduction-energy
reproduction-energy
0
10
3.0
1
1
NIL
HORIZONTAL

PLOT
708
41
908
191
Larvae Number
Time
Number
0.0
3000.0
0.0
1000.0
true
false
"" ""
PENS
"Larvae" 1.0 0 -2674135 true "" "plot count turtles with [ life-stage = 1 ]"

SLIDER
340
461
512
494
Hatch-interval
Hatch-interval
0
100
70.0
1
1
NIL
HORIZONTAL

PLOT
925
43
1125
193
Total Mosquito Number
NIL
NIL
0.0
3000.0
0.0
1000.0
true
false
"" ""
PENS
"Total" 1.0 0 -16777216 true "" "plot count turtles"

SLIDER
19
381
191
414
eclosion-mass
eclosion-mass
0
50
31.0
1
1
NIL
HORIZONTAL

SLIDER
529
462
709
495
early-juvenile-mortality
early-juvenile-mortality
0
100
90.0
1
1
NIL
HORIZONTAL

SLIDER
18
333
197
366
food-recolonize-chance
food-recolonize-chance
0
10
2.0
1
1
NIL
HORIZONTAL

PLOT
709
229
909
379
Adult Number
Time
Number
0.0
3000.0
0.0
100.0
true
false
"" ""
PENS
"pen-8" 1.0 0 -11221820 true "" "plot count turtles with [ life-stage = 3 ]"

PLOT
926
229
1126
379
Patches with Food
NIL
NIL
0.0
3000.0
0.0
10.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -7500403 true "" "plot count patches with [food > 0]"

SLIDER
727
462
899
495
late-juvenile-mortality
late-juvenile-mortality
0
100
0.0
1
1
NIL
HORIZONTAL

INPUTBOX
962
438
1117
498
time-to-mortality
500.0
1
0
Number

SLIDER
18
478
190
511
mass-to-energy-ratio
mass-to-energy-ratio
0
1
0.5
.1
1
NIL
HORIZONTAL

SLIDER
37
180
209
213
metabolism-rate
metabolism-rate
0
1
0.05
0.01
1
NIL
HORIZONTAL

MONITOR
730
399
825
444
NIL
premort-total
0
1
11

MONITOR
854
398
959
443
NIL
postmort-total
0
1
11

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

caterpillar
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

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

mosquito
true
0
Polygon -7500403 true true 135 165 120 150 120 90 135 75 165 75 180 90 180 150 165 165
Circle -7500403 true true 124 26 52
Polygon -7500403 true true 165 105 165 120 180 135 225 225 255 240 270 240 270 180 240 135
Polygon -7500403 true true 135 105 60 135 30 180 30 240 45 240 75 225 120 135 135 120
Line -2674135 false 150 30 150 0
Polygon -7500403 true true 135 285 120 240 120 180 135 165 165 165 180 180 180 240 165 285
Rectangle -7500403 true true 144 -1 156 31

mosquito 2
true
0
Polygon -7500403 true true 143 81 113 104 112 182 128 196 128 253 126 262 127 272 130 280 136 285 148 286 158 281 159 269 161 262 161 248 159 193 174 182 174 104
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100
Circle -7500403 true true 109 24 61
Line -7500403 true 140 29 140 -9

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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="overcompensation_general_late" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-total</metric>
    <metric>postmort-total</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="s_em_10" repetitions="8" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>no-energy-larva-death</metric>
    <metric>no-energy-adult-death</metric>
    <metric>old-larva-death</metric>
    <metric>external-death</metric>
    <metric>avg-adult-energy</metric>
    <metric>avg-eggs-produced</metric>
    <metric>median-instar-age</metric>
    <metric>median-eclosion-age</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="test123" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-adults</metric>
    <metric>postmort-adults</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="overcompensation_general_early" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-total</metric>
    <metric>postmort-total</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="R-FOOD-late" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-adults</metric>
    <metric>postmort-adults</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <metric>food-r</metric>
    <metric>food-recolonize-chance</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
      <value value="10"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="R-FOOD-early" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-adults</metric>
    <metric>postmort-adults</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <metric>food-r</metric>
    <metric>food-recolonize-chance</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="10"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="R-FOOD-late-25" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-adults</metric>
    <metric>postmort-adults</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <metric>food-r</metric>
    <metric>food-recolonize-chance</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="FOOD_RECOLONIZE-late" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-adults</metric>
    <metric>postmort-adults</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <metric>food-r</metric>
    <metric>food-recolonize-chance</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
      <value value="10"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="FOOD_RECOLONIZE-early" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>total-mosquito-number = 0</exitCondition>
    <metric>total-mosquito-number</metric>
    <metric>adult-number</metric>
    <metric>larvae-number</metric>
    <metric>egg-number</metric>
    <metric>zero-energy-larva-death</metric>
    <metric>zero-energy-adult-death</metric>
    <metric>too-old-larva-death</metric>
    <metric>external-mort-death</metric>
    <metric>premort-adults</metric>
    <metric>postmort-adults</metric>
    <metric>hatch-interval</metric>
    <metric>early-juvenile-mortality</metric>
    <metric>late-juvenile-mortality</metric>
    <metric>food-r</metric>
    <metric>food-recolonize-chance</metric>
    <enumeratedValueSet variable="Hatch-interval">
      <value value="1"/>
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="metabolism-rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-k">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="late-juvenile-mortality">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-mortality">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-recolonize-chance">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eclosion-mass">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="early-juvenile-mortality">
      <value value="10"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mass-to-energy-ratio">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="food-r">
      <value value="1"/>
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
0
@#$#@#$#@
