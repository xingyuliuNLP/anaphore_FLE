setwd("/Users/becca/Documents/these/RLinguistics/mycorpus")
df <- read.csv('result.txt', sep = '\t', encoding = "UTF-8")
type_code <- ""
n_rows <- nrow(df)
file_list <- list("01","02")
simp_list <- list("cela","ceci","ce","cet","cette","ces")
compl_list <- list("ce qui", "dont", "ce dernier", "cette dernière", "ces derniers", "ces dernières")
for(i in 1:n_rows) {
  for(f in file_list){
    if (substring(df$docname[i],1,2) == f){
      type_code1 <- paste(type_code, "ch", f, sep = "")
    }
    for(s in simp_list) {
      if (df$keyword[i] == s) {
        type_code2 <- paste(type_code1, "s", sep = "")
      } 
    }
    for(c in compl_list) {
      if (df$keyword[i] == c) {
        type_code2 <- paste(type_code1, "c", sep = "")
      } 
    }
    type_code3 <- paste(type_code2, "SUJ", sep = "")
    df$type[i] <- type_code3
  }
}

df_new <- write.table(df, "result_new.txt", sep = "\t", row.names = F )
