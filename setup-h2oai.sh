#!/bin/bash
  
  DEBIAN_FRONTEND=noninteractive

  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8
  
  apt-get upgrade -y && \
  apt-get install -y \
    libopenblas-dev \
    libatlas-base-dev \
    python3-pip \
    python3-dev \
    python3-dev \
    python3-wheel \
    nodejs \
    libgtk2.0-0 \
    dirmngr \
    libpng-dev \
    zlib1g-dev \
    dpkg-dev \
    automake \
    autoconf \
    libcurl4-openssl-dev \
    unzip 

  mkdir /opt/h2oai
  cd /opt
  wget https://raw.githubusercontent.com/h2oai/h2oai-power-nae/master/requirements.txt

  apt-get install -y \
    pkg-config \
    libfreetype6-dev \
    git \
    libopencv-dev

  /usr/bin/pip3 install --upgrade pip && \
  /usr/bin/pip3 install --upgrade numpy && \
  /usr/bin/pip3 install --upgrade cython && \
  /usr/bin/pip3 install --upgrade scipy && \
  /usr/bin/pip3 install -r /opt/h2oai/requirements.txt && \ 
  apt-get clean && \
  rm -rf /var/cache/apt/*

  cd /opt && \
  git clone --recursive https://github.com/dmlc/xgboost && \
  cd xgboost && \
  sed -e 's/-msse2//' -i ./Makefile && \
  cd .. && \
  cd rabbit && \
  sed -e 's/-msse2//' -i ./Makefile && \
  cd .. && \
  cd dmlc-core && \
  sed -e 's/-msse2//' -i ./Makefile && \
  cd .. && \
  make -j4 && \
  make install && \
  cd python-package && \
  /usr/bin/python3 ./setup.py install

  cd /opt && \
  git clone --recursive https://github.com/dmlc/mxnet && \
  cd mxnet && \
  make -j USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=/usr/local/cuda USE_CUDNN=1 && \
  /usr/bin/pip3 install --upgrade graphviz mxnet

  cd /opt && \
  git clone https://github.com/google/protobuf.git && \
  cd protobuf && \
  git checkout v3.0.0 && \
  ./autogen.sh && ./configure && make && \
  make install

  cd /opt && \
  git clone https://github.com/grpc/grpc-java.git && \
  cd grpc-java && \
  git checkout v1.0.0 && \
  export CXXFLAGS="-I /opt/protobuf/src" LDFLAGS="-L /opt/protobuf/src/.libs" && \
  cd compiler && \
  GRPC_BUILD_CMD="../gradlew java_pluginExecutable" && \
  eval $GRPC_BUILD_CMD

  cd /opt && \
  git clone https://github.com/bazelbuild/bazel.git && \
  cd bazel && \
  export PROTOC=/opt/protobuf/src/protoc && \
  export GRPC_JAVA_PLUGIN=/opt/grpc-java/compiler/build/exe/java_plugin/protoc-gen-grpc-java && \
  ./compile.sh && \
  cd output && \
  export PATH=$(pwd):$PATH

  cd /opt && \
  git clone https://github.com/PPC64/tensorflow.git && \
  cd tensorflow && \
  ./configure && \
  bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package

  cd /opt && \
  git clone http://github.com/fbcotter/py3nvml && \
  cd py3nvml && \
  /usr/bin/python3 setup.py install

# Install H2o
  cd /opt && \
  wget https://s3.amazonaws.com/h2o-deepwater/public/nightly/deepwater-h2o-230/h2o.jar && \
  wget https://s3.amazonaws.com/h2o-beta-release/goai/h2oaiglm-0.0.2-py2.py3-none-any.whl && \
  wget http://s3.amazonaws.com/h2o-deepwater/public/nightly/deepwater-h2o-230/h2o-3.11.0.230-py2.py3-none-any.whl && \
  wget https://s3.amazonaws.com/h2o-deepwater/public/nightly/latest/mxnet-0.7.0-py2.7.egg && \
  /usr/bin/pip3 install --upgrade /opt/h2oaiglm-0.0.2-py2.py3-none-any.whl && \
  /usr/bin/pip3 install --upgrade /opt/h2o-3.11.0.230-py2.py3-none-any.whl && \
  git clone http://github.com/h2oai/perf
  
#ADD h2oai /opt/h2oai

  cd /opt && \
  wget https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/higgs_head_2M.csv && \
  wget https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/ipums_feather.gz
  /usr/bin/pip3 install --upgrade --user /opt/h2oaiglm-0.0.2-py2.py3-none-any.whl && \
  /usr/bin/pip3 install --upgrade --user /opt/h2o-3.11.0.230-py2.py3-none-any.whl && \
  rm -f /opt/*.whl
