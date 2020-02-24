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
  # get texts in paper
  data_ch <- texts(readtext(file)); data_ch
  # lowercase all texts
  data_ch_lower <- char_tolower(data_ch); data_ch_lower
  # extract the main content of papers from start point, "résumé"; to end point, "bibliographie"
  (start_v <- stri_locate_first_fixed(data_ch_lower, "résumé")[1])
  (end_v <- stri_locate_last_fixed(data_ch_lower, "bibliographie")[1])
  data_ch_final <- stri_sub(data_ch_lower, start_v, end_v)
  full_text <-
    corpus(data_ch_final)
    # corpus_segment(pattern = "CHAPTER\\s\\d+.*\\n", valuetype = "regex")
  # dfm function convert text into dfm format and removes punctuation and makes the text all lowercase
  type_token_ration <-
    dfm(full_text) %>% 
    textstat_lexdiv(measure = "TTR")
  print(ntoken(data_ch_final))
  print(type_token_ration) 
  
}  
  