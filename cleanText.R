library(pdftools)

setwd("/Users/becca/Documents/these/RLinguistics/mycorpus/pdf/")
file_list <- list.files(path="/Users/becca/Documents/these/RLinguistics/mycorpus/pdf/"); file_list
for(file in file_list) {
  # convert pdf to txt
  txt <- pdf_text(file)
  for (i in 1:length(txt)) {
    # extract page numbers
    # 1-10
    if (endsWith(txt[i], regex([:digit:])) {
      txt[i] <- substr(txt[i], 1, nchar(txt[i])-2)
    }
  }
  write.table(txt, "elodie.txt", sep="\t", row.names = F, col.names = F)
}

