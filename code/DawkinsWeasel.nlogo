globals
[
  uppercase
  lowercase
  parent-string
  generation
  all-done
]

to setup
  clear-all
  set uppercase "ABCDEFGHIJKLMNOPQRSTUVWXYZ "
  set lowercase "abcdefghijklmnopqrstuvwxyz"
  setup-intial-string
  initialize-string
  set generation 0
  set all-done false
  reset-ticks
end

to go

  if all-done [ stop ] ; this line prevents the simulation from continuing to print out the following at every timestep after completion:

  if (with-selection and go-with-selection = 0 ) or (not with-selection and go-without-selection = 0) [ ; simulation found an exact matching phrase
    set all-done true
    print word "It took " word generation word " generations of " word number-of-offspring " offspring to evolve to the target phrase."
    stop ]

  tick
end

to output-generation
  output-print (word generation "   " parent-string)
end

to-report go-with-selection ; go function used when WITH-SELECTION is TRUE

  let offspring-string parent-string
  let top-offspring-string parent-string
  let top-offspring-score get-score parent-string
  let uppercase-length length uppercase
  let string-length length parent-string

  set generation generation + 1

  let i 0

  ; EACH OFFSPRING LOOP
  while [i < number-of-offspring]
  [
    set offspring-string parent-string;
    let j 0

    ; EACH CHARACTER LOOP
    while [j < string-length]
    [
      let mutation-probability random-float 1.0
      if mutation-probability < mutation-rate [
        let random-letter item (random uppercase-length) uppercase
        set offspring-string replace-item j offspring-string random-letter
      ]
      set j j + 1
    ]

    ; compares current offspring with top offspring
    let current-offspring-score get-score offspring-string
    if current-offspring-score < top-offspring-score [
      set top-offspring-string offspring-string
      set top-offspring-score current-offspring-score
    ]

    set i i + 1
  ]
  set parent-string top-offspring-string
  output-generation
  report top-offspring-score
end

to-report go-without-selection ; go function used when WITH-SELECTION is FALSE
  let uppercase-length length uppercase
  set generation generation + 1

  let i 0
  while [i < length parent-string]
    [
      let mutation-probability random-float 1.0
      if mutation-probability < mutation-rate [
        let random-letter item (random uppercase-length) uppercase
        set parent-string replace-item i parent-string random-letter
      ]
      set i i + 1
    ]
  output-generation
  report get-score parent-string
end

to setup-intial-string
  let string-length length target-phrase
  if string-length < 1 [ set target-phrase "SORRY DAVE I CANNOT ALLOW THAT" ]
  let i 0
  while [i < string-length] ; replace lowercase with uppercase:
  [
    if (not member? item i target-phrase uppercase) [
      ifelse (member? item i target-phrase lowercase)
      [ set target-phrase replace-item i target-phrase item (position (item i target-phrase) lowercase) uppercase ]
      [ set target-phrase replace-item i target-phrase " " ]
    ]
    set i i + 1
  ]
end

to initialize-string
  let initial-string target-phrase
  let string-length length initial-string
  let uppercase-length length uppercase
  let index 0
  while [index < string-length]
  [
    let random-letter item (random uppercase-length) uppercase
    set initial-string replace-item index initial-string random-letter
    set index index + 1
  ]
  set parent-string initial-string;
  set parent-string initial-string
  output-generation
end

to-report get-score [input-string] ; score used to determine how well the INPUT-STRING matches the TARGET-PHRASE

  let string-length length input-string
  let score string-length
  let index 0
  while [index < string-length]
  [
    let goal-letter item index target-phrase
    let input-letter item index input-string
    if goal-letter = input-letter [set score score - 1]
    set index index + 1
  ]

  report score
end
@#$#@#$#@
GRAPHICS-WINDOW
84
184
257
358
-1
-1
165.0
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
0
0
0
1
1
1
ticks
10.0

BUTTON
570
14
637
47
go
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
470
14
561
47
go once
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
388
14
460
47
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

OUTPUT
20
133
638
480
12

INPUTBOX
145
59
638
119
target-phrase
METHINKS IT IS LIKE A WEASEL
1
0
String

INPUTBOX
20
59
138
119
number-of-offspring
10.0
1
0
Number

SLIDER
20
14
195
47
mutation-rate
mutation-rate
0
1.0
0.05
.05
1
NIL
HORIZONTAL

SWITCH
204
14
379
47
with-selection
with-selection
0
1
-1000

