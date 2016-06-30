
library("LDAvis")
library("aRxiv")
library("tm")
library("topicmodels")

dir <- getwd()


query <- 'cat:astro-ph* AND submittedDate:[20160401 TO 20160430]'
#arxiv_count(query)


#z <- arxiv_search(query,force=T,limit=20000)

z <- z.append(y)

#save(z,file = paste0(dir,'/sussex/arxiv_topicmodels/2016_arxiv.RData'))

load(dir+'/sussex/arxiv_topicmodels/2016_arxiv.RData')

# filter for papers with the primary category in astro-ph
astro_cats <- unique(z$primary_category)[grep('^astro-ph',unique(z$primary_category))]

dat <- z[z$primary_category %in% astro_cats,]

corpus <- tm::Corpus(tm::VectorSource(dat$abstract))

corpus.clean <- tm::tm_map(corpus, content_transformer(tolower), lazy = T)
corpus.clean <- tm::tm_map(corpus.clean, content_transformer(removePunctuation), lazy = T)
corpus.clean <- tm::tm_map(corpus.clean, content_transformer(removeNumbers), lazy = T)
corpus.clean <- tm::tm_map(corpus.clean, content_transformer(removeWords), stopwords('english'))
corpus.clean <- tm::tm_map(corpus.clean, content_transformer(stripWhitespace), lazy = T)
corpus.clean <- tm::tm_map(corpus.clean, content_transformer(removeWords), stopwords('english'))
corpus.clean <- tm::tm_map(corpus.clean, stemDocument)



dtm <- tm::DocumentTermMatrix(corpus.clean)

# filter out low scoring tf-idf terms
tfidf.scores <- colSums(as.matrix(tm::weightTfIdf(dtm)))
dtm <- dtm[,tfidf.scores > quantile(tfidf.scores, 0.3)]

# convert to matrix to allow row and column sums to be calculated
td.mat <- as.matrix(dtm)


topic.no <- 15

lda <- topicmodels::LDA(dtm, k = topic.no, method = "Gibbs")


phi <- posterior(lda)$terms
theta <- posterior(lda)$topics
doc.length <- rowSums(td.mat)
term.frequency <- colSums(td.mat)
vocab <- tm::Terms(dtm)


LDAvis.json <- LDAvis::createJSON(phi = phi,
                                  theta = theta,
                                  doc.length = doc.length,
                                  vocab = vocab,
                                  term.frequency = term.frequency)

library(RJSONIO)

topic_order <- RJSONIO::fromJSON(LDAvis.json)$topic.order

LDAvis::serVis(LDAvis.json)



## save data for Shiny app

# ldavis json
save(LDAvis.json, file=paste0(dir,'/sussex/arxiv_topicmodels/ldavis.RData'))

# small data frame of interesting features
theta_sorted <- data.frame(theta[,topic_order])
colnames(theta_sorted) <- paste("topic",1:15)
output_data <- data.frame(dat[,c("id","submitted","updated","title","link_abstract","primary_category")],theta_sorted)

save(output_data, file=paste0(dir,'/sussex/arxiv_topicmodels/topics.RData'))

## what categories does a topic represent?

# find the topic distribution for each category
top_topics <- lapply(astro_cats,FUN = function(x){
  apply(theta[dat$primary_category == x,],2,mean)
})

# find the top topic for each category
data.frame(astro_cats,unlist(lapply(top_topics,which.max)))


