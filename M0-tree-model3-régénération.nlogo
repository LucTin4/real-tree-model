globals [
  gtree-influence ; le radius de non recouvrement des arbres
  gfield-influence
  patch-area; 10m * 10m = 100m2
  mil-porcent


  parcels-size


  ; Mes variables à qualibrer
  conso-tête ; consommation de mil par vache
  tps-repousse ; nb de jours entre 2 étêtages
  nb-rejets ; nb de rejets/ arbre. A potentiellement mettre en attribu arbre si le nb dépend de la période de coupe, de l'âge etc.
  devient-kadd ; nb jours pour pousse devienne un kadd - a qualibrer et a faire varier avec la RNA
  nb-coupe-fatal ; nombre de coupe à partir de laquelle l'arbre meurt plus rapidement
  surface-jachère ; pourcentage de surface mise en jachère
  pousse-sauvée ; nb jours à partir duquel la pousse ne peut plus être détruit par une machine
  distance-champ-brousse ; jusqu'où s'étendent les champs intermédiaires nb * patch-area
  nombre-coupeurs ; a combien estimer le nombre de coupeur
  paille-laissée ; avant slider - mais aucune paille laissée désormais variable a-t-elle encore un sens?
  age-p-interm ; âge à partir duquel la pousse est sauvée des machines mais menacée par les coupes
  effet-reunion
  effet-reussite
  effet-discussion
  effet-coupe
  stock-limite
  nb-coupes-vigilance;
  age-max-arbre
  reduc-age
  duree-peur-crit
  duree-peur
  arb-reussite
  tmier-FA
  nb-attrape-crit
  nb-coupe
  nb-arb-brousse
  nb-arb-case
  Moy-tps-chp
  Max-tps-chp
  charrette-bois
  charrette-bois-année



  ; Mes variables globale dans les moniteur ou graph
  total-mil-area        ; m2 (53% de la SAU, Vayssière)
  total-groundnuts-area ; m2 (7% SAU, Vayssière
  total-under-tree-area ; m2
  total-jachère-area
  jour-réu
  day-of-year ; de 1 à 365 jours
  year
  année-rotation

  stock-mil-g
  initStockMil  ; ke stock de mil initial a Year +1
  DelatMil ; stock mil final - stock mil init
  sacMoyenMil
  stock-mil-p
  stock-groundnuts-g
  stock-groundnuts-p
  stock-fourrage-moyen

  ; indicateurs
  %-under-tree
  coupeurs-attrapes
  age-moy-arb
  nb-arbres
  init-nb-arbre
  delat-Nb-arbres
  pouss
  pouss-prot
  pouss-inter-prot
  MoyN-interet-RNA
  nb-engages


]

patches-own [

  tree-influence
  under-tree ; TRUE/FALSE
  culture ; can be mil or groundnut
  en-culture
  rendement-mil-g ; rendement de patch (à calibrer plus tard)
  rendement-mil-p ; en fagots
  rendement-groundnuts-g
  rendement-groundnuts-p
  id-parcelle ; permet de conservé la structure des parcelles lors de la rotation
  pas-rotation ; permet de suivre les parcelles qui n'ont pas rotatées ( système de +1)
  rotation ; TRUE/FALSE qui exclue de la procédure les parcelles ayant déjà rotatées
  champ-brousse;
  zoné; TRUE/FALSE utilisé pour définition des zones de jachère
  zone; 3 zones pour la rotation de la jachère

]


breed [bergers berger]
bergers-own [
  troupeau-nourri ; pour l'instant TRUE/FALSE mais à détailler
  arbre-choisi
  nb-têtes ; à calibrer (mais va être difficile
  nb-ha-b ; entre 3,8 (nouveaux installés 11%) et ~ 5,5 (89% de la pop)
  stock-fourrage
  idAgri ; identifiant de mon agriculteur de référence
  timer-FA
]

breed [coupeurs coupeur]
coupeurs-own [
  attrape
  nb-attrape
  jours-peur
  en-coupe
]

breed [agriculteurs agriculteur]
agriculteurs-own [
  id-agri ; ce qui le lie à son unique parcelle
  engagé ; TRUE/FALSE engagement dans la RNA
  interet-RNA
  jour-champ
  nb-ha-a
  stock-mil
  idMyBerger
  nb-patches
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
  age ; age en jour (possibilité de le changer en année)
  signalé
  rna-coupe
]

breed [fields field]
fields-own [
  my-patches
  field-area
  visité
  coupé
  plus-arbres
  en-RNA
]

breed [surveillants surveillant]
surveillants-own [
]

breed [concessions concession]
concessions-own [
]


;___________________________________________________________________________



to setup
  ca
  set year 0
  set day-of-year 0
  set année-rotation 0

  set-default-shape trees "tree"
  set-default-shape villages "house"
  set-default-shape bergers "cow"
  set-default-shape pousses "plant"
  set-default-shape agriculteurs "person"

  ; globals
  set gtree-influence 2 ; problème car valeur =/= pour l'arachide
  set patch-area 10
  set nb-arbres 535
  set init-nb-arbre nb-arbres
  set mil-porcent 80


  set conso-tête 0.4 ; à calibrer
  set stock-limite 1000 ; stock à partir duquel les bergers coupent des arbres pour amortir #TODO
  set tps-repousse 1456 ; = 4ans nb d'année minimal pour que l'arbre reprenne sa forme selon Robert (// terrain avec Antoine) - a vérifier. #TODO
  set nb-rejets 3 ; difficile de savoir combien de rejets
  set devient-kadd 3000 ; = 8ans nb d'année avant que la pousse devienne un kadd
  set nb-coupe-fatal 4
  set parcels-size 9
  set surface-jachère 20
  set pousse-sauvée 1092; plus de 6 ans
  set distance-champ-brousse 40 ; les champs de brousse commencent à 400m du village (c'est surement plus)
  ;; q-présence-brousse 0.02 ; les gens sont 5 fois moins présent en brousse que dans les champs de case et intermédiaire (a calibrer)*
  set age-p-interm 1092 ; environ 3 ans.
  set jour-réu 364 / fréquence-réu
  set effet-reunion 50
  set effet-reussite 75
  set effet-discussion 1
  set effet-coupe 5 ; montant du score (0 à 100) qui baisse par effet de coupe
  set nb-coupes-vigilance 8 ; à partir duquel les agriculteurs stoppent systématiquement les coupeurs
  set age-max-arbre 100 ; arbre moyen de mort des arbres
  set reduc-age 20 ; nb d'année de vie à soustraire si coupes successive (nb-coupe-fatal) (a enlever)
  set nb-attrape-crit 3; a partir duquel coupeur s'arretent de couper plus longtemps
  set duree-peur-crit 200 ; nb jour où les coupeurs recidiviste s'arretent de couper après etre surpris
  set duree-peur 30 ; nb jours où les coupeurs s'arretent de couper apres etre surpris
  set arb-reussite 2; nb de jeunes pousses devenues arbres à partir duquel agri voisins vont vouloir s'engager dans RNA
  set jour-réu 364 / fréquence-réu
  set Max-tps-chp 0




  ask patches [
   set  tree-influence FALSE
   set under-tree FALSE
   set pas-rotation 0
   set rotation FALSE
   set en-culture FALSE
   set champ-brousse TRUE
   set zoné FALSE

  ]

  villages-generator
  parcels-generator ; génération des parcelles - trouver une astuce pour que les parcelles soient moins circulaires
  trees-generator
  crops-assignment ; chaque parcelle se voit assigner un type de culture, pour l'instant pris seulement entre mil et arachide
  crop-tree-influence
  bergers-generator
  coupeurs-generator
  agriculteurs-generator
  surveillants-generator
  concessions-generator

  set total-mil-area count patches with [culture = "mil"] * patch-area
  set total-groundnuts-area count patches with [culture = "groundnuts"] * patch-area
  set total-jachère-area count patches with [culture = "jachère"] * patch-area
  set total-under-tree-area count patches with [under-tree = TRUE] * patch-area
  set stock-fourrage-moyen mean [stock-fourrage] of bergers
  set %-under-tree (total-under-tree-area / (count patches * patch-area)) * 100
  set %-under-tree (total-under-tree-area / (count patches * patch-area)) * 100


  set nb-coupe 0
  set nb-arbres count trees
  set coupeurs-attrapes 0
  set age-moy-arb mean [age-tree] of trees
  set pouss count pousses
  set pouss-prot count pousses with [signalé = TRUE]
  set pouss-inter-prot count pousses with [age > age-p-interm]
  set MoyN-interet-RNA mean [interet-RNA] of agriculteurs
  set nb-engages count agriculteurs with [engagé = TRUE]
  set nb-arb-brousse count trees with [[champ-brousse] of patch-here = TRUE]
  set nb-arb-case count trees with [[champ-brousse] of patch-here = FALSE]
  set charrette-bois 0



  reset-ticks

end

  to trees-generator

  ; génération des arbres en faisant attention qu'ils soient espacés d'une distance minimum.


  let n 1
  while [n <= nb-arbres] [
    create-trees 1[
      setxy random-xcor random-ycor ; avec une condition d'éloignement minimum entre les arbres (random mais avec une certaine régularité)
      set color green
      set size 3
      set nb-coupes 0
      set age-tree random 40 + 60  ; ici on ne prend pas en compte que les arbres ne se sont pas régénérés depuis longtemps et ont donc tous le même âge - a déterminer
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

to villages-generator

  ; le village apparait toujours au même endroit. sont déterminés les chanps de case et champs de brousse (distance-champ-brousse)

  create-villages 1
  [
    set size 5
    set color red
    setxy 75 75
    ask trees in-radius 20 [set proche-village TRUE]
    ask patches in-radius distance-champ-brousse [set champ-brousse FALSE]

    ]
end

to parcels-generator

  ; génération des parcelles à partir d'un agent (field) qui une fois créé détermine une zone d'influence autour de lui.
  ; Les patches de cette zone gardent l'identité du field (id-parcelle) et sont donc liés.
  ; problème de recouvrement des parcelles déjà générées, qui rend impossible le contrôle des surfaces de parcelles

   while [count patches with [pcolor = black] != 0][
    create-fields 1 [
      setxy random-xcor random-ycor
      set size 0.1
      set coupé 0
      set plus-arbres 0
      set visité FALSE
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
  ; mieux renseigner la part de chaque culture (% mil, arachide, jachère)
  ; 3 zones ont été définie - elles permettent la rotation de la jachère sur 3 ans.
  ; problème - les champs de brousse sont éloignés d'environ 1km (hors de la surface de simulation)

   ask patches [
    if pycor > 45 [set zone 0]
    if pxcor < 46 and pycor < 46 [set zone 1]
    if pxcor > 45 [set zone 2]
    ]

  let fields-id [who] of fields


  foreach fields-id [ x ->
    let _total-jachère-area (count patches with[culture = "jachère"] / count patches) * 100
    if _total-jachère-area < surface-jachère  [
     ask field x [
      ifelse [zone] of patch-here = 2 [
        ask my-patches with [en-culture = FALSE][
        if champ-brousse = TRUE [
          set culture "jachère"
          set pcolor 9
          set en-culture TRUE
        ]
      ]
      ][]
  ]
  ]
  ]



  foreach fields-id [ x ->
    let total-mil-aera (count patches with[culture = "mil"] / count patches with [culture != "jachère"])* 100
    if total-mil-aera < mil-porcent  [
     ask field x [
        ask my-patches with [en-culture = FALSE][
          set culture "mil"
          set pcolor yellow
          set en-culture TRUE
        ]
      ]
    ]
  ]
  ask patches with [en-culture = FALSE][
    set pcolor 36
    set culture "groundnuts"
  ]

end

to crop-tree-influence

  ;Génération de la zone d'infleunce (de fertilisation) des arbres sur les cultures. Calibration Roupsard et son doctorant.
  ; Est-ce que cettte procédure est encore utile? Oui si on considère les stocks de mil et d'arachide comme Output intéressant.

  ask trees [
    ask patches with [culture = "mil"] in-radius 2 [
      set under-tree TRUE
    ]
    ask patches with [culture = "groundnuts"] in-radius 1 [
      set under-tree TRUE
    ]
  ]
end


to bergers-generator

 ; génération des bergers du village. Ils sont liés à un troupeau dont le nombre de tête est variable et déterminé de façon aléatoire (calibrage à affiner?)
 ; et pocèdent un nombre d'ha entre 2 et 5 la aussi défini aléatoirement (calibrage à affiner?)
 ; est-il nécessaire de créer une variable "troupeau gardé"? Ne semble pas être un frein majeur à la régénération du parc.

  create-bergers nombre-bergers
  [
    set size 3
    move-to one-of villages
    set troupeau-nourri FALSE
    set arbre-choisi one-of trees in-radius 100 with [proche-village = FALSE]
    set nb-têtes (random 13) + 12 ; les troupeaux qui restent ont entre 12 et 25 vaches
    set nb-ha-b (random 2) + 3.5
    set color brown
    set idAgri 9999
    set timer-FA 6
  ]
end

to coupeurs-generator

  ; un nombre de coupeur (variable) est défini
  ; Peut-être qu'il serait pertinent de faire varier ce nombre selon les besoins en bois / la sensibilisation des jeunes bergers?

  create-coupeurs nb-coupeurs
  [
    set attrape FALSE
    set nb-attrape 0
    set jours-peur 0
    set en-coupe FALSE
  ]
end

to agriculteurs-generator

  ; Pour chaque champ, un agriculteur est créé. Ils sont liés entre eux.
  ; certains d'agriculteurs sont engagés dans la RNA (engagés-initiaux - variable qui reste à faire varier)
  ; Il serait mieux d'assigner plusieurs champs à un même agriculteurs - si (hypo) l'agriculteur est plus suceptible de protéger les pousses
  ; dans les champs proches.

  let _myIdParcelle [id-parcelle] of patches ;on récupère toute les identifiant de tout les patches
  set _myIdParcelle remove-duplicates _myIdParcelle ;on supprime les doublons

  foreach _myIdParcelle [ x ->
    create-agriculteurs 1
    [set id-agri x
      set size 1
      set jour-champ 0
      set interet-RNA 0
      set engagé FALSE
      set nb-ha-a (random 3) + 2
      set nb-patches count patches with [id-parcelle = [id-agri] of myself]
      let _myWho who
      if any? bergers with[idAgri = 9999][
        ask one-of bergers with [idAgri = 9999][
          set idAgri _myWho
        ]
      ]
    ]

  ]

  ask n-of engagés-initiaux agriculteurs [
    set engagé TRUE
    set interet-RNA 100
    let _my-field fields with [who = [id-agri] of myself]
    ask _my-field [ set en-RNA TRUE]
  ]

  let _nb-agri count agriculteurs

end

to concessions-generator

  ; créer les concessions en groupant des agriculteurs de brousse et de case

end

to surveillants-generator

  create-surveillants nb-surveillants

end

;______________________________________________________________________________________________


to go

; 1 go = 1 jour, les procédures sont définies temporairement selon découpage annuel
  ; calendrier: juillet 1, aout 32, sept 60, oct 92, nov 123, déc 155, jan 186, fév 218, mars 249, avril 279, mai 310, juin 339 (5j de trop)
  ;if day-of-year < 140 HIVERNAGE
  ;if day-of-year >= 140 SAISON SECHE

  if nb-arbres <= 0 OR ticks > 8395[ ;; si plus d'arbre ou 23 ans de simu stop
   stop
  ]
  set day-of-year day-of-year + 1

  if day-of-year = 140 [
    récolte ; est ce qu'il faut mettre la récolte avant le changement de culture?
    récolte-machine
    rotation-cultures
    stock-agri
  ]

  if day-of-year < 140 [
  berger-jachère
  ] ; HIVERNAGE
  if day-of-year >= 140 []; SAISON SECHE

  if day-of-year = 310
  [rejets]

  if day-of-year > 249 ; a changer mars
  [nourrir-troupeau] ; peut-être porter la condition plutôt sur les stocks

  présence-champs
  Régénération-NA
  if day-of-year >= 140 [
    reperage-pousse]
  surveillance-representant
  surveillance-champ
  if day-of-year >= 140 [
    coupe-pousse]
  croissance-pousse
  croissance-arbre
  mort-arbre

  update-variables
  update-graph
  update-time


  tick

end


to rotation-cultures

  ; Les parcelles tournent. Elles passent toutes en mil, puis la jachère apparait, et enfin les champs d'arachide (le reste)
  ; On pourrait affiner la rotation: les champs de case tj en mil, les champs intermédiaires mil/arachide, après la jachère arachide
  ; sauf si Puf Ndao (parcelles fumées en jachère)

  let _myIdParcelle [id-parcelle] of patches ;on récupère toute les identifiant de tout les patches
  set _myIdParcelle remove-duplicates _myIdParcelle ;on supprime les doublons

  foreach _myIdParcelle [ x ->
      ask patches with [id-parcelle = x and rotation = FALSE][
        if culture != "mil" [
          set culture "mil"
          set pcolor yellow
        ]
      ]
    ]

let fields-id [who] of fields

 foreach fields-id [ y ->
    let _total-jachère-area (count patches with[culture = "jachère"] / count patches) * 100
    if _total-jachère-area < surface-jachère  [
      ask field y [
        if année-rotation = 0 [
          ifelse [zone] of patch-here = 0 [
            ask my-patches with [rotation = FALSE][
              if champ-brousse = TRUE [
                set culture "jachère"
                set pcolor 9
                set rotation TRUE
              ]
            ]
          ][]
        ]
        if année-rotation = 1 [
          ifelse [zone] of patch-here = 1 [
            ask my-patches with [rotation = FALSE][
              if champ-brousse = TRUE [
                set culture "jachère"
                set pcolor 9
                set rotation TRUE
              ]
            ]
          ][]
        ]
        if année-rotation = 2 [
          ifelse [zone] of patch-here = 2 [
            ask my-patches with [rotation = FALSE][
              if champ-brousse = TRUE [
                set culture "jachère"
                set pcolor 9
                set rotation TRUE
              ]
            ]
          ][]
        ]
      ]
    ]
  ]


  foreach _myIdParcelle [ x ->
    let _total-groundnuts-area (count patches with [culture = "groundnuts"] / count patches with [culture != "jachère"]) * 100
    if _total-groundnuts-area < (100 - mil-porcent) [
    ask patches with [id-parcelle = x and rotation = FALSE][
        set culture "groundnuts"
        set pcolor brown
        set rotation TRUE

      ]
    ]
  ]

  ask patches [set rotation FALSE]

  ifelse année-rotation = 0 [
    set année-rotation année-rotation + 1
  ][
    ifelse année-rotation = 1 [
      set année-rotation année-rotation + 1
    ][
      set année-rotation année-rotation - 2
    ]
  ]

end

to récolte

  ; au premier jour de la saison sèche - récolte = constitution des stocks de mil et d'arachide. Stocks globaux sauf pour ceux des bergers
  ; qui ont été individualisé pour la paille de mil.
  ; prendre en compte le volume d'arachide laissé par terre? (mil = 60%, arachide = 31% Vayssière et al) mais plus rien n'est laissé dans les champs ajd

  ask patches [ ;reset rendement
    set rendement-mil-g 0
    set rendement-mil-p 0
    set rendement-groundnuts-g 0
    set rendement-groundnuts-p 0
  ]

  ask patches with [culture != "jachère"] [ifelse culture = "mil"[
    set rendement-mil-g 6.26
    set rendement-mil-p 1.00][; en fagots - 100 fag/ha ramené au patch 1 fag/10 m2
    set rendement-groundnuts-g 3.71
    set rendement-groundnuts-p 11.71]
  ]

  ask patches with [under-tree = TRUE and culture != "jachère"][ifelse culture = "mil"[
    set rendement-mil-g rendement-mil-g * 1.36
    set rendement-mil-p rendement-mil-p * 2][; la valeur est arbitraire ici (à calibrer)
    set rendement-groundnuts-g rendement-groundnuts-g * 1 ; inutile car effet du F.A pas prouvé
    set rendement-groundnuts-p rendement-groundnuts-p * 1.5]
  ]

  ask patches with [pas-rotation > 0][ ; baisse de productivité si pas de rotation - valeurs arbitraires + est-ce utilise pour le modèle
   set rendement-mil-g rendement-mil-g * 1 ;plus de baisse de productivité si le mil n'a pas tourné
   set rendement-mil-p rendement-mil-p * 1]

  set stock-mil-g (sum [rendement-mil-g] of patches) * (1 - (paille-laissée / 100)) ; calibrer le pourcentage de paille laissée aux champs
  set stock-mil-p sum [rendement-mil-p] of patches
  set stock-groundnuts-g sum [rendement-groundnuts-g] of patches
  set stock-groundnuts-p sum [rendement-groundnuts-p] of patches

  ask bergers [
    set stock-fourrage ((stock-mil-p / 100) * nb-ha-b) * (1 - (paille-laissée / 100))
  ] ; les bergers laissent-ils moins de paille que les autres?



end

to stock-agri

  ask agriculteurs [
    ifelse [culture] of one-of patches with [id-parcelle = [id-agri] of myself] = "mil" [
      set stock-mil nb-patches * 6.26
      if year < 2 [
       set initStockMil  stock-mil
      ]
    ][
      set stock-mil 0
    ]
  ]
end

to récolte-machine

  ; les pousses sont détruites par les machines si elles ne sont pas signalées (signalé FALSE). Elles sont protégées par la jachère
  ; et sont sauvées à partir d'un certain âge (pousse-sauvée ~ 2 ans)

  ask pousses with [age < pousse-sauvée] [
    if signalé = FALSE [
    ifelse [culture] of patch-here != "jachère"
        [die]
        []
      ]
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

  ; Réflechir de nouveau a cette procédure - les arbres sont coupés dès la disparition de l'herbe pour amortir la diminution des stocks
  ; + faut-il inclure les Neems aussi? Puisque que la coupe des F dépend de la disponibilité des Neems

  nourrir-paille
  ask bergers [
    if stock-fourrage <= 0 [
      berger-coupe
    ]
  ]


end



to berger-coupe

  ; chaque jour le berger choisit un arbre et le coupe (pas de simulation du déplacement + plus de prise en compte de la distance au village
  ; Les bergers coupent dorénavant 1 fois par semaine (1j/7)

  let _arbres-restant count trees with [size != 0.1]; with [proche-village = FALSE and size != 0.1]
  if _arbres-restant != 0 [
    let _proba random 100
    ifelse timer-FA = 6 [
      move-to one-of trees with [size != 0.1] ; with [proche-village = FALSE and size != 0.1]
      ask trees-here [
        set size 0.1
        set nb-coupes nb-coupes + 1
      ]
      set timer-FA 0
      set charrette-bois charrette-bois + 1
    ][
      set timer-FA timer-FA + 1
    ]
  ]




end

to berger-jachère

 ; les bergers restant vont dans la jachère (à partir du semi des arachides - a définir). Ils y coupent les jeunes pousses.

  ask bergers [
    move-to one-of patches with [culture ="jachère"]
    if not any? agriculteurs with [engagé = TRUE] in-radius 10 [
      let _myAgriEngage? [engagé] of agriculteurs with[who = [idAgri] of myself]
      if _myAgriEngage? = FALSE [
        if any? pousses in-radius 3 [
          ask pousses in-radius 3 [die]
        ]
      ]
    ]
  ]

end

to présence-champs

  ; Les agriculteurs vont dans leur champ. Ils sont plus présents dans les champs de case que dans les champs de brousse (facteur q-présence-brousse)


  ask agriculteurs
  [
    move-to one-of patches with [id-parcelle = [id-agri] of myself]
     if day-of-year > 140 [
      ifelse [champ-brousse] of patch-here = TRUE [
;        if [culture] of patch-here = "jachère" [move-to one-of villages]  A réintégrer quand plus de temps
        if random 100 > (tps-au-champ * q-présence-brousse) [move-to village 0]
      ][
        if random 100 > (tps-au-champ) [move-to village 0]
      ]
    ]
    if [id-parcelle] of patch-here = id-agri [
      set jour-champ jour-champ + 1
    ]
  ]

end

to surveillance-champ

  if S-pop [

  ask agriculteurs with [engagé = TRUE][
    if [id-parcelle] of patch-here = id-agri [ ; si l'agriculteur est dans son champ
      let _my-field fields with [who = [id-agri] of myself]
      let _nb-coupe first [coupé] of _my-field
      ifelse _nb-coupe > nb-coupes-vigilance [   ; si il a déjà eu de nbreuses coupes dans son champ

        ask coupeurs in-radius 10 with [en-coupe = TRUE] [
          set attrape TRUE
          set nb-attrape nb-attrape + 1
          set coupeurs-attrapes coupeurs-attrapes + 1
          let _proba random 100
          if _proba > 20 [                        ; probable qu'il ne le voit pas avant
            set en-coupe FALSE
          ]
        ]
      ][
        let _proba random 100
        if _proba < proba-denonce [
          ask coupeurs in-radius 10 with [en-coupe = TRUE] [
            set attrape TRUE
            set nb-attrape nb-attrape + 1
            set coupeurs-attrapes coupeurs-attrapes + 1
            if _proba > 20 [                      ; probable qu'il ne le voit pas avant
              set en-coupe FALSE
            ]
          ]
        ]
      ]
    ]
  ]
  ]


end

to surveillance-representant

  ; Les surveillants vont de champs en champs. Ils commencent par les champs en RNA (hypo assez forte) puis visite un nb champs variables (nb-chp-visités)
  ; ils arrêtent systématiquement le coupeur (ici aussi discutable) mais la proba qu'ils le voient depend du tps qu'ils restent dans le champs // nb chps visités
  ; Le sanction est inchangée mais devrait peut-être l'être.
  ;

  if S-repreZ [

    let n 1
    ask surveillants [
      while [n <= nb-champs-visités][                                    ; jusqu'à ce qu'il soit allé dans nb de champs prévu
        let _chp-RNA count fields with [en-RNA = TRUE and visité = FALSE]
        ifelse _chp-RNA > 0 [                                            ; il va d'abord dans les champs en RNA puis dans les autres
          move-to one-of fields with [en-RNA = TRUE]
          ask fields-here [set visité TRUE]                              ; il se souvient des champs où il est déjà allé dans la journée
          if any? coupeurs with [en-coupe = TRUE] in-radius 10 [         ; si il voit un coupeur aux alentours
            let _proba1 random 100                                      ; la proba qu'il le surprenne effectivement dans les champs dépend du nb de champ
            if _proba1 < (100 / (nb-champs-visités * 0.25))[                     ; a visiter dans la journée (bcp de champs // peu de temps passer dans chacun
              ask coupeurs in-radius 10 with [en-coupe = TRUE] [
                set attrape TRUE
                set nb-attrape nb-attrape + 1
                set coupeurs-attrapes coupeurs-attrapes + 1
                set en-coupe FALSE
              ]
            ]
          ]
        ][
          move-to one-of fields with [visité = FALSE]                   ; quand il n'y a plus de champ en RNA, continu dans les autres champs
          ask fields-here [set visité TRUE]
          if any? coupeurs with [en-coupe = TRUE] in-radius 10 [
            let _proba1 random 100
            if _proba1 < 100 / (nb-champs-visités * 0.25) [
              ask coupeurs in-radius 10 with [en-coupe = TRUE] [
                set attrape TRUE
                set nb-attrape nb-attrape + 1
                set coupeurs-attrapes coupeurs-attrapes + 1
                set en-coupe FALSE
              ]
            ]
          ]

        ]
        set n n + 1
      ]
    ]
       ifelse coordination [
      ][
        ask fields [set visité FALSE]
      ]
  ]

  ask fields [set visité FALSE]

end

to croissance-arbre

  ; les arbres retrouvent leurs branches et leurs feuilles à partir d'un certain jour - tps-repousse (à déterminer et peut-être définir plusieurs palliers
  ; ou voir autres pour éviter les effets de seuil) A faire varier selon d'autres facteurs surement - nb coupes antérieures (nb-coupes déjà en variable), âge (age)

  ; croissance après coupe
  ask trees with [size = 0.1][
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

to mort-arbre
  ; hypothèse forte que les coupes successive influence la durée de vie de l'arbre
  ; les arbres meurt vers 100 ans.

  if day-of-year = 350 [
    ask trees [set age-tree age-tree + 1]]

  ask trees [
    ifelse nb-coupes >= nb-coupe-fatal [
      if age-tree > (age-max-arbre - reduc-age) [
        ask patches with [culture = "mil"] in-radius 2 [
          set under-tree FALSE]
        ask patches with [culture = "groundnuts"] in-radius 1 [
          set under-tree FALSE]
          die
      ]
    ][
      if age-tree > age-max-arbre [
        ask patches with [culture = "mil"] in-radius 2 [
          set under-tree FALSE]
        ask patches with [culture = "groundnuts"] in-radius 1 [
          set under-tree FALSE]
          die
        ]
      ]
    ]


end

 to croissance-pousse
  ; les pousses deviennent arbres à partir d'un certain nb de jour (devient-kadd)
  ; la croissance est accéléré de 300% par la RNA - besoin de calibrer + tous les protecteurs semblent tailler les arbres

  ask pousses [
     set age age + 1
     if age > devient-kadd [
      set breed trees
      set size 3
      set nb-coupes 0
      set age-tree 0
      set color green
      ask patches with [culture = "mil"] in-radius 2 [
        set under-tree TRUE
      ]
      ask patches with [culture = "groundnuts"] in-radius 1 [
        set under-tree TRUE
      ]
      ifelse any? villages in-radius 20 [
        set proche-village TRUE]
      [set proche-village FALSE]

      let _quel-champ [id-parcelle] of patch-here
      ask fields with [who = _quel-champ][set plus-arbres plus-arbres + 1]
    ]
  ]


end

to rejets

; les arbres font des rejets (nb-rejets): quelles période? cb? ou?
; les arbres étêtés n'en font pas

  ask trees with [size != 0.1][
   hatch-pousses nb-rejets [
      set size 0.7
      rt random 360
      forward 10
      set age 0
      set signalé FALSE
    ]
  ]

end

to reperage-pousse

  ; Les coupeurs se baladent et coupent une pousse (arbustre de minimum 3 ans) par jour si il n'y a pas de présence à proximité
  ; Quelle importance des coupes dans la non régénération? Comment estimer leur impact?

  ask coupeurs with [attrape = FALSE][
    move-to one-of patches
    if any? pousses with [signalé = TRUE and age > age-p-interm] in-radius 10 [
      move-to one-of pousses with [signalé = TRUE and age > age-p-interm] in-radius 10
      set en-coupe TRUE ; potentiellement variable locale ici
    ]
  ]

end

to coupe-pousse

  ask coupeurs with [en-coupe = TRUE]
  [
    ask pousses-here [die]
    let _quel-champ [id-parcelle] of patch-here
    ask fields with [who = _quel-champ][set coupé coupé + 1]
    set nb-coupe nb-coupe + 1
    desengagement-coupes
  ]

  ask coupeurs with [attrape = TRUE][
    set jours-peur jours-peur + 1
    ifelse nb-attrape > nb-attrape-crit [ ; nb arbitraire
      if jours-peur > duree-peur-crit [ ; attend 1 an
        set attrape FALSE
        set jours-peur 0
      ]
    ][
      if jours-peur > duree-peur [ ; attend 1 mois
        set attrape FALSE
        set jours-peur 0
      ]
    ]
  ]

    ask coupeurs [set en-coupe FALSE]
end

to Régénération-NA

  if RNA [
    if ticks <= 1092 [
    if day-of-year > 310
    [protection-RNA ]
    ]

    if ticks > 1092 [
    if day-of-year > 310
    [protection-RNA ]

    nv-engagés-RNA
    ]
  ]

end

to protection-RNA ; ATTENTION DIFFICILE DE VOIR SI ELLE MARCHE COMME JE VEUX

  ; protection des jeunes pousses de SA parcelle. Les protège quand il est présent. la protection dépend donc de la présence.

  ; A partir d'un certains nombres de pousses protégées, il ne protège plus les nouvelles (nb potentiellement a faire varier)
  ; accélération de la croissance a faire dans une autres procédure.

  if RNA [
    ask agriculteurs with [engagé = TRUE][
      if id-agri = [id-parcelle] of patch-here [ ; si il est dans sa parcelle
        if any? pousses with [[id-parcelle] of patch-here =[id-agri] of myself][ ; si il y a des pousses dans sa parcelle
          let _nb-pousses-protégées count pousses with [[id-parcelle] of patch-here = [id-agri] of myself and signalé = TRUE]
          if _nb-pousses-protégées < nb-protG-max [ ; si il n'y a pas plus de XX (interface) pousses protégées dans sa parcelle
            if any? pousses with [[id-parcelle] of patch-here = [id-agri] of myself and signalé = FALSE][
              ask one-of pousses with [[id-parcelle] of patch-here = [id-agri] of myself and signalé = FALSE][
                set color red
                set signalé TRUE
              ]
            ]
          ]
        ]
      ]
    ]
  ]


end

to nv-engagés-RNA

  ; procédure d'accroissement du nombres d'engagés - selon des réunions, selon la réussite de certains protecteurs, selon des contre-parties à la protection?

  ; Réunion / projet etc.


  ifelse (jour-réu > -1 and jour-réu < 1) [
     let _reste-parti count agriculteurs with [engagé = FALSE]
    if _reste-parti >= participants [
    ask n-of participants agriculteurs with [engagé = FALSE][
      set interet-RNA interet-RNA + effet-reunion
      ]
    ]
    set jour-réu 364 / fréquence-réu
  ][
     set jour-réu jour-réu - 1
    ]

  ; diffusion par succès - oservation du champ

  ask agriculteurs with [engagé = FALSE][
    if [id-parcelle] of patch-here = id-agri [
    if any? fields in-radius 20 with [plus-arbres > arb-reussite][
      set interet-RNA interet-RNA + effet-reussite
      ]
    ]
  ]

  ; diffusion par discussions - en parler avec les voisins

  ask agriculteurs [
    if [id-parcelle] of patch-here = id-agri [
      ;;;
      let _proba random 100
      ifelse any? agriculteurs with [engagé  = TRUE and id-agri != [id-agri] of myself] in-radius 10 [
        ;;Si il y a des agriculteur engagé autour ET qui ne sont pas eux meme
        ifelse _proba < proba-discu [ ;; si la proba tiré au hasard est  inferieur a la valeur de gui
          ;; alors on augmenter
          set interet-RNA interet-RNA + effet-discussion
        ][
          ;; sinon on baisse
          set interet-RNA interet-RNA - effet-discussion + 0.5
        ]
      ][
        ;;; Si je n'ai pas de voisin engagé je ne peut pas discuter alors ça baisse
        set interet-RNA interet-RNA - effet-discussion + 0.5
      ]
    ]
  ]

  ask agriculteurs [
    if interet-RNA >= 20 [
      set engagé TRUE
    ]
    if interet-RNA <= 0 [
      set engagé FALSE
    ]

    if interet-RNA < 0 [
      set interet-RNA 0
    ]
  ]

end



to desengagement-coupes

  ask agriculteurs with [engagé = TRUE and id-agri = [id-parcelle] of patch-here]
  [ set interet-RNA interet-RNA - effet-coupe
    if interet-RNA <= 0 [
    set interet-RNA 0
    set engagé FALSE
    ]
  ]
end

to update-variables

  ; A l'issue des rotations les surfaces de chaque culture changent - monitorer ces variations fines.
  ; Le stock de fourrage perso des bergers est aussi à suivi chaque go/jour

  set total-mil-area count patches with [culture = "mil"] * patch-area
  set total-groundnuts-area count patches with [culture = "groundnuts"] * patch-area
  set total-jachère-area count patches with [culture = "jachère"] * patch-area
  set total-under-tree-area count patches with [under-tree = TRUE] * patch-area
  set stock-fourrage-moyen mean [stock-fourrage] of bergers
  set %-under-tree (total-under-tree-area / (count patches * patch-area)) * 100

  ; indicateurs
  set %-under-tree (total-under-tree-area / (count patches * patch-area)) * 100
  set nb-arbres count trees
  set age-moy-arb mean [age-tree] of trees
  set pouss count pousses
  set pouss-prot count pousses with [signalé = TRUE]
  set pouss-inter-prot count pousses with [age > age-p-interm]
  set MoyN-interet-RNA mean [interet-RNA] of agriculteurs
  set nb-engages count agriculteurs with [engagé = TRUE]
  set nb-arb-brousse count trees with [[champ-brousse] of patch-here = TRUE]
  set nb-arb-case count trees with [[champ-brousse] of patch-here = FALSE]
  set Moy-tps-chp mean [jour-champ] of agriculteurs
  if Max-tps-chp < Moy-tps-chp [
    set Max-tps-chp Moy-tps-chp
  ]
  set charrette-bois-année charrette-bois
  set sacMoyenMil mean [stock-mil] of agriculteurs
  set DelatMil sacMoyenMil - initStockMil
  set delat-Nb-arbres nb-arbres - init-nb-arbre

  ; coupeur-attrape
  ; nb-coupe

end

to update-time

  ; permet de suivre le calendrier: quel jour on est!

  if day-of-year > 364 [
    set day-of-year 0
    set year year + 1
    let _nb-agri count agriculteurs
   ask agriculteurs [
    set jour-champ 0
    ]
  ]
  if day-of-year = 2 [
    set charrette-bois 0
  ]


end

to update-graph

  if day-of-year = 1 [
;    set-current-plot "Volume de mil"
;  set-current-plot-pen "pen-0"
;  plotxy year stock-mil-p
    set-current-plot "Âge moyen du parc"
    ask trees [
      set-current-plot-pen "pen-0"
      plotxy year mean [age-tree] of trees
    ]
    set-current-plot "Stock de mil"
    set-current-plot-pen "pen-0"
    plotxy year stock-mil-g

    set-current-plot "Stock de sacs mil"
    ask agriculteurs [
      set-current-plot-pen "pen-0"
      plotxy year sacMoyenMil
    ]
    set-current-plot "bois"
    set-current-plot-pen "pen-0"
    plotxy year charrette-bois-année
  ]



end
@#$#@#$#@
GRAPHICS-WINDOW
220
10
628
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

MONITOR
640
140
720
177
arbres/ha
count trees / 100
17
1
9

MONITOR
155
60
205
97
%-mil
(total-mil-area / (count patches * patch-area)) * 100
1
1
9

MONITOR
640
95
765
140
%under-tree
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

PLOT
960
15
1160
180
nombre d'arbres 
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"pou" 1.0 0 -16777216 true "" "plot count trees with [size != 0.1]"
"nba" 1.0 0 -7500403 true "" "plot count trees "
"bro" 1.0 0 -2674135 true "" "plot nb-arb-brousse"
"pen-3" 1.0 0 -5825686 true "" "plot nb-arb-case"

PLOT
800
10
960
180
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
"pen-1" 1.0 0 -2674135 true "" ""

MONITOR
90
60
155
97
%-jachère 
(total-jachère-area / (count patches * patch-area)) * 100
1
1
9

MONITOR
20
60
90
97
%arachide
(total-groundnuts-area / (count patches * patch-area)) * 100
1
1
9

SWITCH
20
200
123
233
RNA
RNA
0
1
-1000

SLIDER
20
235
192
268
engagés-initiaux
engagés-initiaux
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
20
350
200
383
tps-au-champ
tps-au-champ
0
100
80.0
1
1
NIL
HORIZONTAL

PLOT
855
195
1055
345
pousses-protégées
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
"default" 1.0 0 -16777216 true "" "plot count pousses with [signalé = TRUE]"
"pen-1" 1.0 0 -7500403 true "" "plot count pousses with [age > age-p-interm]"
"pen-2" 1.0 0 -2674135 true "" "plot count pousses"

SLIDER
20
385
200
418
q-présence-brousse
q-présence-brousse
0
1
0.31
0.01
1
NIL
HORIZONTAL

PLOT
855
350
1055
500
Engagés RNA 
NIL
NIL
0.0
10.0
0.0
50.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "plot count agriculteurs with [engagé = TRUE]"

PLOT
1050
195
1250
345
Stock de mil
year
NIL
0.0
10.0
40000.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

PLOT
1250
345
1450
495
surface-sous-arbre
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
"default" 1.0 0 -16777216 true "" "plot %-under-tree"

SLIDER
235
440
407
473
fréquence-réu
fréquence-réu
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
235
475
407
508
participants
participants
0
100
22.0
1
1
NIL
HORIZONTAL

MONITOR
795
390
845
427
nb-agri
count agriculteurs
0
1
9

MONITOR
790
350
855
387
agri-engagés
count agriculteurs with [engagé = TRUE]
17
1
9

PLOT
1250
195
1450
345
coupeurs-attrapes 
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
"default" 1.0 0 -16777216 true "" "plot coupeurs-attrapes"
"pen-1" 1.0 0 -7500403 true "" "plot count coupeurs with [attrape = TRUE]"

TEXTBOX
235
425
385
443
Reunion RNA \n
12
0.0
1

PLOT
1050
345
1250
495
interet-moyen-RNA 
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
"default" 1.0 0 -16777216 true "" "plot mean [interet-RNA] of agriculteurs"

PLOT
1160
15
1320
180
nb-coupes
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
"default" 1.0 0 -5825686 true "" "plot nb-coupe"

SLIDER
635
220
807
253
nb-surveillants
nb-surveillants
0
20
8.0
1
1
NIL
HORIZONTAL

SLIDER
635
255
812
288
nb-champs-visités
nb-champs-visités
0
80
5.0
1
1
NIL
HORIZONTAL

SWITCH
635
185
740
218
S-repreZ
S-repreZ
0
1
-1000

SWITCH
125
315
215
348
S-pop
S-pop
1
1
-1000

SWITCH
635
290
782
323
coordination
coordination
0
1
-1000

INPUTBOX
25
115
95
175
nombre-bergers
5.0
1
0
Number

INPUTBOX
105
115
170
175
nb-coupeurs
10.0
1
0
Number

INPUTBOX
20
275
100
335
nb-proTG-max
35.0
1
0
Number

INPUTBOX
20
430
110
490
proba-discu
80.0
1
0
Number

INPUTBOX
120
430
215
490
proba-denonce
60.0
1
0
Number

BUTTON
465
435
532
468
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
460
470
523
503
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

PLOT
1310
25
1510
175
Stock de sacs mil
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

PLOT
625
385
785
505
bois
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

Ce modèle simule l'évolution de l'état du parc arboré dans le temps, compte tenu des pressions, usages, et modee de gestion gravitant autour de l'arbre. 

## HOW IT WORKS

L'espace représenté est de 100ha. Dans cette espace un village et des faidherbias, dont la densité locale a été déterminée grâce à des travaux de télédétection (Leroux et al), des champs, de case (proche du village) et de brousse, dont la culture change d'une année à l'autre. Les différentes procédures sont temporellement définies et s'activent en fonction du calendrier.

**Avec les push du 23 juin**
- Quand on pousse proba denonce de 20 à 60 sur 20 ans on augmente un peut le nombre d'arbre.
- Quand on pousse la proba discute de 20 40 a 60, au augmente le nombre d'engager en RNA et donc la prtection des arbres. A 20 c'est très ocillant.A 80 c'est radical, le nombre d'arbre a largement augmenter et le territoire est dans une dynamique positive
- temps au champ  de 20 40 et 60 ne semble pas avoir beaucoup d'influence sur le nombre d'arbre ... peut être quelque chose a voir sur la sociabilité et donc le recrutement d'engagé dans la RNA ? 
- q-presence brouse de 0.20 0.40 et 0.60 à l'aire d'avance dans le meme sens que le temps au champs. Plus al valeur est haute plus le nombre d'arbre est important 

Il y a vraiment quelque chose a faire avec un indice de fragmenation spatiale . La config temps en brouse 40, proba discu et proba denonce à 60 produit des formes spatiale qui ressemble bien a des parcelles. 

Comme les arbres sont des point il peut y avoir des arbres assez proches dans l'esapce ce qui augmente le nombre d'arbre a l'hectard sans accroitre la surface sous arbre. 

## TODO

Définir un stock de Neem au village, pour retarder l'étêtage des Faidherbia - fait mais prolème de la remise à jour des stocks (combien de temps pour qu"un Neem se régénère?). Pour l'instant nombre fixe tous les ans (2 par agriculteurs // nb de Neem dans les concessions) - le modif en réduisant la fréquence de coupe 

Les stocks de mil en sac doivent être exprimées - 
- comment résoudre le pb d'ha/agri? le même pour ts les agri? 
- exprimer le stock de mil en nb/sac/ha 

finir les conversions d'unité / calibration après l'atelier 

stock de bois lié à la coupe des kadd par les bergers (stock variable selon l'âge de l'arbre et à la dernière coupe) => le problème est que le stock de bois ne dépend pas du nb de kadd. Indicateur peu pertinent donc. potentiellement faire une procédure: a partir d'un certain nb d'arbre sur sa parcelle - les agriculteurs peuvent en couper. 

liste de recalibration en fonction de l'échelle 

grouper les agriculteurs en concession: 
- stock de mil par concession 
- stock de bois 
- stock de paille? 


## HOW TO USE IT

Le modèle 
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
<experiments>
  <experiment name="Essai-réaliste" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10192"/>
    <metric>%-under-tree</metric>
    <metric>coupeurs-attrapes</metric>
    <metric>age-moy-arb</metric>
    <metric>nb-arbres</metric>
    <metric>pouss</metric>
    <metric>pouss-prot</metric>
    <metric>pouss-inter-prot</metric>
    <metric>MoyN-interet-RNA</metric>
    <metric>nb-engages</metric>
    <metric>stock-mil-g</metric>
    <enumeratedValueSet variable="engagés-initiaux">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nombre-bergers">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proba-denonce">
      <value value="10"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proba-discu">
      <value value="10"/>
      <value value="40"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fréquence-réu">
      <value value="1"/>
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="q-présence-brousse">
      <value value="0.1"/>
      <value value="0.3"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-proTG-max">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-coupeurs">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RNA">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="participants">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tps-au-champ">
      <value value="10"/>
      <value value="30"/>
      <value value="60"/>
      <value value="99"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="eval_replication" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10192"/>
    <metric>%-under-tree</metric>
    <metric>coupeurs-attrapes</metric>
    <metric>age-moy-arb</metric>
    <metric>nb-arbres</metric>
    <metric>pouss</metric>
    <metric>pouss-prot</metric>
    <metric>pouss-inter-prot</metric>
    <metric>MoyN-interet-RNA</metric>
    <metric>nb-engages</metric>
    <metric>stock-mil-g</metric>
    <enumeratedValueSet variable="engagés-initiaux">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proba-denonce">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nombre-bergers">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proba-discu">
      <value value="81"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fréquence-réu">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="q-présence-brousse">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-proTG-max">
      <value value="26"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-coupeurs">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RNA">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tps-au-champ">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="participants">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Essai-15/06" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="8280"/>
    <metric>%-under-tree</metric>
    <metric>coupeurs-attrapes</metric>
    <metric>age-moy-arb</metric>
    <metric>nb-arbres</metric>
    <metric>nb-arb-brousse</metric>
    <metric>nb-arb-case</metric>
    <metric>pouss</metric>
    <metric>pouss-prot</metric>
    <metric>pouss-inter-prot</metric>
    <metric>MoyN-interet-RNA</metric>
    <metric>nb-engages</metric>
    <metric>stock-mil-g</metric>
    <metric>Moy-tps-chp</metric>
    <metric>Max-tps-chp</metric>
    <enumeratedValueSet variable="engagés-initiaux">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nombre-bergers">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proba-discu">
      <value value="20"/>
      <value value="50"/>
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-pop">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RNA">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proba-denonce">
      <value value="20"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fréquence-réu">
      <value value="1"/>
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="q-présence-brousse">
      <value value="0.02"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-proTG-max">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-coupeurs">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tps-au-champ">
      <value value="20"/>
      <value value="50"/>
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="participants">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
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
