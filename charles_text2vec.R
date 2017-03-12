
##################
#                #
# Word Distances #
#                #
##################

library(rword2vec)
library(tm)
stopWords <- stopwords("english")

base = "C:\\Users\\OCIS-9CS2TY1\\Documents\\mY dOCS\\nwu_mspa\\course_454\\group_project\\"
inputfile = paste(base, "Train_rev1.csv", sep="")
descfile = paste(base, "fulldesc.txt", sep="")
binfile = paste(base, "model1_little.bin", sep="")
txtfile = paste(base, "model1_little.txt", sep="")

adz.data = read.csv(inputfile, na.strings=c(""," ","NA"), nrow=100)
adz.data[] <- lapply(adz.data, as.character)

adz.desc <- adz.data$FullDescription

'%nin%' <- Negate('%in%')
adz.desc.2 <- lapply(adz.desc, function(x) {
  t <- unlist(strsplit(x, " "))
  t[t %nin% stopWords]
})

adz.desc.2 <- gsub("<br />","",adz.desc.2)
adz.desc.2 <- tolower(adz.desc.2)
adz.desc.2 <- gsub("[[:punct:]]", "", adz.desc.2)

write(adz.desc.2, descfile)

model=word2vec(train_file=descfile, output_file=binfile, layer1_size=300, min_count=40, num_threads=4, window=10, sample=0.001)

bin_to_txt(binfile, txtfile)

ana1=word_analogy(binfile,"position work role")

dist1=distance(binfile,"experience",num = 10)


##################
#                #
# Data Prep      #
#                #
##################

library(tidytext)
library(dplyr)

# load data
#adz.data <- read.csv(file="C:\\Users\\OCIS-9CS2TY1\\Documents\\mY dOCS\\nwu_mspa\\course_454\\group_project\\Train_rev1.csv",header=TRUE,sep=",")
adz.data = read.csv('C:\\Users\\OCIS-9CS2TY1\\Documents\\mY dOCS\\nwu_mspa\\course_454\\group_project\\Train_rev1.csv', na.strings=c(""," ","NA"), nrow=1000)

# convert factor columns to character
adz.data[] <- lapply(adz.data, as.character)

data(stop_words)

# get word counts across all job descriptions
desc_words_all <- adz.data %>%
  unnest_tokens(word, FullDescription) %>%
  anti_join(stop_words) %>%
  #count(Id, word, sort = TRUE) %>%
  count(word, sort = TRUE) %>%
  ungroup()

# get word counts within each description
desc_words_ids <- adz.data %>%
  unnest_tokens(word, FullDescription) %>%
  anti_join(stop_words) %>%
  count(Id, word, sort = FALSE) %>%
  ungroup()

desc_total <- desc_words_ids %>% 
  group_by(Id) %>% 
  summarize(total = sum(n))

#desc_sort <- left_join(desc_words_ids, desc_total)  

#desc_sort %>%
#  select(-total) %>%
#  arrange(desc(tf_idf))

desc_words_ids <- desc_words_ids %>%
  bind_tf_idf(word, Id, n)


#m_all <- as.matrix(desc_words_all)
#m_ids <- as.matrix(desc_words_ids)

# grab top 50 words and alphabetize
desc_words_50 <- desc_words_all[1:50,]
desc_words_50_sorted <- desc_words_50[with(desc_words_50, order(word)),]

# initialize new/resulting dataframe
adz.data.tfidf <- data.frame(matrix(ncol=108, nrow=0))
col_tfidf <- paste(c(desc_words_50_sorted$word), "tfidf", sep = "_")
col_kwfreq <- paste(c(desc_words_50_sorted$word), "kwfreq", sep = "_")
colnames(adz.data.tfidf) <- c('SalaryNormalized', 
                              'Id', 
                              'Title', 
                              'LocationNormalized', 
                              'ContractType',
                              'ContractTime',
                              'Company',
                              'Category',
                              col_tfidf, 
                              col_kwfreq)

# flatten tfidfs & kwfreqs
for (i in 1:nrow(desc_words_ids)) {
  id <- desc_words_ids[i,"Id"]
  
  # check if job already exists in new data set
  if (!is.element(id, adz.data.tfidf$Id)) {
    temprow <- matrix(c(rep.int(0,length(adz.data.tfidf))),nrow=1,ncol=length(adz.data.tfidf))
    newrow <- data.frame(temprow)
    colnames(newrow) <- colnames(adz.data.tfidf)
    orig.row_id <- which(adz.data$Id==as.integer(id))
    
    # populate original values    
    newrow$Id <- id
    newrow$SalaryNormalized <- adz.data[orig.row_id, 'SalaryNormalized']
    newrow$Title <- adz.data[orig.row_id, 'Title']
    newrow$LocationNormalized <- adz.data[orig.row_id, 'LocationNormalized']
    newrow$ContractType <- adz.data[orig.row_id, 'ContractType']
    newrow$ContractTime <- adz.data[orig.row_id, 'ContractTime']
    newrow$Company <- adz.data[orig.row_id, 'Company']
    newrow$Category <- adz.data[orig.row_id, 'Category']
    
    adz.data.tfidf[nrow(adz.data.tfidf)+1,] <- newrow
  }
  word <- desc_words_ids[i,"word"]
  
  # is word one of the top 50?
  if(word %in% desc_words_50_sorted$word) {  #if(word %in% colnames(desc_words_ids_flat)) {
    label_tfidf <- paste(as.character(word), 'tfidf', sep='_')
    label_kwfreq <- paste(as.character(word), 'kwfreq', sep='_')
    row_id <- match(id,adz.data.tfidf$Id)
    adz.data.tfidf[row_id, label_tfidf] <- desc_words_ids[i,'tf_idf']
    adz.data.tfidf[row_id, label_kwfreq] <- desc_words_ids[i,'n']
  }
}

df = as.matrix(adz.data.tfidf)

write.csv(df, file = 'C:\\Users\\OCIS-9CS2TY1\\Documents\\mY dOCS\\nwu_mspa\\course_454\\group_project\\adzuna_data_prep.csv',row.names=FALSE)



