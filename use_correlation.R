library("ggpubr")
corr_data <- read.delim("/Users/becca/Documents/these/RLinguistics/correlation.txt")


setwd("/Users/becca/Documents/these/RLinguistics/")
ggscatter(corr_data, x = "anaphoreFreq", y = "TTR",
          add = "reg.line", conf.int = TRUE,
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "fréquence d'anaphores", ylab = "Type-Token Ratio (TTR)")

# ggscatter(corr_data, x = "anaphoreFreq", y = "longueurDePhrase", 
#           add = "reg.line", conf.int = TRUE, 
#           cor.coef = TRUE, cor.method = "pearson",
#           xlab = "fréquence d'anaphores", ylab = "Longueur de phrase")

res <- cor.test(corr_data$anaphoreCFreq, corr_data$TTR, 
                method = "pearson")
res