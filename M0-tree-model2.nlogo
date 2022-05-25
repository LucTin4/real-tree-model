globals [
  gtree-influence ; le radius de non recouvrement des arbres
  gfield-influence
  patch-area; 10m * 10m = 100m2

  parcels-size
  nombre-villages
  conso-tête
  gros-troupeau
  tps-repousse
  nb-rejets ; nb de rejets/ arbre. A potentiellement mettre en attribu arbre si le nb dépend de la période de coupe, de l'âge etc.
  devient-kadd ; nb jours pour pousse devienne un kadd - a qualibrer
  nb-coupe-fatal


  ; Mes variables globale dans les moniteur ou graph
  total-mil-area        ; m2
  total-groundnuts-area ; m2
  total-under-tree-area ; m2
  day-of-year ; de 1 à 365 jours
  year

  stock-mil-g
  stock-mil-p
  stock-groundnuts-g
  stock-groundnuts-p
  stock-fourrage-moyen

]
patches-own [

  tree-influence
  under-tree ; TRUE/FALSE
  culture ; can be mil or groundnut
  rendement-mil-g ; rendement de patch (à calibrer plus tard)
  rendement-mil-p
  rendement-groundnuts-g
  rendement-groundnuts-p
  id-parcelle ; permet de conservé la structure des parcelles lors de la rotation
  pas-rotation ; permet de suivre les parcelles qui n'ont pas rotatées ( système de +1)
  rotation ; TRUE/FALSE qui exclue de la procédure les parcelles ayant déjà rotatées

]


