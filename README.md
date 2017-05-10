# H<sub>2</sub>O<sup>AI</sup>

Fast Scalable Machine Learning For Smarter Applications - http://h2o.ai

> Code less, kick butt, have fun, don't cheat, love your customers, change computing forever.

## Goals
- User interface (UI) is visual/web-based (no coding), targeted to the beginner/mid-level user (NoDataScientist)
- The black-box engine underneath has the following components:
 * SKLearn for prototypes
 * NumPy/Pandas - using Feather binary IO
 * data.table (eventually w GPU) - using Feather binary IO
 * XGBoost w GPU
 * TensorFlow w GPU
 * H2O w GPU (for production)
 * Spark (for production)
- Work flow is auto-generated from a specification document (state machine)
- UI is auto-generated from the specification
- Experiments are stored individually
 * Binary input (feather)
 * Feature Engr script (using data.table or pandas)
 * Modeling script (default XGBoost with 5-fold CV)
 * Text/JSON/etc. output containing the metric of the experiment
 
## Setup

Not ready yet. Compile from source instead.

## Compiling from source

- Install Node.js LTS using the [pre-built installer](https://nodejs.org/en/download/). 
- Install Python 3.6.
- Install [R](https://cran.r-project.org/mirrors.html), then `install.packages(c("data.table", "feather"))`.

Then do the following. YMMV depending on how hosed your Python/pip environment is.

```
# Clone git repo and set up python env.
cd ~
git clone https://github.com/h2oai/h2oai.git
cd h2oai
mkdir env
virtualenv -p python3 env
source env/bin/activate
pip3 install -r requirements.txt 

# Build and run H2O:
make
python3 -m h2o
```

Finally, point your browser to [http://localhost:12345](http://localhost:12345).

### Subsequent runs

Once you've set up your Python dependencies correctly, subsequent git pull/make should be easier:

```
# Update from git and activate python env.
cd ~/h2oai
git pull
source env/bin/activate

# Build and run H2O:
make
python3 -m h2o
```

### Notes

- Run `make help` to list all `make` tasks.
- [PyCharm](https://www.jetbrains.com/pycharm/download/) is recommended for development. Point PyCharm to your virtualenv.
- See [h2o/static/README.md](h2o/static/README.md) for GUI/Typescript development configuration.
- To make the application auto-restart on Python source code changes, use `python3 -m h2o --debug`.
- To limit the number of worker processes, use `python3 -m h2o --max-workers=1` (defaults to number of processors).
- To start the application in **GUI Kitchensink** mode, use `python3 -m h2o --workflow=ui`. This is mainly a design/development mode for UI components, and not intended to be customer-facing.

### Troubleshooting

- Because of browser caching, you're likely to see an older version of the UI even though you have rebuilt the project. To disable this in Chrome, open up Google Chrome's DevTools,  select *Main Menu > Settings > Network*, then select *"Disable cache (while DevTools is open)"*
- If you run into errors installing xgboost on OSX, try again after `brew install gcc --without-multilib`. If you have gcc > 6.0, install gcc 5 using `brew install gcc@5 --without-multilib`.
- If you have an issue installing feather-format on a Mac OS, then try `export MACOSX_DEPLOYMENT_TARGET=10.10`.
- There are also some issues if you have other distributions of Python3 installed, i.e., Python 3.5. In that case, it is best practice to run `pip3.6 install ...` instead of `pip3.5 install ...` to ensure you are using the correct version of Python.

## Running From Docker
After running `make` simply run `docker build -t opsh2oai/h2oai .` and then `docker run -d -v /home/markc/H2O/h2o-3/smalldata:/smalldata -p 12345:12345 opsh2oai/h2oai`. Then point your browser to localhost:54321 and load data from `/smalldata` directory

## This guide is for installing h2oai if you want/have anaconda. 

####Anaconda Install (If you dont have it) 
1. Make sure you do not have Python3 installed, atleast not in your path. 
2. Download  Anaconda Anaconda3-4.3.1-MacOSX-x86_64.sh - which is Python3.6
3. Change the permissions to executable with `chmod +x Anaconda3-4.3.1-MacOSX-x86_64.sh"
4. Now execute with ./Anaconda3-4.3.1-MacOSX-x86_64.sh
5. Follow thru all prompts
6. Add the export PATH=/Users/`whoami`/anaconda3:$PATH (or your-personal-loc:$PATH)
6. Check that python3 and pip3 are pointing to the Anaconda python and pip. 

####Installing and running h2oai
1. Follow through the guide up till activating python environment
2. If you are on a mac and run the pip3 install -r requirements then while installing feather you will get the following error,
"#include <cstdint> file not found" error. 
3. For that you need to run "export MACOSX_DEPLOYMENT_TARGET=10.10"
4. Follow that with "pip3 install -r requirements"
5. make
6. and finally python3 -m h2o 

####Special Case
1. This case applies to some people who manually link and unlink their python command to python2.7 and python3 as required (similarly, link and unlink pip2.7 and pip3 to pip) 
2. In this case you do not need to activate a virtualenv you can directly go to "pip install -r requirements" or do the 3rd step in Install and then follow with pip, in case of a MAC
