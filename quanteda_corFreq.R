# quanteda 比r vanilla好用的地方：
# 1. stri_locate_first_fixed()和stri_sub() 找开始结束位置，截取正文
# 2. textstat_frequency() 找top10 words
# 3. topfeatures() instead of sort()
# install packages quanteda and readtext
install.packages("quanteda")
install.packages("readtext")
# load packages
library(quanteda)
library(readtext)

data_char_mobydick <- texts(readtext("http://www.gutenberg.org/cache/epub/2701/pg2701.txt"))
names(data_char_mobydick) <- "Moby Dick"
library(stringi)
# stri_sub() function from the stringi package
stri_sub(data_char_mobydick, 1, 75)
# extract the header information
(start_v <- stri_locate_first_fixed(data_char_mobydick, "CHAPTER 1. Loomings.")[1])
start_v
(end_v <- stri_locate_last_fixed(data_char_mobydick, "orphan.")[1])
# verify that "orphan" is the end of the novel
kwic(data_char_mobydick, "orphan")
stri_sub(data_char_mobydick, from = start_v, to = end_v) %>%
  stri_count_fixed("\n")
novel_v <- stri_sub(data_char_mobydick, start_v, end_v)
# %>% pass the left hand side of the operator to the first argument of the right hand side of the operator
# equals to cat(stri_sub(novel_v, 1, 94))
stri_sub(novel_v, 1, 94) %>% cat()
# quanteda’s *_tolower() functions work like the built-in tolower(), with an extra option to preserve upper-case acronyms when detected. For character objects, we use char_tolower()
# lowercase text
novel_lower_v <- char_tolower(novel_v)
moby_word_v <- tokens(novel_lower_v, remove_punct = TRUE) %>% as.character()
(total_length <- length(moby_word_v))
moby_word_v[c(4,5,6)]
# check positions of "whale"
which(moby_word_v == "whale") %>% head()
# total occurrences of "whale" including possessive
length(moby_word_v[which(moby_word_v == "whale")]) + length(moby_word_v[which(moby_word_v == "whale's")])
# same thing using kwic()
nrow(kwic(novel_lower_v, pattern = "whale"))
nrow(kwic(novel_lower_v, pattern = "whale*")) # includes words like "whalemen"
(total_whale_hits <- nrow(kwic(novel_lower_v, pattern = "^whale('s){0,1}$", valuetype = "regex")))
total_whale_hits / ntoken(novel_lower_v, remove_punct = TRUE) 
# total unique words
length(unique(moby_word_v))
# type = unique tokens
ntype(char_tolower(novel_v), remove_punct = TRUE)
# To quickly sort the word types by their frequency, we can use the dfm() command to create a matrix of counts of each word type 
# ten most frequent words dfm document-feature matrix
moby_dfm <- dfm(novel_lower_v, remove_punct = TRUE)
head(moby_dfm, nf = 10)      
textstat_frequency(moby_dfm, n = 10) 

# plot frequency of 50 most frequent terms 
library(ggplot2)
theme_set(theme_minimal())
textstat_frequency(moby_dfm, n = 50) %>% 
  ggplot(aes(x = rank, y = frequency)) +
  geom_point() +
  labs(x = "Frequency rank", y = "Term frequency")

# moby_dfm是一个matrix object
# nfeat() get the number of features in an object
# 降序排列moby_dfm
sorted_moby_freqs_t <- topfeatures(moby_dfm, n = nfeat(moby_dfm))
# frequencies of "he" and "she" - these are matrixes, not numerics
sorted_moby_freqs_t[c("he", "she", "him", "her")]
#   he  she  him  her 
# 1758  112 1058  330
# another method: indexing the dfm
moby_dfm[, c("he", "she", "him", "her")]
ntoken(moby_dfm)


# Relative term frequencies:
#################
#按词频降序排列##
#################
sorted_moby_rel_freqs_t <- sorted_moby_freqs_t / sum(sorted_moby_freqs_t) * 100
sorted_moby_rel_freqs_t["to"]

# by weighting the dfm directly
# dfm_weight Weight the feature frequencies in a dfm
# scheme: a label of the weight type:
# prop: the proportion of the feature counts of total feature counts (aka relative frequency)
moby_dfm_pct <- dfm_weight(moby_dfm, scheme = "prop") * 100

dfm_select(moby_dfm_pct, pattern = "the")
                        
 ##################
# top10words作图###
###################

plot(sorted_moby_rel_freqs_t[1:10], type = "b",
     xlab = "Top Ten Words", ylab = "Percentage of Full Text", xaxt = "n")
axis(1,1:10, labels = names(sorted_moby_rel_freqs_t[1:10]))

textstat_frequency(moby_dfm_pct, n = 10) %>% 
  ggplot(aes(x = reorder(feature, -rank), y = frequency)) +
  geom_bar(stat = "identity") + coord_flip() + 
  labs(x = "", y = "Term Frequency as a Percentage")


# token distribution

# using words from tokenized corpus for dispersion
textplot_xray(kwic(novel_v, pattern = "whale")) + 
    ggtitle("Lexical dispersion")

# produce multiple dispersion plots for comparison
textplot_xray(
    kwic(novel_v, pattern = "whale"),
    kwic(novel_v, pattern = "Ahab")) + 
    ggtitle("Lexical dispersion")

