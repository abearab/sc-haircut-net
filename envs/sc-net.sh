conda create -y -n sc-net python=3.7
conda activate sc-net
conda install -y numpy pandas
conda install -y -c anaconda cytoolz
# pip install pyscenic 

conda install -c conda-forge python-igraph
conda install -c bioconda scanpy

pip install pyscenic
pip install stringdb
pip install algorithmx

conda install -c anaconda ipykernel