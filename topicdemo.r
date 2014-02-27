# Install and load the corpus

install.packages("corpus.JSS.papers"
                , repos = "http://datacube.wu.ac.at/"
                , type = "source"
                )
data("JSS_papers", package = "corpus.JSS.papers")

JSS_papers <- JSS_papers[JSS_papers[,"date"] < "2010-08-05",]
JSS_papers <- JSS_papers[ sapply(JSS_papers[, "description"]
                        , Encoding) == "unknown"
                        ,
                        ]
library("tm")
library("XML")
remove_HTML_markup <-
   function(s) tryCatch({
      doc <- htmlTreeParse(paste("<!DOCTYPE html>", s)
                                , asText = TRUE, trim = FALSE
                                )
      xmlValue(xmlRoot(doc))
   }, error = function(s) s)
corpus <- Corpus(VectorSource( sapply( JSS_papers[, "description"]
                                     , remove_HTML_markup
                                     )
                             )
                )
Sys.setlocale("LC_COLLATE", "C")
JSS_dtm <- DocumentTermMatrix( corpus
                             , control = list( stemming = TRUE
                                             , stopwords = TRUE
                                             , minWordLength = 3
                                             , removeNumbers = TRUE
                                             , removePunctuation = TRUE
                                             )
                             )
dim(JSS_dtm)
library("slam")
summary(col_sums(JSS_dtm))
term_tfidf <- tapply( JSS_dtm$v/row_sums(JSS_dtm)[JSS_dtm$i]
                    , JSS_dtm$j, mean
                    ) * log2(nDocs(JSS_dtm)/col_sums(JSS_dtm > 0))
summary(term_tfidf)
JSS_dtm <- JSS_dtm[,term_tfidf >= 0.1]
JSS_dtm <- JSS_dtm[row_sums(JSS_dtm) > 0,]
summary(col_sums(JSS_dtm))
dim(JSS_dtm)
library("topicmodels")
k <- 30
SEED <- 2010
jss_TM <- list( VEM = LDA( JSS_dtm
                          , k = k
                          , control = list(seed = SEED)
                          )
              , VEM_fixed = LDA( JSS_dtm
                               , k = k
                               , control = list( estimate.alpha = FALSE
                                               , seed = SEED
                                               )
                               )
              , Gibbs = LDA( JSS_dtm
                           , k = k
                           , method = "Gibbs"
                           , control = list( seed = SEED
                                           , burnin = 1000
                                           , thin = 100
                                           , iter = 1000
                                           )
                           )
              , CTM = CTM( JSS_dtm
                         , k = k
                         , control = list( seed = SEED
                                         , var = list(tol = 10^-4)
                                         , em = list(tol = 10^-3)
                                         )
                         )
              )

sapply(jss_TM[1:2], slot, "alpha")

sapply(jss_TM, function(x) mean( apply(posterior(x)$topics
                                      , 1
                                      , function(z) - sum(z * log(z))
                                      )
                                )
      )

Topic <- topics(jss_TM[["VEM"]], 1)
Terms <- terms(jss_TM[["VEM"]], 5)
Terms[,1:5]

(topics_v24 <- topics(jss_TM[["VEM"]])[grep("/v24/", JSS_papers[, "identifier"])])
most_frequent_v24 <- which.max(tabulate(topics_v24))
terms(jss_TM[["VEM"]], 10)[, most_frequent_v24]