breed [bergers berger]
bergers-own [
  troupeau-nourri ; pour l'instant TRUE/FALSE mais à détailler
  arbre-choisi
  nb-têtes ; à calibrer (mais va être difficile
  nb-ha ; à calibrer
  stock-fourrage
  transhumance
]
breed [villages village]

breed [trees tree]
trees-own [
  proche-village ; VARIABLE SUREMENT INUTILE (arbres des villages également élagués)
  nb-coupes
  nb-jour-coupe
  age-tree
]

breed [pousses pousse]
pousses-own [
  disséminée ; inutile pour l'instant
  age ; age en jour (possibilité de le changer en année)
  signalé
]

breed [fields field]
fields-own [
  my-patches
  field-area
]


to setup
  ca
  set year 0
  set day-of-year 0

  set-default-shape trees "tree"
  set-default-shape villages "house"
  set-default-shape bergers "person"
  set-default-shape pousses "plant"

  ; globals
  set gtree-influence 2 ; problème car valeur =/= pour l'arachide
  set patch-area 10
  set nombre-villages 1

  set conso-tête 1.0 ; à calibrer
  set gros-troupeau 25 ; demander à partir de combien de bêtes les troupeaux partent en transhumance
  set tps-repousse 1825 ; = 5ans nb d'année minimal pour que l'arbre reprenne sa forme selon Robert (// terrain avec Antoine) - a vérifier.
  set nb-rejets 2
  set devient-kadd 1095 ; = 3ans nb d'année avant que la pousse devienne un kadd
  set nb-coupe-fatal 4
  set parcels-size 13


  ask patches [
   set  tree-influence FALSE
   set under-tree FALSE
   set pas-rotation 0
   set rotation FALSE

  ]

  parcels-generator ; génération des parcelles - trouver une astuce pour que les parcelles soient moins circulaires
  trees-generator
  crops-assignment ; chaque parcelle se voit assigner un type de culture, pour l'instant pris seulement entre mil et arachide
  crop-tree-influence
  villages-generator
  bergers-generator
  update-variables

  reset-ticks

end

  to trees-generator

  ; génération des arbres en faisant attention qu'ils soient espacés d'une distance minimum.


  let n 1
  while [n <= number-trees] [
    create-trees 1[
      setxy random-xcor random-ycor ; avec une condition d'éloignement minimum entre les arbres (random mais avec une certaine régularité)
      set color green
      set size 3
      set nb-coupes 0
      set age-tree random 20 ; ici on ne prend pas en compte que les arbres ne se sont pas régénérés depuis longtemps et ont donc tous le même âge - a déterminer
      set proche-village FALSE
      if [tree-influence] of patch-here = TRUE  [
        let pWithouT one-of patches with[ tree-influence = FALSE]
        ifelse not any? patches with[ tree-influence = FALSE][
          die
        ][
          move-to  pWithouT
        ]

      ]
      ask patches in-radius gtree-influence [
        set tree-influence TRUE
      ]
    ]

    set n n + 1
  ]

end

to parcels-generator

  ; génération des parcelles à partir d'un agent (field) qui une fois créé détermine une zone d'influence autour de lui.
  ; Les patches de cette zone gardent l'identité du field (id-parcelle) et sont donc liés.
  ; problème de recouvrement des parcelles déjà générées, qui rend impossible le contrôle des surfaces de parcelles

   while [count patches with [pcolor = black] != 0][
    create-fields 1 [
      setxy random-xcor random-ycor
      set size 1
      ifelse [pcolor] of patch-here != black [

          let _pblack one-of patches with [pcolor = black]
          ifelse not any? patches with [pcolor = black]
           [
            die
           ][
            move-to  _pblack
            set my-patches patches in-radius parcels-size with [pcolor = black]
            ask my-patches [
              set pcolor [color] of myself
              set id-parcelle [who] of myself
            ]
           ] ; ne peut se générer car patch appartenant déjà à une parcelle donc meurt ou se déplace
        ][
        set my-patches patches in-radius parcels-size with [pcolor = black]
        ask my-patches [
          set pcolor [color] of myself
          set id-parcelle [who] of myself
        ]
        set field-area count my-patches * patch-area

    ] ; peut se générer directement car patch n'appartient pas encore à une parcelle

  ]]

end

to crops-assignment

  ; Ici à chaque parcelle créée est assigné une culture, encore une fois par l'intermédiaire des agents "fields". Permet de contrôler la part de chaque culture
  ; problème mineur lié à l'assignation 1 à 1: la valeur du slider =/= valeur finale (monitorée)
  ; il sera nécessaire par la suite d'inclure la jachère et de mieux renseigner la part de chaque culture (% mil, arachide, jachère)

;  foreach [1.1 2.2 2.6] [ x -> show (word x " -> " round x) ]
  let fields-id [who] of fields
  foreach fields-id [ x ->
    let total-mil-aera count patches with[culture = "mil"] / count patches * 100
    if total-mil-aera < mil-porcent  [
     ask field x [
       ask my-patches [
          set culture "mil"
          set pcolor yellow
        ]
      ]
    ]
  ]
  ask patches with [culture != "mil"][
    set pcolor 36
    set culture "groundnuts"
  ]

end

to crop-tree-influence

  ;Génération de la zone d'infleunce (de fertilisation) des arbres sur les cultures. Calibration Roupsard et son doctorant.

  ask trees [
    ask patches with [culture = "mil"] in-radius 2 [
      set under-tree TRUE
    ]
    ask patches with [culture = "groundnuts"] in-radius 1 [
      set under-tree TRUE
    ]
  ]
end

to villages-generator
  create-villages nombre-villages
    [
     set size 7
     set color red
     setxy random-xcor random-ycor
     ask trees in-radius 20 [set proche-village TRUE]
    ]
end

to bergers-generator

 ; génération des bergers du village. Ils sont liés à un troupeau dont le nombre de tête est variable et déterminé de façon aléatoire (calibrage à affiner?)
 ; et pocèdent un nombre d'ha entre 2 et 5 la aussi défini aléatoirement (calibrage à affiner?)

  create-bergers nombre-bergers
  [
    set size 3
    move-to one-of villages
    set troupeau-nourri FALSE
    set arbre-choisi one-of trees in-radius 100 with [proche-village = FALSE]
    set nb-têtes (random 30) + 15
    set nb-ha (random 3) + 2
    set transhumance FALSE
  ]
end


to update-variables

  ; A l'issue des rotations les surfaces de chaque culture changent - monitorer ces variations fines.
  ; Le stock de fourrage perso des bergers est aussi à suivi chaque go/jour

  set total-mil-area count patches with [culture = "mil"] * patch-area
  set total-groundnuts-area count patches with [culture = "groundnuts"] * patch-area
  set total-under-tree-area count patches with [under-tree = TRUE] * patch-area
  set stock-fourrage-moyen mean [stock-fourrage] of bergers

end

to go

; 1 go = 1 jour, les procédures sont définies temporairement selon découpage annuel
; calendrier: juillet 1, aout 32, sept 60, oct 92, nov 123, déc 155, jan 186, fév 218, mars 249, avril 279, mai 310, juin 339 (5j de trop)

  set day-of-year day-of-year + 1


  if day-of-year = 80 [
    récolte ; est ce qu'il faut mettre la récolte avant le changement de culture?
    rotation-cultures
    retour-bergers
    récolte-machine
    ]

  if day-of-year < 92 ; HIVERNAGE
  []
  if day-of-year = 339
  [rejets]
  if day-of-year >= 92 []; SAISON SECHE
  if day-of-year > 218 [
    nourrir-troupeau] ; peut-être porter la condition plutôt sur les stocks



  croissance-pousse
  croissance-arbre
  mort-arbre

  update-time
  update-variables
  update-graph


  tick

end


to rotation-cultures

  ; il reste à implémenter la priorité faite aux champs qui n'ont pas tourné l'année dernière

  let _myIdParcelle [id-parcelle] of patches ;on récupère toute les identifiant de tout les patches
  set _myIdParcelle remove-duplicates _myIdParcelle ;on supprime les doublons
  foreach _myIdParcelle [ x ->
    ask patches with [id-parcelle = x][
      if culture = "groundnuts" [
        set culture "mil"
        set pcolor yellow
        set rotation TRUE
      ]
    ]
  ]

  foreach _myIdParcelle [ x ->
    let _total-groundnuts-area (count patches with [culture = "groundnuts"] / count patches) * 100
    if _total-groundnuts-area < (100 - mil-porcent) [
    ask patches with [id-parcelle = x and rotation = FALSE][
        set culture "groundnuts"
        set pcolor brown
        set rotation TRUE

      ]
    ]
  ]
  ask patches with [rotation = FALSE][
    set pas-rotation pas-rotation + 1
  ]

  ask patches [set rotation FALSE]

end

to récolte

  ; au premier jour de la saison sèche - récolte = constitution des stocks de mil et d'arachide. Stocks globaux sauf pour ceux des bergers
  ; qui ont été individualisé pour la paille de mil.
  ; prendre en compte le volume d'arachide laissé par terre? (mil = 60%, arachide = 31% Vayssière et al) les valeurs ont sûrement bcp évolué.

  ask patches [ ;reset rendement
    set rendement-mil-g 0
    set rendement-mil-p 0
    set rendement-groundnuts-g 0
    set rendement-groundnuts-p 0
  ]

  ask patches [ifelse culture = "mil"[
    set rendement-mil-g 6.26
    set rendement-mil-p 18.23][
    set rendement-groundnuts-g 3.71
    set rendement-groundnuts-p 11.71]
  ]

  ask patches with [under-tree = TRUE][ifelse culture = "mil"[
    set rendement-mil-g rendement-mil-g * 1.36
    set rendement-mil-p rendement-mil-p * 1.4][; la valeur est arbitraire ici (à calibrer)
    set rendement-groundnuts-g rendement-groundnuts-g * 1 ; inutile car effet du F.A pas prouvé
    set rendement-groundnuts-p rendement-groundnuts-p * 1.5]
  ]

  ask patches with [pas-rotation > 0][ ; baisse de productivité si pas de rotation - valeurs arbitraires + est-ce utilise pour le modèle
   set rendement-mil-g rendement-mil-g * 0.8
   set rendement-mil-p rendement-mil-p * 0.8]

  set stock-mil-g (sum [rendement-mil-g] of patches) * (1 - (paille-laissée / 100)) ; calibrer le pourcentage de paille laissée aux champs
  set stock-mil-p sum [rendement-mil-p] of patches
  set stock-groundnuts-g sum [rendement-groundnuts-g] of patches
  set stock-groundnuts-p sum [rendement-groundnuts-p] of patches

  ask bergers [set stock-fourrage ((stock-mil-p / 100) * nb-ha) * (1 - (paille-laissée / 100))] ; les bergers laissent-ils moins de paille que les autres?

end

to retour-bergers
  ask bergers [
    set transhumance FALSE
  ]

end

to récolte-machine
  ask pousses [
    if signalé = FALSE [die]
  ]
end

to nourrir-paille

  ; Quand l'herbe vient à manquer (estimé en février), le berger commence à nourir son troupeau avec son stock de paille de mil
  ; la consommation quotidienne dépend du nombre de vache (tête) mais est-ce vraiment le cas? et combien consomme une vache/ un troupeau?

  ask bergers [
     ifelse stock-fourrage - conso-tête * nb-têtes > 0 [ ;
     set stock-fourrage stock-fourrage - conso-tête * nb-têtes
        set stock-mil-p stock-mil-p - conso-tête * nb-têtes
      ][
        set stock-fourrage 0
       ]
    ]


end

to nourrir-troupeau

  ; le troupeau est nourri avec les stocks de paille, une fois écoulé: soit départ en transhumance si gros troupeau (globale a calibrer), soit coupe d'arbre
  ; problème: les bergers avec petits troupeaux coupent des arbres avant que les stocks soient entiérement finis.

    nourrir-paille
    ask bergers [
      if stock-fourrage < 500 [
        ifelse nb-têtes > gros-troupeau
        [
         move-to one-of villages
         set transhumance TRUE
        ][
          berger-coupe
        ]
      ]
    ]

end



to berger-coupe

  ; chaque jour le berger choisit un arbre et le coupe (pas de simulation du déplacement) e qui affecte les cultures aux alentours
  ; Seulement un critère influence leur choix: la proximité au village, peut-être affiner les critères de choix (entretien avec Diouf)
  ; ici une grosse hypothèse a été faite: l'étêtage d'un arbre met un terme à son effet fertilisant (sûrement faux)


     ; mesure un peu arbitraire, calibration plus fine?

  let _arbres-restant count trees ; with [proche-village = FALSE and size != 1]
  ifelse _arbres-restant != 0 [
  move-to one-of trees ; with [proche-village = FALSE and size != 1]
    ask trees-here [
      set size 1
      set nb-coupes nb-coupes + 1
      ask patches with [culture = "mil"] in-radius 2 [
          set under-tree FALSE]
      ask patches with [culture = "groundnuts"] in-radius 1 [
          set under-tree FALSE]
    ]
  ]
  []
  ;]






end


to croissance-arbre

  ; les arbres retrouvent leurs branches et leurs feuilles à partir d'un certain jour - tps-repousse (à déterminer et peut-être définir plusieurs palliers
  ; ou voir autres pour éviter les effets de seuil) A faire varier selon d'autres facteurs surement - nb coupes antérieures (nb-coupes déjà en variable), âge (age)

  ; croissance après coupe
  ask trees with [size = 1][
    ifelse nb-jour-coupe < tps-repousse [
      set nb-jour-coupe nb-jour-coupe + 1
    ][
      set size 3
      ask patches with [culture = "mil"] in-radius 2 [
        set under-tree TRUE]
      ask patches with [culture = "groundnuts"] in-radius 1 [ ; on aurait pu aussi copier juste le nom de la procédure mais problème car ask tous les trees
        set under-tree TRUE]
      set nb-jour-coupe 0]
  ]

