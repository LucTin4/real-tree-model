

1. # Purpose and patterns

Le bassin arachidier fait face à une perte de fertilité des sols. L'amendement chimiques est indisponible sur la zone ou inaccessible d’un point de vue économique pour les agriculteurs. La fertilité des sols repose donc sur deux aspects : la présence de bétail sur le territoire pour maintenir une fumure à l'année, et les Faedherbias albida qui joue un rôle fondamental dans les cycles de cultures. En effet, ceux-ci ont la particularité de perdre leurs feuilles pendant la saison de culture et de fixer l’azote de l’aire dans les sols.  

Le modèle cherche donc à évaluer et explorer des solutions de gestion du parc à Faidherbia amenant à leur densification ? Le modèle se focalise sur  l’exploration d’initiatives dite communautaire, sont considérées. 

2. # Entities, state variables, and scales
    

  

L’espace simulé, à travers lequel les agents interagissent,  représente 100 hectares. Il est composé de 1000 entités spatiales (patches) ayant une taille de 10m2 (résolution). Il est exclusivement agricole puisque l’espace habité du village est condensé en un point.( Les zones qui ne sont pas cultivées, zone humide, parcours, sont rares et n’ont pas été représentées.) 

Le pas de temps irréductible est le jour (tick). Les différents éléments du système (interactions etc.) prennent en compte la saisonnalité qui structure les activités agricoles. A chaque 364 jours, une nouvelle année commence et le rythme des saisons continue. On peut considérer une seconde unité temporelle  : l’année, qui est constituée de saisons. Les simulations sont généralement faites sur 23 ans. En début de simulation, on considère que les 3 premières années servent à initialiser le modèle . 

Les entités du modèle sont relativement nombreuses: certaines sont statiques (arbres, parcelles et village), d’autres en mouvement ( bergers, agriculteurs, coupeurs et surveillants). La description détaillée des agents et de leurs variables d’état est faite dans la figure X. 

  

3. # Process overview and scheduling
    

  

Il est possible de décomposer le modèle en plusieurs sous-modèles: 

Le modèle se décompose en sous modèles qui sont organisés et ordonnancés de la manière suivante. 

A l’initialisation on génère l’environnement 

- Génération des parcelles et des cultures 
    
- Génération des arbres et leurs effets fertilisants
    
- Génération des agents humains: bergers, coupeurs, agriculteurs, surveillants 
    
- Génération du village 
    

Toutes les procédures suivantes sont répétées à chaque pas de temps:

La récolte et l’orientation des cultures 

- Récolte et constitution des stocks 
    
- Effet des machines sur les pousses non protégées 
    
- Rotation des cultures 
    

Croissance des arbres et leur reproduction

- Rejets 
    
- Croissance des pousses 
    
- Vieillissement et mort des arbres
    

Alimentation du bétail et utilisation fourragère des acacias 

- Alimentation des troupeaux avec la paille 
    
- Coupe des arbres 
    
- Troupeaux dans la jachère et la coupe des pousses 
    

  

Coupe des pousses par les coupeurs 

- repérage des pousses 
    
- la coupe des pousses 
    

  

Engagement des agriculteurs 

- Participation aux réunions 
    
- Constatation de la réussite des voisins 
    
- interaction sociale et motivation 
    
- Protection des pousses 
    

  

Surveillance 

- surveillance et présence aux champs des agriculteurs (surveillance communautaire généralisée) 
    
- surveillance communautaire délégués 
    

4. # Design concepts
    

  

L’intérêt des modèles SMA est d’analyser l’émergence de certains comportements globaux. Dans ce modèle l’émergence est dite “faible” puisque les comportements globaux émergents n’ont pas d’effet c'est-à-dire, ne sont pas perçus en retour par les agents. 

La densité du parc, le nombre d'arbres et leurs répartition spatiale, constitue le résultat émergent central du modèle. Des résultats émergents intermédiaires peuvent être identifiés: le nombre d’agriculteurs engagés en RNA, le nombre de coupes et de coupeurs attrapés… Enfin des résultats émergents, liés à celui des arbres, peuvent être évoqués: le stock de mil par exemple, l’âge du parc. 

Adaptation.

 Deux agents ont des comportements adaptatifs/changeants: les coupeurs et les agriculteurs. La réaction des coupeurs au fait qu’ils soient surpris par un protecteur de pousse, diffère selon le nombre de fois où ils ont été précédemment surpris. Les agriculteurs ont un score décrivant l’intérêt qu’ils portent à la protection des arbres. Ce score évolue constamment selon plusieurs règles: la rencontre avec un autre agriculteur engagé, la constatation de la réussite du système de protection d’un voisin, la participation à des réunions etc. 

Objectives. 

Learning. 

Prediction. 

Sensing. 

Interaction. 

L’interaction entre agent est direct 

Les coupeurs sont en interaction directe avec les pousses puisqu’ils les tuent, pareil pour les bergers avec les arbres. Les agriculteurs ou surveillants interagissent également directement avec les coupeurs en les stoppant. Les agriculteur détruisent les jeunes pousse qui ne sont pas protégées

Stochasticity.

Beaucoup d’événements du modèle reposent sur un hasard partiel puisqu’ils sont probabilistes. 

La probabilité est souvent utilisée en tant que fréquence C’est le cas pour les déplacements des agriculteurs dans leur champs et la probabilité que les agriculteurs discutent entre eux de la RNA. 

Le hasard partiel est utilisé en tant qu’incertitude notamment celle sur le fait que les surveillants surprennent les coupeurs. Puisqu’ils ne passent pas l’intégralité de la journée dans un même champ, ils peuvent visiter un champ sans y surprendre le coupeur. 

Enfin le hasard est utilisé pour créer de la variabilité dans les variables initiales. C’est le cas pour le nombre de tête des différents troupeaux, qui sont ainsi plus ou moins gros et pour l’âge initial de chaque arbre, qui sont alors plus ou moins vieux. 

(hasard lors des rejets - position)  

Collectives. 

Des formes collectives émergent avec l’engagement des agriculteurs dans la protection des pousses. Plus le groupe d'engagés est vaste, plus le ralliement est probable et plus sa pérennité du groupe est assurée. 

Observation.

5. # Initialization
    

  

Il s’agit de décrire ici l’état initial du modèle. 

- village: 1 
    
- arbres: 535 soit une densité de 5.35 arbres/ha 
    
- parcelles en culture: entre 90 et 100 en fonction de la génération 
    
- agriculteurs: en nombre équivalent à celui des parcelles. 9 d’entre eux sont déjà engagés dans la protection des pousses  
    
- Coupeurs: le nombre de coupeurs peut être modulé. On a fait tourner nos simulation avec 10 coupeurs 
    
- bergers: 5
    
- surveillants: le nombre de surveillants peut être modulé. 
    

6. # Input data
    

  

1. # Submodels