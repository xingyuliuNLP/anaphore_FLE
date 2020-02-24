import nltk
from nltk.corpus import PlaintextCorpusReader
corpus_root = r'/Users/becca/Documents/these/RLinguistics/mycorpus'
corpus = PlaintextCorpusReader(corpus_root, '.*')
files = corpus.fileids()
listLen = []
with open ('recapulatif1.txt', 'w+') as output:
    for file in files:
        sents = corpus.sents(file)
        print(sents)
        length = 0
        for sent in sents:
          listLen.append(len(sent))
          if len(sent)== 110:
            print(sent)
          length += len(sent)
        len_average = length/len(sents)
        output.write(file + '\t' + str(len_average) + '\n')





# tokenizer = nltk.RegexpTokenizer(r'\w+')
# tokenizer.tokenize