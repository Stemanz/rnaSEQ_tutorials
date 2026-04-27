# copy and paste everything into R, then execute it.
# NOTE: you will be asked this question:

#> install.packages("BiocManager")
#BiocManager::version()
#Installing package into ‘/usr/local/lib/R/site-library’
#(as ‘lib’ is unspecified)
#Warning in install.packages("BiocManager") :
#  'lib = "/usr/local/lib/R/site-library"' is not writable
#Would you like to use a personal library instead? (yes/No/cancel) y

# hit "y", then "Enter"

#Would you like to create a personal library
#‘~/.Rlib’
#to install packages into? (yes/No/cancel) y

# hit "y", then "Enter"

install.packages("BiocManager")
BiocManager::install(version = "3.22", ask=FALSE)

#BiocManager::version()

BiocManager::install("DESeq2", ask=FALSE)

BiocManager::install("AnnotationDbi", ask=FALSE)
BiocManager::install("org.Hs.eg.db", ask=FALSE)
BiocManager::install("org.Mm.eg.db", ask=FALSE)

BiocManager::install("rtracklayer", ask=FALSE)
BiocManager::install("GenomicFeatures", ask=FALSE)
BiocManager::install("txdbmaker", ask=FALSE)
