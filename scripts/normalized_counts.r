library(org.Hs.eg.db) # <- Homo sapiens
library(AnnotationDbi)

convert_ensembl_to_symbol <- function(df, ensembl_col) {
  # Estrai gli identificatori Ensembl dalla colonna specificata
  ensembl_ids <- df[[ensembl_col]]
  
  # Mappa gli ID Ensembl ai simboli genici
  gene_symbols <- mapIds(org.Hs.eg.db, 
                         keys = ensembl_ids, 
                         column = "SYMBOL", 
                         keytype = "ENSEMBL", 
                         multiVals = "first")
  
  # Sostituisci i NA con spazi vuoti
  gene_symbols[is.na(gene_symbols)] <- ""
  
  # Aggiungi i simboli al dataframe originale
  df$gene_symbol <- gene_symbols
  
  return(df)
}


library(DESeq2)

setwd("/home/manz/samples/aligned")

countData <- read.csv("countData.csv")
colData <- read.csv("colData.csv")

dds <- DESeqDataSetFromMatrix(
	countData=countData,
	colData=colData,
	design=~treatment,
	tidy=TRUE
)

# this writes down the normalized counts
dds <- estimateSizeFactors(dds)
sizeFactors(dds)
normalized_counts <- counts(dds, normalized=TRUE)
write.table(normalized_counts, file="normalized_counts.csv", sep=",", quote=F, col.names=NA)

# let's also add gene symbols to the normalized counts file
normalized_counts <- read.csv("normalized_counts.csv") # this adds the "X" to first colum
my_counts <- convert_ensembl_to_symbol(normalized_counts, "X")
write.csv(my_counts, file = "normalized_counts.csv", row.names = FALSE)