# identify the chapter break locations
chap_positions_v <- kwic(novel_v, phrase(c("CHAPTER \\d")), valuetype = "regex")$from
head(chap_positions_v)
chapters_corp <- 
    corpus(data_char_mobydick) %>%
    corpus_segment(pattern = "CHAPTER\\s\\d+.*\\n", valuetype = "regex")
summary(chapters_corp, 10)
# docvars: Get or set variables associated with a document in a corpus, tokens or dfm object
# The titles are automatically extracted into the pattern document variables, and the text of each chapter becomes the text of each new document unit. 
docvars(chapters_corp, "pattern") <- stringi::stri_trim_right(docvars(chapters_corp, "pattern"))
summary(chapters_corp, n = 3)     
 
# rename
docnames(chapters_corp) <- docvars(chapters_corp, "pattern")


# barplot

# create a dfm
chap_dfm <- dfm(chapters_corp)

# extract row with count for "whale"/"ahab" in each chapter
# and convert to data frame for plotting
whales_ahabs_df <- chap_dfm %>% 
    dfm_keep(pattern = c("whale", "ahab")) %>% 
    convert(to = "data.frame")
    
whales_ahabs_df$chapter <- 1:nrow(whales_ahabs_df)

# aes: Construct Aesthetic Mappings, visualize
ggplot(data = whales_ahabs_df, aes(x = chapter, y = whale)) + 
    geom_bar(stat = "identity") +
    labs(x = "Chapter", 
         y = "Frequency",
         title = 'Occurrence of "whale"')

ggplot(data = whales_ahabs_df, aes(x = chapter, y = ahab)) + 
    geom_bar(stat = "identity") +
        labs(x = "Chapter", 
         y = "Frequency",
         title = 'Occurrence of "ahab"')
      
  rel_dfm <- dfm_weight(chap_dfm, scheme = "prop") * 100
head(rel_dfm)    

# subset dfm and convert to data.frame object
rel_chap_freq <- rel_dfm %>% 
    dfm_keep(pattern = c("whale", "ahab")) %>% 
    convert(to = "data.frame")

rel_chap_freq$chapter <- 1:nrow(rel_chap_freq)
ggplot(data = rel_chap_freq, aes(x = chapter, y = whale)) + 
    geom_bar(stat = "identity") +
    labs(x = "Chapter", y = "Relative frequency",
         title = 'Occurrence of "whale"')

##############
# correlation#
##################################################################

# margin: identifies the margin of the dfm on which similarity or difference will be computed: "documents" for documents or "features" for word/term features. 
dfm_weight(chap_dfm, scheme = "prop") %>% 
    textstat_simil(selection = c("whale", "ahab"), method = "correlation", margin = "features") %>%
    as.matrix() %>%
    head(2)


# Testing Correlation with Randomization

cor_data_df <- dfm_weight(chap_dfm, scheme = "prop") %>% 
    dfm_keep(pattern = c("ahab", "whale")) %>% 
    convert(to = "data.frame")

# sample 1000 replicates and create data frame
n <- 1000
samples <- data.frame(
    cor_sample = replicate(n, cor(sample(cor_data_df$whale), cor_data_df$ahab)),
    id_sample = 1:n
)

# plot distribution of resampled correlations
ggplot(data = samples, aes(x = cor_sample, y = ..density..)) +
    geom_histogram(colour = "black", binwidth = 0.01) +
    geom_density(colour = "red") +
    labs(x = "Correlation Coefficient", y = NULL,
         title = "Histogram of Random Correlation Coefficients with Normal Curve")






########################################
##### measures of lexical variety  #####
########################################

# length of the book in chapters
ndoc(chapters_corp)
# chapter names
docnames(chapters_corp) %>% head()
# calculate first few chapters
(ntoken(chapters_corp) / ntype(chapters_corp))%>% head()

(ntoken(chapters_corp) / ntype(chapters_corp)) %>%
    plot(type = "h", ylab = "Mean word frequency")

# TTR
dfm(chapters_corp) %>% 
    textstat_lexdiv(measure = "TTR") %>%
    head(n = 10)

# Hapax
# hapaxes per document
rowSums(chap_dfm == 1) %>% head()

# as a proportion
hapax_proportion <- rowSums(chap_dfm == 1) / ntoken(chap_dfm)
head(hapax_proportion)

barplot(hapax_proportion, beside = TRUE, col = "blue", names.arg = seq_len(ndoc(chap_dfm)))

#########################
##      kwic          ###
# For a text or a collection of texts (in a quanteda corpus object), 
# return a list of a keyword supplied by the user in its immediate context, 
# identifying the #source text# and the #word index number# within the source text.
# (Not the line number, since the text may or may not be segmented using end-of-line delimiters.)
##############################################


# find the indexes of the token positions for “gutenberg”
gutenberg_kwic <- kwic(data_char_mobydick, pattern = "gutenberg")
head(gutenberg_kwic$from, 10)

data_char_senseandsensibility <- texts(readtext("http://www.gutenberg.org/files/161/161.txt"))
names(data_char_senseandsensibility) <- "Sense and Sensibility"

litcorpus <- corpus(c(data_char_mobydick, data_char_senseandsensibility))

(dogkwic <- kwic(litcorpus, pattern = "dog"))

write.table(dogkwic, "mydata.txt", sep="\t", row.names = F)

data_char_mobydick










