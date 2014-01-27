install.packages('kohonen')
library('kohonen')
data(wines)
str(wines)
example <- c( "aap noot mies wim zus jet teun vuur gijs lam kees bok"
            , "maan zaag fien vier koek schoen teun vuur gijs lam kees bok"
            , "aap noot mies wim zus maan teun vuur gijs lam kees bok"
            , "aap noot zaag wim zus teun gijs lam bok"
            , "maan zaag mies vier koek schoen gijs lam kees bok"
            , "zaag fien vier wim schoen teun vuur gijs lam kees bok"
            )
str(example)

for (i in 1:length(example)){
#    wordlist <- strsplit(example[i], " ")[[1]]
    if(i == 1){
        vocab <- example[1]
    } else {
        vocab <- paste(vocab, example[i])
    }
}                    
vocab <- unique(strsplit(vocab, " ")[[1]])
ndocs <- length(example)
nwords <- length(vocab)
hittable <- matrix(data = 0, nrow = ndocs, ncol = nwords, dimnames=list(1:length(example), vocab))
for (i in 1:length(example)){
    wordlist <- strsplit(example[i], " ")[[1]]
    wordnrs <- match(wordlist, vocab)
    for(j in 1:length(wordlist)){
        hittable[i, wordnrs[j]] <- hittable[i, wordnrs[j]] + 1
    }
}                    
hittable
set.seed(4)
docs.som <- som(data = hittable, grid = somgrid(2, 1, 'rectangular'))
plot(docs.som, type = "counts", main = "My topic distribution")
plot(docs.som, type = "changes", main = "Youp topic distribution")

plot(docs.som, main = "docs data")
docs.som
str(docs.som)
docs.som$changes