end

to mort-arbre ; bizarre car la procédure à l'air de fonctionner mais le show ne marche pas.

  if day-of-year = 350 [
    ask trees [set age-tree age-tree + 1]]

  ask trees [
    ifelse nb-coupes >= nb-coupe-fatal [
      if age-tree > 10 [die]

    ][
      if age-tree > 20 [die]

    ]
  ]

end

 to croissance-pousse
  ; les pousses deviennent arbres à partir d'un certain nb de jour (devient-kadd)

  ask pousses [
     set age age + 1
     if age > devient-kadd [
      set breed trees
      set size 3
      set nb-coupes 0
      set age-tree 0
      ask patches with [culture = "mil"] in-radius 2 [
      set under-tree TRUE
    ]
      ask patches with [culture = "groundnuts"] in-radius 1 [
      set under-tree TRUE
      ]
      ifelse any? villages in-radius 20 [
        set proche-village TRUE]
      [set proche-village FALSE]
    ]
  ]

end

to rejets

; les arbres font des rejets: quelles période? cb? ou?
  ask trees with [size != 1][
   hatch-pousses nb-rejets [
      set size 0.7
      rt random 360
      forward 10
      set disséminée FALSE
      set age 0
      set signalé FALSE
    ]
  ]

end

to update-time

  ; permet de suivre le calendrier: quel jour on est!

  if day-of-year > 364 [
    set day-of-year 0
    set year year + 1]

