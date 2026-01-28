; -------------------------------------------------------------------------------------
; Dawkins Weasel model
; -------------------------------------------------------------------------------------
; Big idea (plain language):
;   This model “evolves” a random string of characters until it
;   exactly matches a chosen TARGET-PHRASE.
;
;   - Each generation creates new strings by copying the current string.
;   - Copying can include random mistakes (“mutations”) at each character.
;   - If WITH-SELECTION is ON, keep the best offspring (closest match).
;   - If WITH-SELECTION is OFF, just mutate the single string randomly.
;
; This is a teaching model. It demonstrates why cumulative selection
; (keeping improvements) is far more effective than pure random change.
; -------------------------------------------------------------------------------------


; -------------------------------------------------------------------------------------
; GLOBAL VARIABLES (shared across the whole model)
; -------------------------------------------------------------------------------------

globals
[
  allowed-chars     ; the “alphabet” the model is allowed to use (A–Z plus space)
  parent-string     ; the current best string (the “parent” for the next generation)
  generation        ; how many generations have passed so far
]


; -------------------------------------------------------------------------------------
; SETUP: the user presses SETUP to initialize everything
; -------------------------------------------------------------------------------------

to setup
  clear-all         ; wipe the world and reset all variables
  clear-output      ; wipe the Output Area so the run log starts fresh

  ; Restrict the keyboard to uppercase letters plus space, matching Dawkins’s setup.
  set allowed-chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ "

  ; Clean up whatever the user typed into target-phrase so it only contains
  ; valid characters (uppercase A–Z and spaces).
  normalize-target-phrase

  ; Create a random starting string with the same length as the target phrase.
  initialize-string

  ; Start counting generations from 0 (the random initial state is generation 0).
  set generation 0

  reset-ticks       ; reset NetLogo's tick counter
end


; -------------------------------------------------------------------------------------
; SETUP HELPERS
; -------------------------------------------------------------------------------------

to normalize-target-phrase
  ; Goal:
  ;   Ensure target-phrase uses only characters in allowed-chars (A–Z and space).
  ;   - Lowercase letters are converted to uppercase.
  ;   - Any other symbol (punctuation, numbers, etc.) becomes a space.
  ;
  ; Why do this?
  ;   Because our “typewriter” only has the characters in allowed-chars.

  let lowercase "abcdefghijklmnopqrstuvwxyz"
  let string-length length target-phrase

  ; If the user leaves target-phrase empty, substitute a default phrase.
  if string-length < 1
  [
    set target-phrase "SORRY DAVE I CANNOT ALLOW THAT"
    set string-length length target-phrase
  ]

  ; Walk through the target-phrase one character at a time.
  let i 0
  while [i < string-length]
  [
    let ch item i target-phrase

    ; If this character is already in allowed-chars (uppercase A–Z or space),
    ; leave it alone.
    ;
    ; Otherwise, try to convert it:
    ;   - If it is lowercase, replace it with the matching uppercase letter.
    ;   - If it is anything else, replace it with a space.
    if not member? ch allowed-chars
    [
      ifelse member? ch lowercase
      [
        ; Convert lowercase to uppercase by finding the lowercase letter’s position
        ; and taking the character at the same position in allowed-chars.
        ;
        ; Example: ch = "b" -> position in lowercase is 1 -> item 1 in allowed-chars is "B"
        set target-phrase replace-item i target-phrase item (position ch lowercase) allowed-chars
      ][
        ; Not an uppercase letter, not a lowercase letter -> treat as space
        set target-phrase replace-item i target-phrase " "
      ]
    ]

    set i i + 1
  ]
end

to initialize-string
  ; Goal:
  ;   Create a random starting string the same length as target-phrase.
  ;   This is the “ancestral” string that begins evolving.

  let initial-string target-phrase
  let string-length length initial-string
  let character-count length allowed-chars

  ; Replace each character with a random allowed character.
  let index 0
  while [index < string-length]
  [
    let random-letter item (random character-count) allowed-chars
    set initial-string replace-item index initial-string random-letter
    set index index + 1
  ]

  set parent-string initial-string

  ; Log generation 0 to the Output Area.
  output-generation
end


; -------------------------------------------------------------------------------------
; GO: the user presses GO-ONCE or GO to advance the model
; -------------------------------------------------------------------------------------

