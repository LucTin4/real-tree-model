## ce script a pour objectif d'aide a l'analyse des résultat des simulations lancé par Lucas 
## sur son mondel 'M0-tree-model3-régénération_wa_moran' lancé sur le calculateur de l'UMMISCO
## date : 05-08-2022
## Projet DSCATT
## auteur : E. Delay

require(data.table)
require(ggplot2)
require(patchwork)
require(dplyr)
library(stringr)
library(reshape2)

rm(list = ls())

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

path <- "../data/exploration1/"
l.files <- list.files(path)

data.df <- data.frame()
for(i in 1:length(l.files)){
  tmp <- fread(paste0(path, l.files[i]), skip = 6)
  data.df <- rbind(data.df, tmp)
}

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
write.table(median.df,"/tmp/median_simu.csv", row.names = F)


## On peut aussi faire des boxplot avec les valeurs des 20 replications

ggplot(data = data.df)+
  geom_boxplot(aes(x = as.factor(proba.discu), y = nb.arbres))+
  labs(x = "probabilité de discussion", "nombre d'arbres")+
  facet_grid(fréquence.réu~tps.au.champ, labeller = label_both)+
  theme_bw()
ggsave("../img/boxplot_discussion_freq_tps_champs.png", width = 8)

ggplot(data = data.df)+
  geom_boxplot(aes(x = as.factor(fréquence.réu), y = nb.arbres))+
  labs(x = "fréquance des réunions", "nombre d'arbres")+
  facet_grid(proba.discu~tps.au.champ, labeller = label_both)+
  theme_bw()
ggsave("../img/boxplot_freq_proba_discu_tps_champs.png", width = 8)

ggplot(data = data.df)+
  geom_boxplot(aes(x = as.factor(tps.au.champ), y = nb.arbres))+
  labs(x = "Temps passé au champs", "nombre d'arbres")+
  facet_grid(fréquence.réu~proba.discu, labeller = label_both)+
  theme_bw()
ggsave("../img/boxplot_tps_champs_freq_discu.png", width = 8)

###########################################################################################
## Exploration n°2 dans laquel on introduit des surveillant délégué
###########################################################################################

data2.df <- fread("../data/exploration2/Exploration2-sp-130820222135.csv", skip = 6)
colnames(data2.df)[17] <- "pct-under-tree"
colnames(data2.df)[1] <- "run.number"
colnames(data2.df) <- str_replace_all(colnames(data2.df),"-", ".")


## on va s'intéresser d'abord a des frequ de réunion faible
sel <- data2.df$fréquence.réu == 2

fr2 <- ggplot(data = data2.df[sel,])+
  geom_boxplot(aes(x = as.factor(nb.surveillants), y = nb.arbres))+
  scale_y_continuous(limits = c(0, 4000))+
  labs(x = "nb de surveillant", y = "nombre d'arbres", subtitle = "Fréquence des réunions : 2 par ans")+
  facet_grid(proba.discu~tps.au.champ, labeller = label_both)+
  theme_bw()
fr2

sel <- data2.df$fréquence.réu == 8

fr8 <- ggplot(data = data2.df[sel,])+
  geom_boxplot(aes(x = as.factor(nb.surveillants), y = nb.arbres))+
  scale_y_continuous(limits = c(0, 4000))+
  labs(x = "nb de surveillant", y = "nombre d'arbres", subtitle = "Fréquence des réunions : 8 par ans")+
  facet_grid(proba.discu~tps.au.champ, labeller = label_both)+
  theme_bw()
fr8

fr2 + fr8

ggsave("../img/exp2_boxplot_nSurveillant_discussion_tps_champs.png", width = 10)