end

to update-graph

  if day-of-year = 1 [
    set-current-plot "Volume de mil"
  set-current-plot-pen "pen-0"
  plotxy year stock-mil-p
    set-current-plot "Âge moyen du parc"
    ask trees [
    set-current-plot-pen "pen-0"
      plotxy year mean [age-tree] of trees
    ]
  ]

  set-current-plot "paille-berger"
  ask bergers [
    set-plot-pen-color color
    plotxy ticks stock-fourrage
  ]


end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
618
419
-1
-1
4.0
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
99
0
99
0
0
1
ticks
30.0

BUTTON
20
20
100
53
Set Up
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

SLIDER
32
102
204
135
number-trees
number-trees
0
4000
535.0
1
1
NIL
HORIZONTAL

SLIDER
30
175
207
208
mil-porcent
mil-porcent
0
100
69.0
1
1
%
HORIZONTAL

MONITOR
125
135
205
172
arbres/ha
count trees / 100
17
1
9

MONITOR
125
210
210
247
%-mil
(total-mil-area / (count patches * patch-area)) * 100
1
1
9

MONITOR
640
110
765
155
%-under-tree
(total-under-tree-area / (count patches * patch-area)) * 100
2
1
11

TEXTBOX
645
20
795
41
1 patch = 10 m2\nEnv = 1 000 000 m2 = 100 ha
9
0.0
1

