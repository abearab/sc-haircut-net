import numpy as np 
import pandas as pd
import scanpy as sc
import anndata as ad
import seaborn as sns
import matplotlib as mpl
import matplotlib.pyplot as plt

sc.settings.verbosity = 1             # verbosity: errors (0), warnings (1), info (2), hints (3)
sc.settings.set_figure_params(dpi=80, frameon=False, figsize=(3, 3), facecolor='white')

sc.logging.print_header()


def preprocessing(adata):
    # Basic filtering:
    sc.pp.filter_genes(adata, min_cells=1)
    # annotate the group of mitochondrial genes as 'mt'
    adata.var['mt'] = adata.var.index.str.startswith('MT-')  
    # Remove cells that have too many mitochondrial genes expressed or too many total counts:
    sc.pp.calculate_qc_metrics(adata, qc_vars=['mt'], percent_top=None, log1p=False, inplace=True)
    adata = adata[adata.obs.n_genes_by_counts < 2500, :]
    adata = adata[adata.obs.pct_counts_mt < 5, :]
    # Total-count normalize (library-size correct) the data matrix 
    # 𝐗 to 10,000 reads per cell, so that counts become comparable among cells.
    sc.pp.normalize_per_cell(adata)
    # Logarithmize the data:
    sc.pp.log1p(adata)
    # Identify highly-variable genes.
    sc.pp.highly_variable_genes(adata, min_mean=0.0125, max_mean=3, min_disp=0.5)
    adata.raw = adata
    # Actually do the filtering
    adata = adata[:, adata.var.highly_variable]
    # Regress out effects of total counts per cell and the percentage of mitochondrial genes expressed. 
    # Scale the data to unit variance.
    sc.pp.regress_out(adata, ['total_counts', 'pct_counts_mt'])
    # Scale each gene to unit variance. Clip values exceeding standard deviation 10.
    sc.pp.scale(adata, max_value=10)

    
def cluster(adata):
    # dimensionality reduction
    sc.pp.pca(adata)
    sc.pp.neighbors(adata, n_neighbors=10, n_pcs=40)
    sc.tl.umap(adata)
    # clustering
    sc.tl.leiden(adata, key_added='clusters', resolution=0.5)
    # finding marker genes 
    sc.tl.rank_genes_groups(adata, 'clusters', method='t-test') # wilcoxon


def selected_hairpins(adata_m,adata_r,src='reanalyzed',out='adata'): # src -> or public; out -> df
    '''
    mean scaled count of U-45 and rG-44
    '''
    # Uracil_45
    U = adata_r[:,adata_r.var_names.str.contains(r'Uracil[1-5]_45')].layers['counts'].mean(axis=1)
    # riboG_44
    rG = adata_r[:,adata_r.var_names.str.contains(r'riboG[1-5]_44')].layers['counts'].mean(axis=1)    
    cells = adata_r.obs.index.tolist()
    
    df = pd.DataFrame([np.array(U),np.array(rG)],columns=cells).T.rename(columns={0: "Uracil-45", 1: "riboG-44"})
    if out == 'df': 
        return df
    elif out == 'adata':        
        adata0= ad.AnnData(df)
        adata = adata_m.T.concatenate(adata0.T).T
        adata.obs = adata_m.obs
        adata.uns = adata_m.uns
        adata.obsm = adata_m.obsm
        adata.obsp = adata_m.obsp
        return adata


def read_repair(PATH):
    adata = sc.read_mtx(f'{PATH}/matrix.mtx.gz').T
    barcodes = pd.read_csv(f'{PATH}/barcodes.tsv.gz', header=None, index_col=0)
    barcodes.index.name = 'barcodes'
    features = pd.read_csv(f'{PATH}/features.tsv.gz', header=None, index_col=0)
    features.index.name = 'features'
    adata.var.index = features.index
    adata.obs.index = barcodes.index
    adata.layers["counts"] = adata.X.copy()
    adata.var["control"] = adata.var_names.str.contains("control")
    
    sc.pp.calculate_qc_metrics(adata,percent_top=(5, 10, 15),var_type="hairpins",qc_vars=("control",),inplace=True,)
    
    return adata


def read_data(expriment,src='reanalyzed'): # or public
    if src == 'public':
        adata_m = sc.read_10x_mtx(f'public-data/{expriment}/mrna/')
        adata_r = read_repair(f'public-data/{expriment}/repair/')
    elif src == 'reanalyzed':
        barcodes = pd.read_csv(
            f'public-data/{expriment}/repair/barcodes.tsv.gz',sep='\t',header=None
        )[0].str.split('-', 1, expand=True)[0].tolist()
        adata_m = sc.read(f'reanalyzed-data/{expriment}_mrna/counts_unfiltered/adata.h5ad')
        adata_m = adata_m[barcodes]
        # gene names as .var index
        adata_m.var.index = adata_m.var.gene_name.tolist()
        adata_m.var_names_make_unique()
        
        adata_r = ad.read_umi_tools(f'reanalyzed-data/{expriment}_repair_umitools_counts.tsv.gz')
        adata_r.obs.index.name = 'barcodes'
        adata_r.var.index.name = 'features'
        adata_r = adata_r[barcodes]
    
    
    preprocessing(adata_m)
    adata_m.layers["counts"] = adata_m.X.copy()
    # scale and store results in layer
    adata_m.layers['scaled'] = sc.pp.scale(adata_m, copy=True).X
    cluster(adata_m)
    
    adata_r.layers["counts"] = adata_r.X.copy()
    # scale and store results in layer
    adata_r.layers['scaled'] = sc.pp.scale(adata_r, copy=True).X
    adata_r.var["control"] = adata_r.var_names.str.contains("control")
    cluster(adata_r)
    
    adata_m.obs['repair'] = adata_r.obs.clusters
    
    return adata_m, adata_r 