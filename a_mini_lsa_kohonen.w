m4_define(m4_projname, `mini_lsa_kohonen')m4_dnl
m4_define(m4_amcathost, `http://amcat-dev.labs.vu.nl')m4_dnl
m4_define(m4_articlesetname, `minicorp')m4_dnl
m4_define(m4_articlesetid, `8402')m4_dnl
m4_define(m4_docfreq_thres, `2')m4_dnl
m4_define(m4_docfreq_pct_max, `95')m4_dnl
m4_define(m4_word_grid_width, `2')m4_dnl
m4_define(m4_word_grid_height, `2')m4_dnl
m4_define(m4_word_grid_shape, `rectangular')m4_dnl
m4_define(m4_doc_grid_width, `3')m4_dnl
m4_define(m4_doc_grid_height, `1')m4_dnl
m4_define(m4_doc_grid_shape, `rectangular')m4_dnl
m4_define(m4_random_generator_seed, `12345')m4_dnl
m4_changequote(`<!',`!>')m4_dnl
\documentclass{artikel3}
\newcommand{\theauthor}{Paul Huygen}
\newcommand{\thedoctitle}{Demo that LSA-kohonen works}
\title{\thedoctitle}
\author{\theauthor}
% Packages.
\usepackage{a4wide}
\usepackage{alltt}
\usepackage{color}
\usepackage{lmodern}
@%\usepackage[latin1]{inputenc}
@%\usepackage[T1]{fontenc}
\usepackage[british]{babel}
\usepackage{ifpdf}
\ifpdf
 \usepackage[pdftex]{graphicx}       %%% graphics for dvips
 \usepackage[pdftex]{thumbpdf}      %%% thumbnails for ps2pdf
 \usepackage[pdftex]{thumbpdf}      %%% thumbnails for pdflatex
 \usepackage[pdftex,                %%% hyper-references for pdflatex
 bookmarks=true,%                   %%% generate bookmarks ...
 bookmarksnumbered=true,%           %%% ... with numbers
 a4paper=true,%                     %%% that is our papersize.
 hypertexnames=false,%              %%% needed for correct links to figures !!!
 breaklinks=true,%                  %%% break links if exceeding a single line
 linkbordercolor={0 0 1}]{hyperref} %%% blue frames around links
 %                                  %%% pdfborder={0 0 1} is the
 %                                  default
 \hypersetup{
   pdfauthor   = {\theauthor},
   pdftitle    = {\thedoctitle},
   pdfsubject  = {web program},
  }
 \renewcommand{\NWlink}[2]{\hyperlink{#1}{#2}}
 \renewcommand{\NWtarget}[2]{\hypertarget{#1}{#2}}
 \renewcommand{\NWsep}{$\diamond$\rule[-1\baselineskip]{0pt}{1\baselineskip}}
\else
 \usepackage[dvips]{graphicx}        %%% graphics for dvips
%\usepackage[latex2html,             %%% hyper-references for ps2pdf
%bookmarks=true,%                   %%% generate bookmarks ...
%bookmarksnumbered=true,%           %%% ... with numbers
%hypertexnames=false,%              %%% needed for correct links to figures !!!
%breaklinks=true,%                  %%% breaks lines, but links are very small
%linkbordercolor={0 0 1},%          %%% blue frames around links
%pdfborder={0 0 112.0}]{hyperref}%  %%% border-width of frames 
\usepackage{html}
\renewcommand{\NWlink}[2]{\hyperlink{#1}{#2}}
\renewcommand{\NWtarget}[2]{\hypertarget{#1}{#2}}
\fi
%
@%\usepackage{hyperref}
%
% Settings
%
\raggedbottom
\makeatletter
\if@@oldtoc
  \renewcommand\toc@@font[1]{\relax}
\else
  \renewcommand*\toc@@font[1]{%
    \ifcase#1\relax
    \chaptocfont
    \or\slshape
    \or\rmfamily
    \fi}
\fi
\makeatother
\newcommand{\chaptocfont}{\large\bfseries}

\newcommand{\pdfpsinc}[2]{%
\ifpdf
  \input{#1}
\else
  \input{#2}
\fi
}
\newcommand{\BMU}{\textsc{bmu}}
\newcommand{\CSV}{\textsc{csv}}
\newcommand{\POS}{\textsc{pos}}
\newcommand{\SOM}{\textsc{som}}

\begin{document}

\maketitle

\section{Introduction}
\label{sec:intro}

\begin{itemize}
\item Topic analysis, bags-of-words, clustering of words and documents.
\item Visualisation of clusters of words and documents.
\item Kohonen package~\cite{wehrens2007a}
\item Four methods of dimension-reduction: 1) none; 2) random mapping
  of words; 3) Principal components~\cite{ampazis2004a} and 4) Latent Dirichlet analysis.
\item In this document one of the methods is applied on a tiny set of
  wordbags to show that it the technique works.
\end{itemize}

Poor-man's approach. This should have been done in Knitr, but I am too
lazy for that. Hence, here is the R file (in Nuweb):

@o mini_lsa_kohonen.r @{@%
#!/usr/bin/env Rscript
@< load libraries @>
@< define/set variables @>
@< define functions @>
@< get the documents as bags-of-words @>
@< filter words and generate vocabulary @>
@< perform dimension-reduction with LSA @>
@< create a word-SOM @>
@< create a doc-SOM @>

@| @}



\section{Methods}
\label{sec:methods}

\subsection{Outline}
\label{sec:outline}

\begin{itemize}
\item Made set of six word-bags in which the words are distributed in a not completely random way.
\item Download the set from Amcat.
\item Pre-process.
\item Make a document-term matrix with tf-idf.
\item Apply LSA to map the documents and the words on a set of vectors.
\item Generate a Self-Organizing Map of the terms.
\item Map the documents on the codevectors of the SOM and generate a
  SOM of the documents.
\end{itemize}

\subsection{Software used}
\label{sec:used}

\begin{itemize}
\item Documents stored in Amcat.
\item Processing done in R.
\item Packages: \href{http://cran.r-project.org/web/packages/kohonen/kohonen.pdf}{Kohonen}, lsa.
\item In future package amcat-r.
\end{itemize}

@d load libraries  @{@%
library('lsa')
library('kohonen')
library('RCurl')

@| @}

\subsection{Data}
\label{sec:data}

The data is a set of 6 ``documents'' that have been stored in Amcat. 

\textbf{TODO:} Find out how to read the documents from Amcat and
display them here.

Each document is a line of words:

\begin{description}
\item[doc1:] aap noot mies wim zus jet teun vuur gijs lam kees bok       
\item[doc2:] maan zaag fien vier koek schoen teun vuur gijs lam kees bok 
\item[doc3:] aap noot mies wim zus maan teun vuur gijs lam kees bok      
\item[doc4:] aap noot zaag wim zus teun gijs lam bok aap noot            
\item[doc5:] maan zaag mies vier koek schoen gijs lam kees bok           
\item[doc6:] zaag fien vier wim schoen teun vuur gijs lam kees bok       
\end{description}


To get the documents from Amcat, we have to specify some parameters:

@d define/set variables @{@%
host <- 'm4_amcathost'
articleset_title <- 'm4_articlesetname'
articleset_id <- m4_articlesetid
@| host articleset_title articleset_id @}

Apart from this, the script has to read a user/password combination
from a secret file. This file, named \verb|~/.amcatauth|, in
comma-separated value (\CSV{}) format, contains your username and your
password for access to Amcat. Such a file may look like:


\begin{verbatim}
host,user,passwd
http://amcat-dev.labs.vu.nl,PaulHuygen,Secret
\end{verbatim}


\section{Do the work}
\label{sec:dothework}

\subsection{Get bags-of-words}
\label{sec:getbags}

The function \texttt{getFeatures} retrieves words from the
documents in Amcat. When called by \texttt{getFeatures},  Amcat performs two filtering operations:
\begin{enumerate}
\item Only words with Part-Of-Speech (\POS{}) label ``Noun'', ``NN''
  and ``verb'' are selected. In this way it leaves out most of the
  common words like determiners and prepositions that have little to
  do with the topics in the documents.
\item The words are converted to their stems. In this way different
  inflections of e.g. verbs are mapped on the same stem.
\end{enumerate}

Use the old-fashioned library \verb|amcatr.r| instead the new
\href{https://github.com/amcat/amcat-r}{Github package}, because that
package did not work yet When I created this document. A disadvantage
of the legacy package is, that the script cannot find your username
and password for Amcat from a file and you bave to present them
interactively.

@d load libraries @{@%
source('amcatr.r')
source('amcat_getdata.r')
@| @}


@d get the documents as bags-of-words @{@%
userpass <- amcat.readauth(host)
conn = amcat.connect(host, username=userpass$username, passwd=userpass$password)
features = amcat.getFeatures(conn, articleset_id)
@|conn features getFeatures @}




The returned object is a dataframe with the following structure:

\begin{verbatim}
> str(features)
'data.frame':	63 obs. of  4 variables:
 $ id  : int  71952484 71952485 71952484 71952484 71952486 71952481 71952482 71952486 71952483 71952485 ...
 $ word: Factor w/ 22 levels "aap","bok","doc1",..: 18 2 2 21 8 15 17 9 1 17 ...
 $ pos : Factor w/ 2 levels "NN","noun": 1 1 1 1 1 1 2 1 2 2 ...
 $ hits: int  1 1 1 1 1 1 1 1 1 1 ...

\end{verbatim}

Every column of the dataframe mentions how often a word with a certain
stem and a certain \POS{} occurs in a certain document.

The number of words obtained is still very large (in ``real'' documentsets). When this is a
problem, or when one feels that further limitation of the words may
improve the result, we can remove words that occur in nearly every
document (in more than \verb|docfreq_pct.max| percent), or words that
occur hardly ever (fewer than \verb|docfreq.thres| times).

@d define/set variables @{@%
docfreq.thres <- m4_docfreq_thres
docfreq_pct.max <- m4_docfreq_pct_max
@|docfreq.thresh docfreq_pct.max @}


\textbf{Note} the following: We obtained the words as sets of stem and
\POS{}. However, in the following we are going to ignore the \POS{}
label. However, there are words with the same stem but different
\POS{} label and these with from now on be treated as identical.


@d filter words and generate vocabulary @{@%
docfreq <- aggregate(hits ~ word, features, FUN='length')
docfreq$docfreq_pct = (docfreq$hits / length(unique(features$id))) * 100
too_rare <- docfreq\$word[docfreq\$hits < docfreq.thres]
too_common <- docfreq\$word[docfreq\$docfreq_pct > docfreq_pct.max]
words = aggregate(hits ~ word, features, FUN='sum')
words <- words[!words\$word %in% too_rare,]
words <- words[!words\$word %in% too_common,]
printit('toorare.txt', paste('  ', length(too_rare), 'words are too rare (< docfreq.thres)'))
printit('toocommon.txt', paste('  ', length(too_common), 'words are too common (< docfreq_pct.max)'))

@| @}

The number of words that are too rare/too common:

\begin{verbatim}
m4_include(<!toorare.txt!>)
m4_include(<!toocommon.txt!>)

\end{verbatim}


Object \verb|voca| is to contain the vocabulary.

@d filter words and generate vocabulary @{@%
voca <- words
@| voca @}


\subsection{Perform dimension-reduction with LSA}
\label{sec:lsa}

The function \verb|lsa| takes table with the tf-idf scores of the
words in the documents and produces an object that contains the
singular-value-decomposition elements.

@d perform dimension-reduction with LSA @{@%
@< generate a tf-idf table @>
@< apply LSA @>

@| @}



We need a function to transform the hits into tf-idf scores.

@d define functions @{@%
tfidf <- function(hitmatrix){
    tf <- hitmatrix
    idf <- log(nrow(hitmatrix)/colSums(hitmatrix))
    tfidfm <- hitmatrix
    for(t in 1:ncol(hitmatrix)){
        tfidfm[,t] <- tf[,t]*idf[t]
    }
    tfidfm
}

@|tfidf @}

To build up the tf-idf table, generate an index that maps the
word-tokens in \verb|features| to entries in the vocabulary:


@d generate a tf-idf table @{@%
wordnrs <- match(features\$word, voca\$word)
@|wordnrs @}

Create other convenient parameters:

\begin{description}
\item[freqs:] List of the number of times that a word occurs in a document.
\item[docs:] List of the document-id's.
\item[ndocs:] Number of documents in the collection.
\item[docnrs:] Maps the columns of \verb|features| to the entries in \verb|ndocs|.
\item[nwords:] Number of word-types in the vocabulary.
\end{description}

@d generate a tf-idf table @{@%
freqs <- features\$hits
documents <- features\$id
docs <- unique(documents)
ndocs <- length(docs)
docnrs <- match(features\$id, docs)
nwords = length(voca\$word)

@| freqs documents docs ndocs docnrs nwords @}

Create a \emph{hittable} with the number of times that a word-type
occurs in a document and convert that into a tf-idf table named
\verb|mtd|. 

@d generate a tf-idf table @{@%
hittable <- matrix(data = 0, nrow = ndocs, ncol = nwords, dimnames=list(docs, voca\$word))
for (i in 1:length(features\$id)) {
    hittable[docnrs[i],wordnrs[i]] <- hittable[docnrs[i],wordnrs[i]] + features\$hits[i]
}
mtd <- tfidf(hittable)
tmtd <- t(mtd)

@| hittable mtfd tmtd @}

The \verb|lsa| function takes the transpose of the tf-idf table and
generates an object with the three ``principle component''
matrices. The number of principle components that are retained is
specified with the \verb|dims| argument. The \verb|lsa| packages has
two functions that automatically calculate a reasonable value for
\verb|dims|. In this example we choose the \verb|dimcalc_kaiser| function. 

@d apply LSA @{@%
mLSAspace <- lsa(tmtd, dims=dimcalc_kaiser())
@| mLSAspace lsa dimcalc_kaiser @}


The \verb|mLSAspace| object looks a follows:

\begin{verbatim}
> str(mLSAspace)
List of 3
 $ tk: num [1:13, 1:3] -0.406 -0.139 -0.274 -0.151 -0.121 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : chr [1:13] "fien" "kes" "mies" "not" ...
  .. ..$ : NULL
 $ dk: num [1:6, 1:3] -0.214 -0.491 -0.378 -0.245 -0.628 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : chr [1:6] "71952484" "71952485" "71952486" "71952481" ...
  .. ..$ : NULL
 $ sk: num [1:3] 2.72 2.07 1.4
 - attr(*, "class")= chr "LSAspace"
> 


\end{verbatim}

It contains \verb|tk|, the matrix that maps the word-types on the
princple component vectors, \verb|dk|, that maps the documents on the
princple components and \verb|sk|, the sorted eigenvalues of the
principle components. In our case, the Kaiser algorithm has reduced
the number of principle components to 3.


\subsection{Make SOM of the word-types}
\label{sec:docSOM}

Make a self-organizing map of the word-types as function of the
principle-component vectors, in the hope that words that relate to
similar topic will be mapped near each other in the \SOM{}. The

Define the size (number of rows and columns of the map) and geometry
(rectagular or hexagonal) of the word-\SOM{}.

@d define/set variables @{@%
word.grid.width <- m4_word_grid_width
word.grid.height <- m4_word_grid_height
ncode <- word.grid.width * word.grid.height
word.grid.shape <- "m4_word_grid_shape"
@| word.grid.width word.grid.height word.grid.shape @}

Oh \ldots{} wait \ldots{}. This is intended to be reproducible
research. So before initializing the \SOM{} with randomly chosen
codevectors, let us initialize the random number generator with a
fixed value.

@d define/set variables @{@%
set.seed(m4_random_generator_seed)
@| set.seed @}



The \verb|som| function of the \verb|kohonen| packages generates the
\SOM{}. The
\href{http://cran.r-project.org/web/packages/kohonen/kohonen.pdf}{documentation}
of the \verb|kohonen| packages mentions a lot of configuration
parameters that can be set, but for now we just use their default values.

@d create a word-SOM @{@%
term.matrix <- mLSAspace\$tk
term.som <- som(term.matrix, grid = somgrid(word.grid.height, word.grid.width, word.grid.shape))

@| term.matrix term.som @}

The object \verb|term.som| looks as follows:

\begin{verbatim}
> str(term.som)
List of 10
 $ data        : num [1:13, 1:3] -0.406 -0.139 -0.274 -0.151 -0.121 ...
  ..- attr(*, "dimnames")=List of 2
  .. ..$ : chr [1:13] "fien" "kes" "mies" "not" ...
  .. ..$ : NULL
 $ grid        :List of 5
  ..$ pts   : int [1:4, 1:2] 1 2 1 2 1 1 2 2
  .. ..- attr(*, "dimnames")=List of 2
  .. .. ..$ : NULL
  .. .. ..$ : chr [1:2] "x" "y"
  ..$ xdim  : num 2
  ..$ ydim  : num 2
  ..$ topo  : chr "rectangular"
  ..$ n.hood: chr "square"
  ..- attr(*, "class")= chr "somgrid"
 $ codes       : num [1:4, 1:3] -0.411 -0.34 -0.274 -0.172 -0.165 ...
 $ changes     : num [1:100, 1] 0.0444 0.0488 0.0336 0.0379 0.0376 ...
 $ alpha       : num [1:2] 0.05 0.01
 $ radius      : num [1:2] 1 -1
 $ toroidal    : logi FALSE
 $ unit.classif: int [1:13] 2 4 3 4 4 4 2 4 4 1 ...
 $ distances   : num [1:13] 1.57e-01 6.05e-02 2.15e-06 2.79e-02 2.70e-02 ...
 $ method      : chr "som"
 - attr(*, "class")= chr "kohonen"
> 

\end{verbatim}

The vector \verb|unit.classif| shows to which codevector each
word-type has been associated.

Plot the change and the population of the code (to be shown in the
``results'' section). See~\cite{wehrens2007a} for more examples of
visualization of \SOM{}'s with the Kohonen package.

@d create a word-SOM @{@%
pdf(file='wordsom_changes.pdf')
plot(term.som, type = "changes", main = articleset_title)
dev.off()
pdf(file='wordsom_population.pdf')
plot(term.som, type = "counts", main = articleset_title)
dev.off()
@| @}

\subsection{Create the document-som}
\label{sec:docsom}

Generate a document som as described in~\cite{ampazis2004a}. First map
the documents on the codevectors of the word-som and then make a
\SOM{} of that map according to~\cite{ampazis2004a}. In the words of
Amphazis et al: ``[\ldots] re-encode the original documents by mapping
their text, word by word, onto the \SOM{} by locating the Best
Matching Unit (\BMU) for each term on the map''. If I understand this
correctly, it works as follows:

First note to which \BMU{} each word has been associated.

@d create a doc-SOM @{@%
term.classif <- voca
term.classif$bmu <- term.som$unit.classif
@| term.classif @}

Map the documents via the words to the codevectors of the \SOM{} and
generate the document-\SOM{}.

@d create a doc-SOM @{@%
doc.matrix <- matrix(data=0, nrow=ndocs, ncol=ncode, dimnames=list(docs, NULL))
for(i in 1:nwords){
    column <- term.classif[i,]\$bmu
    doc.matrix[,column] <- doc.matrix[,column] + mtd[,i]
}
doc.som <- som(doc.matrix, grid = somgrid(doc.grid.width, doc.grid.height, doc.grid.shape)) 

@| doc.matrix @}

The configuration-parameters of the doc-\SOM{}:

@d define/set variables @{@%
doc.grid.width <- m4_doc_grid_width
doc.grid.height <- m4_doc_grid_height
doc.grid.shape <- "m4_doc_grid_shape"
@| doc.grid.width doc.grid.height doc.grid.shape @}

Make plots of the mean distance during the training-process and the
population of the code-vectors.

@d create a doc-SOM @{@%
pdf(file='docsom_changes.pdf')
plot(doc.som, type = "changes", main = articleset_title)
dev.off()
pdf(file='wordsom_population.pdf')
plot(term.som, type = "counts", main = articleset_title)
dev.off()
@| @}


\section{Results and discussion}
\label{sec:results}

Figure~\ref{fig:wordsom} shows the population of the word-\SOM{}. 

\begin{figure}[hbtp]
  \centering
  \mbox{\includegraphics[width=5cm]{wordsom_changes.pdf} \hspace{1cm} \includegraphics[width=5cm]{wordsom_population.pdf}}
  \caption{Population of word-\SOM{}}
  \label{fig:wordsom}
\end{figure}



@%\section{All the stuff}
@%\label{sec:remainder}
@%
@%@d all the stuff @{@%
@%
@%#
@%# Make reproducible
@%#
@%set.seed(12345)
@%                                        #
@%# tfidf function
@%#
@%
@%#
@%# Get Bags-of-words
@%#
@%host = 'http://amcat-dev.labs.vu.nl'
@%#
@%# Filter and generate vocabulary
@%#
@%#
@%# Generate word-doc table (matrix)
@%#
@%#
@%# Make word-som
@%#
@%term.classif <- voca
@%term.classif\$bmu <- term.som\$unit.classif
@%
@%
@%#
@%# Make doc-som
@%#
@%doc.matrix <- matrix(data=0, nrow=ndocs, ncol=ncode, dimnames=list(docs, NULL))
@%for(i in 1:nwords){
@%    column <- term.classif[i,]\$bmu
@%    doc.matrix[,column] <- doc.matrix[,column] + mtd[,i]
@%}
@%doc.som <- som(doc.matrix, grid = somgrid(doc.grid.width, doc.grid.height, 'rectangular')) 
@%pdf(file='docsom_changes.pdf')
@%plot(doc.som, type = "changes", main = articleset_title)
@%dev.off()
@%
@%@| @}

\section{Miscellaneous}
\label{sec:misc}

\subsection{Print messages}
\label{sec:print}

We used function \verb|printit| to make R print something that we can
include in this document. Let us define that function:

@d define functions @{@%
printit <- function(filename, printstring){
  sink(file = filename, type = 'output')
  print(printstring)
  sink(file = NULL)
} 

@| printit @}



\section{Run the thing}
\label{sec:runthething}

@o Makefile -t @{@%
to be created
@| @}

@o doit @{@%
#!/bin/bash
stripnw m4_projname
nuweb m4_projname.w
chmod 775 ./doit
chmod 775 m4_projname.r
./m4_projname.r
pdflatex m4_projname
bibtex m4_projname
nuweb m4_projname.w
pdflatex m4_projname
bibtex m4_projname
nuweb m4_projname.w
pdflatex m4_projname
bibtex m4_projname
nuweb m4_projname.w
@| @}

\section{References}
\label{sec:res}

\bibliographystyle{plain}
\bibliography{lda-kohonen}


\end{document}
