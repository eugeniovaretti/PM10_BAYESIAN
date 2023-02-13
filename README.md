# PM10_BAYESIAN
This projects contain (almost) all the work done for the course of Bayesian Statistic a.y 2022/2023 for the MSc. Mathematical Engineering, Politecnico di Milano.  

# Installation

## For end users
The repository contains as module the 'bayesmix' library, a C++ library for running MCMC simulations in Bayesian mixture models.

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


## How to build 'bayesmix'
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

# Authors
Tutor: Matteo Gianella (@TeoGiane)

- Carnevali Davide 
- Gurrieri Davide (@davide-gurrieri)
- Moroni Sofia (@SofiaMoroni9)
- Rescalli Sara 
- Varetti Eugenio (@eugeniovaretti)
- Zelioli Chiara  

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
