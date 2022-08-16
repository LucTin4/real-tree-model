library(tidyverse)
rm(list = ls())


setwd("~/github/real-tree-model/data/")
pse.df <- read.csv("results_pse/population9750.csv", header = T)

ggplot(data = pse.df)+
  geom_point(aes(x = objective.om_stockMil, y = objective.om_charette, size = evolution.samples ))+
  labs(title = "Pattern Space Exploration",
       x = "Prod. de mil", 
       y = "Prod. bois de chauffe")+
  theme_bw()

ggsave("../img/om_pse.png", width = 8)

# columns_to_remove <- grep(".1", names(pse.df))
# pse.df <- pse.df[,-columns_to_remove]

# pse.df <- read.table(path_right, sep = ",",header = TRUE)
# pse.df$id <- seq.int(nrow(pse.df))
# 
# 
# 
# pse.df_selected <- pse.df %>% 
#   mutate(clean_deltaMil = str_replace_all(pse.df$objective.om_delatMil, "[\\[\\]]", "")) %>%
#   mutate(clean_om_trees = str_replace_all(pse.df$objective.om_trees, "[\\[\\]]", "")) %>%
#   mutate(clean_om_charette = str_replace_all(pse.df$om_charette, "[\\[\\]]", "")) %>%
#   mutate(clean_caughhtC = str_replace_all(pse.df$om_caughtCutter, "[\\[\\]]", "")) %>%
#   select(-objective.om_delatMil, -objective.om_trees, -om_charette,-om_caughtCutter) %>% 
#   separate_rows(c(clean_deltaMil,clean_om_trees,clean_om_charette,clean_caughhtC), sep = ',', convert = TRUE ) %>%  
#   group_by(id) %>%
#   mutate(step=row_number()) %>%
#   gather(param,value,clean_deltaMil,clean_om_trees,clean_om_charette,clean_caughhtC) %>%
#   mutate(exp="right")


pse.df_selected <- pse.df_selected[,-c(1:28)]
