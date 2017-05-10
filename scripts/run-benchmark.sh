export CUDA_HOME=/usr/local/cuda-8.0
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
export N=$1

DATADIR=/data/benchmarks_gpu$N_`date +%Y%m%d_%H%M`

cd /opt/h2oaiglm/src
make -j gpu cpu
cd /opt/h2oaiglm/examples/cpp
ln -sf /data/train.txt .

make run 2>&1 | tee log$N.txt

mkdir $DATADIR
cp me*.txt $DATADIR
cp log*.txt $DATADIR

rm me*.txt
rm log*.txt

