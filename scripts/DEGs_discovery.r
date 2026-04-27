library(org.Hs.eg.db)
library(AnnotationDbi)

# Funzione per convertire gli identificatori Ensembl in simboli genici
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
  
  # Aggiungi i simboli genici al dataframe originale
  df$gene_symbol <- gene_symbols
  
  return(df)
}

library(DESeq2)

countData <- read.csv("countData.csv")
colData <- read.csv("colData.csv")

dds <- DESeqDataSetFromMatrix(
	countData=countData,
	colData=colData,
	design=~treatment,
	tidy=TRUE
)

# this actually runs the analysis
des <- DESeq(dds)

# this is needed to produce a readable results table
res = results(des)
res <- res[order(res$padj), ]

# saving the results
write.csv(res, "DESeq_results.csv")

# saving the results with gene symbols added
data <- read.csv("DESeq_results.csv") # this must have been processed to remove subversions from Ensembl ids!
my_data <- convert_ensembl_to_symbol(data, "X")
write.csv(my_data, file = "DESeq_results.csv", row.names = FALSE)


# to write down normalized counts
dds <- estimateSizeFactors(dds)
sizeFactors(dds)
normalized_counts <- counts(dds, normalized=TRUE)
write.table(normalized_counts, file="normalized_counts.csv", sep=",", quote=F, col.names=NA)

# let's also add gene symbols to the normalized counts file
normalized_counts <- read.csv("normalized_counts.csv") # this adds the "X" to first colum
my_counts <- convert_ensembl_to_symbol(normalized_counts, "X")
write.csv(my_counts, file = "normalized_counts.csv", row.names = FALSE)