@#$#@#$#@
# Dawkins Weasel 1.0.3

Compatible with 6.1.1

## WHAT IS IT?

Dawkins Weasel is a NetLogo model that illustrates the principle of evolution by natural selection. It is inspired by a thought experiment presented by Richard Dawkins in his book The Blind Watchmaker (1986). He presents the idea as follows:

#### "I don't know who it was who first pointed out that, given enough time, a monkey bashing away at random on a typewriter could produce all the works of Shakespeare. The operative phrase is, of course, given enough time. Let us limit the task facing our monkey somewhat. Suppose that he has to produce, not the complete works of Shakespeare but just the short sentence 'METHINKS IT IS LIKE A WEASEL', and we shall make it relatively easy by giving him a typewriter with a restricted keyboard, one with just the 26 (capital) letters, and a space bar. How long will he take to write this one little sentence?"

He goes on to point out that - by random mechanisms alone - a monkey is unlikely to produce the phrase in any reasonable amount of time:

#### "To put it mildly, the phrase we seek would be a long time coming, to say nothing of the complete works of Shakespeare."

However, Dawkins points out, with selection the problem becomes quite manageable:

#### "What about cumulative selection; how much more effective should this be? Very very much more effective, perhaps more so than we at first realize, although it is almost obvious when we reflect further. We again use our computer monkey, but with a crucial difference in its program. It again begins by choosing a random sequence of 28 letters, just as before: 'WDLMNLT DTJBKWIRZREZLMQCO P'. It now 'breeds from' this random phrase. It duplicates it repeatedly, but with a certain chance of random error - 'mutation' - in the copying. The computer examines the mutant nonsense phrases, the 'progeny' of the original phrase, and chooses the one which, however slightly, most resembles the target phrase, 'METHINKS IT IS LIKE A WEASEL'."

Dawkins Weasel is a model of this thought experiment, demonstrating the effectiveness of selection for rapidely producing a given target phrase.

## HOW TO USE IT

### Settings

Write in the TARGET-PHRASE input box to determine the target phrase for your simulation.

Use the MUTATION-RATE slider to determine the rate at which each character in a string mutates. The higher the mutation rate, the more likely that each character present in the parent string will produce an error - mutation - in its offspring.

Write in the NUMBER-OF-OFFSPRING input box to determine how many offspring each parent string will produce for every generation.

Use the WITH-SELECTION switch to decide whether your simulation will include selection or not. Without selection, you are simulating a monkey typing on a keyboard, causing random changes to the string. With selection, you are simulating cumulative selection, as described by Dawkins above.

### Buttons

Press SETUP after all of the settings have been chosen. This will initialize the program to create a random string to serve as the initial ancestral state.

Press GO-ONCE to produce the parent string for the next generation, which is selected because it is the closest match to the TARGET PHRASE.

Press GO to make the simulation run continuously. This will create new generations of strings indefinitely or until it matches the TARGET PHRASE. To stop the simulation, press the GO button again.

### Output

While it is running, the simulation will print out the results from each generation, which provides the current generation number and the closest matching string of that generation. For example:

#### 20   ZETHINKS IT AS LIKW A WEABEL

If/When the simulation produces a string that completely matches the TARGET-PHRASE, the simulation will stop and print out the results of this simulation in the COMMAND-CENTER box.

## THINGS TO NOTICE

The purpose of this model is to demonstrate that natural selection is different than accumulated changes occuring by pure chance. Pay attention to how the settings affect the rate at which the simulation produces the TARGET PHRASE:

1. What MUTATION RATE(s) produce the most or least rapid effects?
2. How does the NUMBER OF OFFSPRING affect this rate?
3. Does it matter how long the TARGET PHRASE is?
4. Which is more effective: with selection or without selection?

## REFERENCES

Dawkins, R. 1996. The Blind Watchmaker. New York, NY, W. W. Norton & Co.

## HOW TO CITE

Crouse, Kristin (2019). “Dawkins Weasel” (Version 1.0.3). CoMSES Computational Model Library. Retrieved from: https://www.comses.net/codebases/6042/releases/1.0.3/

## COPYRIGHT AND LICENSE

© 2019 K N Crouse

This model was created at the University of Minnesota as part of a series of models to illustrate principles in biological evolution.

The model may be freely used, modified and redistributed provided this copyright is included and the resulting models are not used for profit.

Contact K N Crouse at crou0048@umn.edu if you have questions about its use.
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

ring
true
0
Circle -7500403 false true -1 -1 301

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
