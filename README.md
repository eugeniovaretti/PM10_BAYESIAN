# PM10_BAYESIAN
This projects contain (almost) all the work done for the course of Bayesian Statistic a.y 2022/2023 for the MSc. Mathematical Engineering, Politecnico di Milano.  

# Installation

## For end users
The repository contains as module the `bayesmix` library, a C++ library for running MCMC simulations in Bayesian mixture models.

**Prerequisites**: to build `bayesmix` you will need `git`, `pkg-config` and a recent version of `cmake`.

On Linux machines, it is sufficient to run
```shell
 sudo apt-get -y update && apt-get install -y
 sudo apt-get -y install git
 sudo apt-get -y install python3-pip
 sudo python3 -m pip install cmake
 sudo apt-get install -yq pkg-config
```

On macOS, after install HomeBrew, replace `sudo apt-get -y` with `brew`.

To install and use the repository, please 'cd' to the folder you wish to install it, and clone it through the following command-line instructions:

```shell
git clone --recursive https://github.com/eugeniovaretti/PM10_BAYESIAN
```
or

```shell
git clone --recursive git@github.com:eugeniovaretti/PM10_BAYESIAN
```
In the latter case you have to register your ssh keys on a github account.


## How to build `bayesmix`
You need to set up bayesmix to run properly the code.  
To build the executable for the main file `run_mcmc.cc`, please use the following list of commands:
```shell
git submodule update
cd bayesmix
mkdir build
cd build
cmake .. -DDISABLE_TESTS=ON
make run_mcmc
cd ..
cd ..
```

# Reproducibility  
This section is intended for any user who wants to run the analysis to reproduce the same results, or for any user who wants to analyze results with different hyperparameter values (in particular, the code is optimized and automated to test grids of totalmass (`totalmass`) and distance (`a`) values), or for those who want to apply the same model to their own data.  
The repository is structured as follow:
- `bayesmix` : contains the submodule that performs the MCMC simulations  
- `input_data` : contains all the input data (time series and covariates for the model)
- `output_plot` : empty folder useful to collect results when the `main.Rmd` and the algorithm are runned
- `python_implementation` : contains the vanilla python implementation of the model. It is useful to better (and easily) understand the algorithm and the model implementation. In addition, it is useful for comparing performances of the same algorithm implemented in C++ (much faster). 
- `utils` : contains the utilities developed for the main script
- `main.Rmd` : 
- `run.sh` : 

# Authors  
Tutor: Matteo Gianella ([@TeoGiane](https://github.com/TeoGiane))

- Carnevali Davide ([@DavideCarne](https://github.com/DavideCarne))
- Gurrieri Davide ([@davide-gurrieri](https://github.com/davide-gurrieri))
- Moroni Sofia ([@SofiaMoroni9](https://github.com/SofiaMoroni9))
- Rescalli Sara ([@rescallisara](https://github.com/rescallisara))
- Varetti Eugenio ([@eugeniovaretti](https://github.com/eugeniovaretti))
- Zelioli Chiara ([@Zeliolina](https://github.com/Zeliolina))

# Only for "interested" users  
To download bayesmix 's updates type
```shell
cd bayesmix
git pull origin master
cd ..
```
If there are updates, after having verified that your working tree is clean ('git status' to check) do:
```shell
git add bayesmix
git commit -m "Downloaded bayesmix updates"
git push
```