to go
  ; Each call to go advances the model by exactly ONE generation.
  ; Compute a “score” for the new parent-string:
  ;   score = number of characters that do NOT match the target-phrase
  ;   score = 0 means a perfect match.

  let score 0
  let selection-state ""

  ; Choose which stepping rule to use based on the WITH-SELECTION switch.
  ifelse with-selection
  [
    set selection-state "on"
    set score step-with-selection
  ][
    set selection-state "off"
    set score step-without-selection
  ]

  ; If score is 0, the target is reached, so stop and report.
  ifelse score = 0
  [
    print (word
      "It took " generation " generations to evolve to the target phrase ('"
      target-phrase
      "') using mutation-rate = " mutation-rate
      ", offspring-per-generation = " offspring-per-generation
      ", and selection " selection-state "."
    )
    stop
  ][
    ; Otherwise, the model continues.
    tick
  ]
end


; -------------------------------------------------------------------------------------
; EVOLUTION STEP WITH SELECTION
; -------------------------------------------------------------------------------------

to-report step-with-selection
  ; Plain language:
  ;   1) Make many offspring copies of the parent-string.
  ;   2) Randomly mutate characters in each offspring (based on mutation-rate).
  ;   3) Score each offspring by how close it is to target-phrase.
  ;   4) Keep the single best offspring as the new parent-string.

  let character-count length allowed-chars
  let string-length length parent-string

  ; Start by assuming the current parent is the best.
  let top-offspring-string parent-string
  let top-offspring-score get-score parent-string

  ; Moving forward one generation.
  set generation generation + 1

  ; Create offspring-per-generation offspring and keep the best.
  let i 0
  while [i < offspring-per-generation]
  [
    ; Begin with an exact copy of the parent.
    let offspring-string parent-string

    ; Walk through each character position and decide whether to mutate it.
    let j 0
    while [j < string-length]
    [
      ; With probability mutation-rate, replace this character with a random allowed character.
      if (random-float 1.0) < mutation-rate
      [
        let random-letter item (random character-count) allowed-chars
        set offspring-string replace-item j offspring-string random-letter
      ]
      set j j + 1
    ]

    ; Compute how many characters still differ from the target.
    let current-offspring-score get-score offspring-string

    ; Smaller score = closer match. If this offspring is better, keep it.
    if current-offspring-score < top-offspring-score
    [
      set top-offspring-string offspring-string
      set top-offspring-score current-offspring-score
    ]

    set i i + 1
  ]

  ; After evaluating all offspring, adopt the best one as the new parent.
  set parent-string top-offspring-string

  ; Log this generation and return the score.
  output-generation
  report top-offspring-score
end


; -------------------------------------------------------------------------------------
; EVOLUTION STEP WITHOUT SELECTION
; -------------------------------------------------------------------------------------

to-report step-without-selection
  ; Plain language:
  ;   This is “random typing.” There is no competition among offspring.
  ;   Take the current string and randomly mutate characters in-place.
  ;   Any “improvement” is accidental and not protected from being lost.

  let character-count length allowed-chars
  let string-length length parent-string

  set generation generation + 1

  ; Walk through each character position and mutate it with probability mutation-rate.
  let i 0
  while [i < string-length]
  [
    if (random-float 1.0) < mutation-rate
    [
      let random-letter item (random character-count) allowed-chars
      set parent-string replace-item i parent-string random-letter
    ]
    set i i + 1
  ]

  output-generation
  report get-score parent-string
end


; -------------------------------------------------------------------------------------
; SCORING: how close is a string to the target phrase?
; -------------------------------------------------------------------------------------

to-report get-score [input-string]
  ; Score definition:
  ;   score = number of character positions that do NOT match target-phrase.
  ;
  ; Example:
  ;   target:  ABCD
  ;   input:   ABXD
  ;   matches at positions 0,1,3 -> 3 matches -> 1 mismatch -> score = 1

  let string-length length input-string

  ; Start with the maximum possible mismatches (one per character),
  ; then subtract 1 for each correct matching position.
  let score string-length

  let index 0
  while [index < string-length]
  [
    if item index target-phrase = item index input-string
    [
      set score score - 1
    ]
    set index index + 1
  ]

  report score
end


; -------------------------------------------------------------------------------------
; OUTPUT: print the current generation and parent-string to the Output Area
; -------------------------------------------------------------------------------------

to output-generation
  ; Format: generation number, three spaces, current string
  output-print (word generation "   " parent-string)
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
638
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
201
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
193
119
offspring-per-generation
10.0
1
0
Number

SLIDER
20
14
169
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
176
14
379
47
with-selection
with-selection
0
1
-1000

@#$#@#$#@
# Dawkins Weasel 1.2.0

## WHAT IS IT?

