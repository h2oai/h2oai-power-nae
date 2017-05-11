FROM nimbix/ubuntu-cuda-ppc64le:latest
MAINTAINER H2o.ai <ops@h2o.ai>

ENV DEBIAN_FRONTEND noninteractive

# Notebook Common
ADD https://raw.githubusercontent.com/nimbix/notebook-common/master/install-ubuntu.sh /tmp/install-ubuntu.sh
RUN \
  bash /tmp/install-ubuntu.sh 3 && \
  rm -f /tmp/install-ubuntu.sh

# General Packaging
RUN \
  apt-get -y install \
  python-software-properties \
  software-properties-common \
  iputils-ping \
  cpio 

# Setup Repos
RUN \
  echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list && \
  gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
  gpg -a --export E084DAB9 | apt-key add -&& \
  add-apt-repository -y ppa:openjdk-r/ppa && \
  apt-get update -yqq

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-ppc64el
ENV JRE_HOME /usr/lib/jvm/java-8-openjdk-ppc64el/jre
ENV CLASSPATH /usr/lib/jvm/java-8-openjdk-ppc64el/lib:/usr/lib/jvm/java-8-openjdk-ppc64el/jre/lib
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH

# Install H2o dependancies
RUN \
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
    libtool \
    build-essential \
    unzip \
    pkg-config \
    libfreetype6-dev \
    git \
    libopencv-dev \
    openjdk-8-jdk

# Install Python Dependancies
COPY requirements.txt /opt/requirements.txt
COPY conf/cuda.conf /etc/ld.so.conf.d/cuda.conf

#RUN \
#  cd /opt && \
#  wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz && \
#  tar -zxvf Python-3.6.1.tgz && \
#  cd Python-3.6.1 && \
#  ./configure --enable-optimizations && \
#  make altinstall && \
#  python3.6 -V

RUN \
  /usr/bin/pip3 install --upgrade pip && \
  /usr/bin/pip3 install --upgrade numpy && \
  /usr/bin/pip3 install --upgrade cython && \
  /usr/bin/pip3 install --upgrade scipy && \
  /usr/bin/pip3 install -r /opt/requirements.txt && \ 
# /usr/local/bin/python3.6 -m pip install --upgrade pip && \
# /usr/local/bin/python3.6 -m pip install --upgrade numpy && \
# /usr/local/bin/python3.6 -m pip install --upgrade cython && \
# /usr/local/bin/python3.6 -m pip install -r /opt/h2oai/requirements.txt && \
# /usr/local/bin/python3.6 -m pip install --upgrade notebook && \
  apt-get clean && \
  rm -rf /var/cache/apt/*

# Build Xgboost
RUN \
  cd /opt && \
  wget https://s3.amazonaws.com/h2o-beta-release/ppc64le/xgboost-0.6-py35-none-any.whl && \
  /usr/bin/pip3 install /opt/xgboost-0.6-py35-none-any.whl


# Build mxnet
RUN \
  cd /opt && \
  git clone --recursive https://github.com/dmlc/mxnet && \
  cd /opt/mxnet && \
  make -j USE_BLAS=openblas USE_CUDA=1 USE_CUDA_PATH=/usr/local/cuda USE_CUDNN=1 && \
  /usr/bin/pip3 install --upgrade graphviz

# Build Protobuf
#RUN \
#  cd /opt && \
#  git clone https://github.com/google/protobuf.git && \
#  cd /opt/protobuf && \
#  git config user.email "ops@h2o.ai" && \
#  git config user.name "ops@h2oai" && \
#  git checkout v3.0.0 && \
#  git git cherry-pick 1760feb621a913189b90fe8595fffb74bce84598 && \
#  ./autogen.sh && ./configure && make

# Build Grpc
#RUN \
#  cd /opt && \
#  git clone https://github.com/grpc/grpc-java.git && \
#  cd /opt/grpc-java && \
#  git checkout v1.0.0 && \
#  export CXXFLAGS="-I /opt/protobuf/src" LDFLAGS="-L /opt/protobuf/src/.libs" && \
#  cd /opt/grpc-java/compiler && \
#  GRPC_BUILD_CMD="../gradlew java_pluginExecutable" && \
#  eval $GRPC_BUILD_CMD

# Build Bazel
#RUN \
#  cd /opt && \
#  git clone https://github.com/bazelbuild/bazel.git && \
#  cd /opt/bazel && \
#  export PROTOC=/opt/protobuf/src/protoc && \
#  export GRPC_JAVA_PLUGIN=/opt/grpc-java/compiler/build/exe/java_plugin/protoc-gen-grpc-java && \
#  ./compile.sh && \
#  cd /opt/bazel/output && \
#  export PATH=$(pwd):$PATH

# Build Tensorflow
#RUN \
#  cd /opt && \
#  git clone https://github.com/PPC64/tensorflow.git && \
#  cd tensorflow && \
#  ./configure && \
#  bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package

# Build py3nvml
RUN \
  cd /opt && \
  git clone http://github.com/fbcotter/py3nvml && \
  cd py3nvml && \
  /usr/bin/python3 setup.py install

# Install H2o
RUN \
  cd /opt && \
  wget https://s3.amazonaws.com/h2o-deepwater/public/nightly/deepwater-h2o-230/h2o.jar && \
  wget https://s3.amazonaws.com/h2o-beta-release/goai/h2oaiglm-0.0.2-py2.py3-none-any.whl && \
  wget http://s3.amazonaws.com/h2o-deepwater/public/nightly/deepwater-h2o-230/h2o-3.11.0.230-py2.py3-none-any.whl && \
  wget https://s3.amazonaws.com/h2o-deepwater/public/nightly/latest/mxnet-0.7.0-py2.7.egg && \
  /usr/bin/pip3 install --upgrade /opt/h2oaiglm-0.0.2-py2.py3-none-any.whl && \
  /usr/bin/pip3 install --upgrade /opt/h2o-3.11.0.230-py2.py3-none-any.whl && \
  git clone http://github.com/h2oai/perf
  
#ADD h2oai /opt/h2oai

RUN \
  cd /opt && \
  wget https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/higgs_head_2M.csv && \
  wget https://s3.amazonaws.com/h2o-public-test-data/bigdata/laptop/ipums_feather.gz

# Add bash scripts
COPY scripts/start-h2o.sh /opt/start-h2o.sh
COPY scripts/run-benchmark.sh /opt/run-benchmark.sh
COPY scripts/start-h2oai.sh /opt/start-h2oai.sh
COPY scripts/start-notebook.sh /opt/start-notebook.sh
COPY scripts/java.sh /etc/profile.d/java.sh
#COPY scripts/bazel.sh /etc/profile.d/bazel.sh

# Set executable on scripts
RUN \
  chown -R nimbix:nimbix /opt && \
  chmod +x /opt/start-h2o.sh && \
  chmod +x /opt/start-h2oai.sh && \
  chmod +x /opt/run-benchmark.sh && \
  chmod +x /opt/start-notebook.sh

EXPOSE 54321
EXPOSE 8888
EXPOSE 12345

# User python install
USER nimbix

RUN \
  /usr/bin/pip3 install --upgrade --user /opt/h2oaiglm-0.0.2-py2.py3-none-any.whl && \
  /usr/bin/pip3 install --upgrade --user /opt/h2o-3.11.0.230-py2.py3-none-any.whl && \
  rm -f /opt/*.whl

# Nimbix Integrations
COPY NAE/AppDef.json /etc/NAE/AppDef.json
COPY NAE/AppDef.png /etc//NAE/default.png
COPY NAE/screenshot.png /etc/NAE/screenshot.png
