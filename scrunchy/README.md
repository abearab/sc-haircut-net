
# scrunchy 

scrunchy provides analysis tools for the **s**ingle-**c**ell
**r**econstruction of f**unc**tional **h**eterogeneit**y**.

New methods to study heterogeneity at cellular resolution in complex
tissues are rapidly transforming human biology. These methods measure
differences in gene expression, chromatin accessibility, and protein
levels across thousands of cells to understand developmental
trajectories of tissues, tumors, and whole organisms. However, their
reliance on measurements of steady-state abundance of DNA, RNA, and
protein limits our ability to extract dynamic information from single
cells.

To propel the study of heterogeneity among single cells, we are
developing functional assays as a new modality for single-cell
experiments. Instead of measuring the molecular abundance of DNA, RNA,
or protein in single cells and predicting functional states, our key
innovation is to directly measure enzymatic activities in single cells
by analyzing the conversion of substrates to products by single-cell
extracts in a high-throughput DNA sequencing experiment.

### Functional heterogeneity of DNA repair

Our first functional method simultaneously measures the activity of DNA
repair enzymes and the abundance of mRNAs from thousands of single
cells. We measure DNA repair activities by encapsulating synthetic DNA
oligonucleotides with defined lesions with single cells. Cellular DNA
repair enzymes recognize and catalyze incision of these substrates,
which we subsequently capture in a modified library construction
protocol. 

An example data set in scrunchy contains a subset of data from an
experiment in which we simultaneously measure mRNA expression and
specific types of DNA repair activities in thousands of single cells
(human peripheral blood mononuclear cells).

In addition to mRNA expression, we measured the activity of DNA repair
factors in each of these cells. 