SLIDER
35
250
207
283
nombre-bergers
nombre-bergers
0
100
13.0
1
1
NIL
HORIZONTAL

BUTTON
120
20
183
53
GO
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

MONITOR
640
50
765
95
Date 
(word day-of-year \" \" year)
0
1
11

BUTTON
120
55
207
88
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

PLOT
635
170
835
320
Volume de mil
year
Vol-mil
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -5298144 true "" ""

MONITOR
895
320
1052
365
NIL
stock-fourrage-moyen
1
1
11

PLOT
855
170
1055
320
paille-berger
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

SLIDER
880
135
1052
168
paille-laissée
paille-laissée
0
100
48.0
1
1
%
HORIZONTAL

MONITOR
130
285
207
322
bergers-là
count bergers with [transhumance = FALSE]
17
1
9

PLOT
1080
170
1280
320
nombre d'arbres 
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count trees with [size != 1]"

MONITOR
690
395
797
440
NIL
count pousses
17
1
11

PLOT
1075
10
1275
160
Âge moyen du parc
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

@#$#@#$#@
## WHAT IS IT?

Ce modèle montre les effets des arbres d'un parc arboré sur les rendements de cultures (mil et arachide) 

## HOW IT WORKS



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
NetLogo 6.2.2
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
1
@#$#@#$#@
