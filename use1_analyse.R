# install packages quanteda and readtext
install.packages("quanteda")
install.packages("readtext")
# load packages
library(quanteda)
library(readtext)
library(stringi)
library(stringr)
# set working directory
setwd("/Users/becca/Documents/these/RLinguistics/mycorpus")

# create a list of the files to be analysed
file_list <- list.files(path="/Users/becca/Documents/these/RLinguistics/mycorpus"); file_list


# execute same procedures for all papers
for(file in file_list) {
  rm_index <- vector()
  # get texts in paper
  data_ch <- texts(readtext(file)); data_ch
  # lowercase all texts
  data_ch_lower <- char_tolower(data_ch); data_ch_lower
  # extract the main content of papers from start point, "résumé"; to end point, "bibliographie"
  (start_v <- stri_locate_first_fixed(data_ch_lower, "introduction")[1])
  (end_v <- stri_locate_last_fixed(data_ch_lower, "bibliographie")[1])
  data_ch_final <- stri_sub(data_ch_lower, start_v, end_v)
  # set data's name by file name without extension
  names(data_ch_final) <- file_path_sans_ext(file)
  # set patterns we want to search
  # avec quoi, sans quoi, faute de quoi, avec lequel, de quoi, a base de quoi, duquel, auquel, a qui, "ce que", "ce dont","le","la","les"
  # POS: sujet
  pattern_list <- c("ce dernier","cette dernière","ces dernières","ces derniers","ce qui","tel","cela","ceci", "celui-ci","celle-ci","ceux-ci","celles-ci","dont","ce","cet","cette","ces")
  for(p in pattern_list) {
    # return a list of a keyword supplied by the user in its immediate context
    anaphore_kwic <- kwic(data_ch_final, pattern = phrase(p), window = 30)
    write.table(anaphore_kwic, "concordance.txt", append = T, sep="\t", row.names = F, col.names = F)
    n_rows <- nrow(anaphore_kwic)
    for(i in 1:n_rows) {
      fol_words <- c("qui","dernier","dernière","derniers", "dernières")
      check_words <- c("ce","cette","ces")
      # mark this item if "ce" is followed by "qui" or "dernier"
      for(w1 in check_words) {
        if(p == w1) {
          for (w2 in fol_words) {
            if(unlist(strsplit(anaphore_kwic$post[i], " "))[1] == w2) {
              # anaphore_kwic <- anaphore_kwic[-i,]
              rm_index <- c(rm_index, i)
          }
          }
        }
      }
    }
  }
  # remove
  # anaphore_kwic_final <- anaphore_kwic[-rm_index,]
  # store these concordance in a txt file
  result_pre <- read.table("concordance.txt")
  result <- result_pre[-rm_index,]
}

write.table(result, "result.txt", sep="\t", row.names = F, col.names = F)

   