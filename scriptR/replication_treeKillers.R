# Ce script permet de visualiser avec des boxplots le nombre d'arbres coupés par type d'agent
# dans le modèle NetLogo. Les types d'agents sont "herders", "cutters" et "farmers".
# Les données proviennent d'un fichier CSV et sont transformées pour la visualisation.

# Nettoyer l'environnement de travail
rm(list = ls())

# Charger les bibliothèques nécessaires
library(tidyverse)
library(reshape2)

# Définir le répertoire de travail (à ajuster selon votre structure de répertoires)
setwd("~/github/real-tree-model/data/")

# Lire les données depuis le fichier CSV en sautant les 6 premières lignes
data.df <- read.csv("results_bs/M2-SAFIRe_model replication_treeKillers-table.csv", skip = 6)
data.df <- data.df[data.df$tps.au.champ == 30,]

# Sélectionner uniquement les colonnes d'intérêt pour l'analyse
small <- subset(data.df, select = c("nbTreekilled_hearder", "nbTreekilled_cutter", "nbTreekilled_grower"))

# Transformer les données de format large à long pour faciliter la création des boxplots
small.m <- melt(small)

# Renommer les niveaux pour correspondre aux types d'agents
levels(small.m$variable) <- c("herders", "cutters", "farmers")

# Convertir la colonne variable en facteur
small.m$variable <- as.factor(small.m$variable)

# Créer et afficher les boxplots
ggplot(data = small.m) +
  geom_boxplot(aes(x = variable, y = value)) +
  theme_bw() +
  labs(x = "", y = "nb. of\ncutted trees", title = "Number of trees cut down by agent category", subtitle = "Over 25 years of simulated and 30 replications")
ggsave("../papier/usage/img/rep_treeKilled.png", width = 6)
