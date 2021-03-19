I've removed the `htslib` folder and then, I replaced that with a fresh [htslib-v1.9](https://github.com/samtools/htslib/releases/tag/1.9). As discussed [here](https://askubuntu.com/questions/25961/how-do-i-install-a-tar-gz-or-tar-bz2-file), I installed it. 
```bash 
wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2
tar xvjf htslib-1.9.tar.bz2 
mv -v  htslib-1.9  htslib
rm htslib-1.9.tar.bz2 
cd htslib/
./configure 
make
cd ../
make 
```

