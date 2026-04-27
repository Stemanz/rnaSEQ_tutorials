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
library(rtracklayer)
library(GenomicFeatures)
library(txdbmaker)

setwd("/home/manz/samples/aligned")

# ----------------------------
# Load count matrix and metadata
# ----------------------------
countData <- read.csv("countData.csv")
colData   <- read.csv("colData.csv")

dds <- DESeqDataSetFromMatrix(
  countData = countData,
  colData   = colData,
  design    = ~ treatment,
  tidy      = TRUE
)

raw_counts <- counts(dds, normalized = FALSE)


# Load GTF and compute gene lengths
gtf_file <- "/home/manz/genome/hsa_GRCh38.p14/gencode.v49.basic.annotation.gtf"
txdb <- makeTxDbFromGFF(gtf_file, format = "gtf")

# Get exons grouped by gene
exons_by_gene <- exonsBy(txdb, by = "gene")

# Compute gene lengths (sum of non-overlapping exons)
gene_lengths <- sum(width(reduce(exons_by_gene)))
# if we removed the subversions from the ENSEMBL ids, we also need to remove them from the ones imported
# from the .gtf file, otherwise matsh() will fail: 
names(gene_lengths) <- sub("\\..*", "", names(gene_lengths))

# Convert to data.frame
gene_length_df <- data.frame(
  gene_id = names(gene_lengths),
  length  = as.numeric(gene_lengths)
)

# ----------------------------
# Align gene lengths to count matrix
# ----------------------------
gene_length_df <- gene_length_df[
  match(rownames(raw_counts), gene_length_df$gene_id),
]

# Remove genes without length annotation
valid <- !is.na(gene_length_df$length)

raw_counts <- raw_counts[valid, ]
gene_length_df <- gene_length_df[valid, ]

# Convert lengths to kilobases
gene_length_kb <- gene_length_df$length / 1000

# ----------------------------
# Calculate TPM
# ----------------------------
# RPK
rpk <- sweep(raw_counts, 1, gene_length_kb, FUN = "/")

# Scaling factor per sample
scaling_factors <- colSums(rpk)

# TPM
tpm <- sweep(rpk, 2, scaling_factors, FUN = "/") * 1e6

# ----------------------------
# Save TPM matrix
# ----------------------------
write.table(
  tpm,
  file = "TPM.csv",
  sep = ",",
  quote = FALSE,
  col.names = NA
)

# ----------------------------
# Add gene symbols (optional)
# ----------------------------
tpm <- read.csv("TPM.csv")  # adds "X" column
my_tpm <- convert_ensembl_to_symbol(tpm, "X")

write.csv(my_tpm, file = "TPM.csv", row.names = FALSE)
