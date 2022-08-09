## ce script a pour objectif d'aide a l'analyse des résultat des simulations lancé par Lucas 
## sur son mondel 'M0-tree-model3-régénération_wa_moran' lancé sur le calculateur de l'UMMISCO
## date : 05-08-2022
## Projet DSCATT
## auteur : E. Delay

require(data.table)
require(ggplot2)
require(dplyr)
library(stringr)

rm(list = ls())

data.df <- fread("~/Documents/CIRAD/2022/2_DSCATT_Dynamic_carbon/Stages/lucas/Exploration1-sp-050820221251.csv", skip = 6)
colnames(data.df)[17] <- "pct-under-tree"
colnames(data.df)[1] <- "run.number"
colnames(data.df) <- str_replace_all(colnames(data.df),"-", ".")


## Cette fonction va calculer la median de chaque groupe de simualtion
## le résultat de sortie est donc une seul ligne qui représente la mediane
## des resutat groupé par la fonction group_by (c.a.d ici 4 valeurs)
median.df <- data.df %>%
  group_by(proba.discu, proba.denonce, fréquence.réu, q.présence.brousse, tps.au.champ) %>%
  summarise(nbSimu = length(run.number), 
            pct.under.tree = median(pct.under.tree),
            coupeurs.attrapes = median(coupeurs.attrapes),
            age.moy.arb = median(age.moy.arb),
            nb.arbres = median(nb.arbres),
            init.nb.arbre = median(init.nb.arbre),
            delat.Nb.arbres = median(delat.Nb.arbres),
            pouss = median(pouss),
            pouss.prot = median(pouss.prot),
            pouss.inter.prot = median(pouss.inter.prot),
            MoyN.interet.RNA = median(MoyN.interet.RNA),
            nb.engages = median(nb.engages)
            
)


