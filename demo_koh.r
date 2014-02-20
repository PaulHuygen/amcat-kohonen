source('amcatr.r')
source('amcat_getdata.r')
source('lda_lib.r')
library('kohonen')

articleset_id = 45     # Columns Youp (n = 1323)
host = 'http://amcat-dev.labs.vu.nl'
docfreq.thres=5        # Min. aantal incidenties v.e. woord in de set
docfreq_pct.max=50     # Max. aantal documenten waarin in woord mag voorkomen
grid.width <- 8
grid.height <- 8
grid.shape <- "rectangular"

##
## Get word statistics from Amcat
##
conn = amcat.connect(host) # AmCAT vraagt om je inloggegevens
features = amcat.getFeatures(conn, articleset_id)
document.total <- aggregate(hits ~ id, features, FUN='sum')






##
## Filter out too common/too rare words
## 
docfreq = aggregate(hits ~ word, features, FUN='length') # in how many documents does a word occur?
too_rare = docfreq$word[docfreq$hits < docfreq.thres]
docfreq$docfreq_pct = (docfreq$hits / length(unique(features$id))) * 100
too_common = docfreq$word[docfreq$docfreq_pct > docfreq_pct.max]
print(paste('  ', length(too_rare), 'words are too rare (< docfreq.thres)'))
print(paste('  ',length(too_common), 'words are too common (> docfreq_pct.max)'))
words = aggregate(hits ~ word + pos, features, FUN='sum')
words = words[!words$word %in% too_rare,]
words = words[!words$word %in% too_common,]
voca = words
features = features[features$word %in% voca$word,]
##
## Create matrix
##
wordnrs <- match(features$word, voca$word)
freqs <- features$hits
documents <- features$id
docs <- unique(documents)
ndocs = length(docs)
docnrs <- match(features$id, docs)
nwords = length(voca$word)
corp <- matrix(data = 0, nrow = ndocs, ncol = nwords, dimnames=list(docs, voca$word))
for (i in 1:length(features$id)) {
    corp[docnrs[i],wordnrs[i]] <- features$hits[i]
}
corp.sc <- scale(corp)
bad <- is.nan(corp.sc[1,])
corp.sc <- corp.sc[,!bad]
##
## Cluster
##
corp.som <- som(data = corp.sc, grid = somgrid(grid.height, grid.width, grid.shape)) 
plot(corp.som, type = "counts", main = "Youp topic distribution")
