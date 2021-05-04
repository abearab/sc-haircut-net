# Load libraries
library(scater)
library(Seurat)
library(tidyverse)
library(cowplot)
library(Matrix.utils)
library(edgeR)
library(dplyr)
library(magrittr)
library(Matrix)
library(purrr)
library(reshape2)
library(S4Vectors)
library(tibble)
library(SingleCellExperiment)
library(pheatmap)
library(apeglm)
library(png)
library(DESeq2)
library(RColorBrewer)


# Likelihood ratio test
dir.create("DESeq2/lrt")

# Create DESeq2Dataset object
clusters <- levels(metadata$cluster_id)

metadata <- gg_df %>%
        select(cluster_id, sample_id, group_id) 

metadata$group <- paste0(metadata$cluster_id, "_", metadata$group_id) %>%
        factor()


# DESeq2
library(DEGreport)
get_dds_LRTresults <- function(x){
        
        cluster_metadata <- metadata[which(metadata$cluster_id == clusters[x]), ]
        rownames(cluster_metadata) <- cluster_metadata$sample_id
        counts <- pb[[clusters[x]]]
        cluster_counts <- data.frame(counts[, which(colnames(counts) %in% rownames(cluster_metadata))])
        
        #all(rownames(cluster_metadata) == colnames(cluster_counts))        
        
        dds <- DESeqDataSetFromMatrix(cluster_counts, 
                                      colData = cluster_metadata, 
                                      design = ~ group_id)
        
        dds_lrt <- DESeq(dds, test="LRT", reduced = ~ 1)
        
        # Extract results
        res_LRT <- results(dds_lrt)
        
        # Create a tibble for LRT results
        res_LRT_tb <- res_LRT %>%
                data.frame() %>%
                rownames_to_column(var="gene") %>% 
                as_tibble()
        
        # Save all results
        write.csv(res_LRT_tb,
                  paste0("DESeq2/lrt/", clusters[x], "_LRT_all_genes.csv"),
                  quote = FALSE, 
                  row.names = FALSE)
        
        # Subset to return genes with padj < 0.05
        sigLRT_genes <- res_LRT_tb %>% 
                filter(padj < 0.05)
        
        # Save sig results
        write.csv(sigLRT_genes,
                  paste0("DESeq2/lrt/", clusters[x], "_LRT_sig_genes.csv"),
                  quote = FALSE, 
                  row.names = FALSE)
        
        # Transform counts for data visualization
        rld <- rlog(dds_lrt, blind=TRUE)
        
        # Extract the rlog matrix from the object and compute pairwise correlation values
        rld_mat <- assay(rld)
        rld_cor <- cor(rld_mat)
        
        
        # Obtain rlog values for those significant genes
        cluster_rlog <- rld_mat[sigLRT_genes$gene, ]
        
        cluster_meta_sig <- cluster_metadata[which(rownames(cluster_metadata) %in% colnames(cluster_rlog)), ]
        
        # # Remove samples without replicates
        # cluster_rlog <- cluster_rlog[, -1]
        # cluster_metadata <- cluster_metadata[which(rownames(cluster_metadata) %in% colnames(cluster_rlog)), ]
        
        
        # Use the `degPatterns` function from the 'DEGreport' package to show gene clusters across sample groups
        cluster_groups <- degPatterns(cluster_rlog, metadata = cluster_meta_sig, time = "group_id", col=NULL)
        ggsave(paste0("DESeq2/lrt/", clusters[x], "_LRT_DEgene_groups.png"))
        
        # Let's see what is stored in the `df` component
        write.csv(cluster_groups$df,
                  paste0("DESeq2/lrt/", clusters[x], "_LRT_DEgene_groups.csv"),
                  quote = FALSE, 
                  row.names = FALSE)
        
        saveRDS(cluster_groups, paste0("DESeq2/lrt/", clusters[x], "_LRT_DEgene_groups.rds"))
        save(dds_lrt, cluster_groups, res_LRT, sigLRT_genes, file = paste0("DESeq2/lrt/", clusters[x], "_all_LRTresults.Rdata"))
        
}

map(1:length(clusters), get_dds_LRTresults)

