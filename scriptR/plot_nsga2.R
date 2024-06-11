# Script pour analyser les résultats d'un algorithme génétique NSGA2
# Auteur : Etienne Delay
# Date : 11 juin 2024

# Ce script lit un fichier CSV produit par un algorithme génétique NSGA2
# qui cherche à maximiser le nombre de charrettes de bois sorties du territoire 
# et le nombre de mil produit. Le script calcule ensuite la médiane des valeurs 
# d'une colonne donnée et génère un graphique montrant l'évolution des objectifs.

# Charger la bibliothèque nécessaire
library(ggplot2)

# Définir le répertoire de travail
setwd("~/github/real-tree-model/data/results_nsga2/")

# Fonction pour parser une chaîne de caractères en un vecteur numérique et calculer la médiane
om_parseur <- function(string) {
  # Enlever les crochets
  string <- gsub("\\[|\\]", "", string)
  # Convertir la chaîne de caractères en vecteur numérique
  numbers <- as.numeric(unlist(strsplit(string, ",")))
  # Calculer la médiane
  median_value <- median(numbers)
  # Retourner la médiane
  return(median_value)
}

# Lire le fichier CSV
data.df <- read.csv("population6400.csv", header = TRUE)

# Inverser les valeurs des deux objectifs pour les maximiser
data.df$objective.om_stockMil <- data.df$objective.om_stockMil * -1
data.df$objective.om_charette <- data.df$objective.om_charette * -1 

# Appliquer la fonction om_parseur à toute la colonne 'om_trees'
data.df$om_trees_med <- sapply(data.df$om_trees, om_parseur)

# Créer un graphique avec ggplot2
ggplot(data = data.df) +
  geom_point(aes(x = objective.om_stockMil, y = objective.om_charette, colour = om_trees_med)) +
  geom_vline(xintercept = 54600, linetype = "dashed", color = "black") + # Ajouter une ligne verticale
  geom_hline(yintercept = 56, linetype = "dashed", color = "black") +  # Ajouter une ligne horizontale
  labs(x = "Millet prod.", y = "Firewood prod.", 
       title = "NSGA2 - Evolution of the double objective optimum", subtitle = "30 years of simulations", 
       colour = "median nb trees\nat end of simulation") +
  theme_bw()