Dawkins Weasel is a NetLogo model that illustrates the principle of **evolution by cumulative selection**. It is inspired by a thought experiment presented by Richard Dawkins in *The Blind Watchmaker* (1986), which contrasts evolution by natural selection with evolution by random chance alone.

Dawkins introduces the thought experiment as follows:

> *“I don't know who it was who first pointed out that, given enough time, a monkey bashing away at random on a typewriter could produce all the works of Shakespeare. The operative phrase is, of course, given enough time. Let us limit the task facing our monkey somewhat. Suppose that he has to produce, not the complete works of Shakespeare but just the short sentence ‘METHINKS IT IS LIKE A WEASEL’, and we shall make it relatively easy by giving him a typewriter with a restricted keyboard, one with just the 26 (capital) letters, and a space bar.”*

Dawkins points out that random typing alone is extraordinarily unlikely to produce the target phrase in any reasonable amount of time:

> *“To put it mildly, the phrase we seek would be a long time coming, to say nothing of the complete works of Shakespeare.”*

However, he then introduces cumulative selection:

> *“The computer examines the mutant nonsense phrases, the ‘progeny’ of the original phrase, and chooses the one which, however slightly, most resembles the target phrase.”*

This model implements that contrast directly. When selection is turned off, the phrase changes randomly over time. When selection is turned on, each generation produces multiple variants, and the variant that most closely matches the **target-phrase** becomes the parent for the next generation.

The purpose of the model is not to simulate real biological evolution in full detail, but to demonstrate why cumulative selection is fundamentally different from—and vastly more effective than—purely random change.

Developed using NetLogo 6.4.0 (expected to run on 6.x releases).


## HOW TO USE IT


#### Settings

**target-phrase**  
The phrase the model is trying to evolve toward. Only uppercase letters (A–Z) and spaces are allowed. Any other characters are converted to spaces during setup.

**mutation-rate**  
The probability that each individual character mutates when a new generation is created. Higher values introduce more random change; lower values preserve existing matches more strongly.

**offspring-per-generation**  
The number of offspring strings produced each generation when selection is on. Each offspring is a mutated copy of the current parent string. The best-matching offspring becomes the parent for the next generation.

**with-selection**  
Controls whether cumulative selection is applied.  
- **On:** Multiple offspring are generated and evaluated each generation; the best match is retained.  
- **Off:** The string mutates randomly over time with no selection.


#### Buttons

**setup**  
Initializes the model by creating a random starting string of the same length as the target-phrase.

**go**  
Runs the model continuously until the target-phrase is matched exactly. Press the button again to stop the run manually.

**go once**  
Advances the model by exactly one generation.


#### Output

The output window displays one line per generation, showing:  
- the generation number, and  
- the current best-matching string.

Example output: `20   ZETHINKS IT AS LIKW A WEABEL`

When the evolving string exactly matches the target-phrase, the model stops automatically and prints a summary message in the **Command Center** reporting how many generations were required.


## THINGS TO NOTICE

This model is designed to help distinguish cumulative selection from random change. As you experiment, consider the following:

1. How does the **mutation-rate** affect the speed of convergence?
2. How does increasing or decreasing **offspring-per-generation** change the outcome?
3. How does the length of the **target-phrase** influence the number of generations required?
4. How does the behavior differ when **with-selection** is turned off?
5. Why does selection allow improvement to accumulate over generations, while random change does not?


## THINGS TO TRY

1. Run the model with **with-selection** turned **off** and observe how long it takes to make progress.
2. Try very low and very high **mutation-rate** values with selection on. What happens in each case?
3. Increase the length of the **target-phrase** and compare convergence times.
4. Use **go once** to step through early generations and watch how partial matches accumulate.


## REFERENCES

Dawkins, R. 1986. *The Blind Watchmaker*. New York, NY: W. W. Norton & Company.


## HOW TO CITE

Crouse, Kristin (2026). "Dawkins Weasel" (Version 1.2.0). CoMSES Computational Model Library. https://www.comses.net/codebases/6042/releases/1.2.0/


## COPYRIGHT AND LICENSE

© 2018–2026 K. N. Crouse

This model was created at the University of Minnesota as part of a series of models illustrating principles in biological evolution.

This model is released under the **Apache License, Version 2.0**.  
You may use, modify, and redistribute this model in accordance with the terms of that license.

A copy of the license should be included with this distribution.  
If not, it is available at: https://www.apache.org/licenses/LICENSE-2.0

For questions about use or adaptation, contact: **kncrouse@gmail.com**


.
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
NetLogo 6.4.0
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
