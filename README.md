# PM10_BAYESIAN
This projects contain (almost) all the work done for the Bayesian Project a.y 2022/2023

The repository contains as module the bayesmix library, so to check it out properly you have to type

```
git clone --recursive https://github.com/eugeniovaretti/PM10_BAYESIAN
```
or

```
git clone --recursive git@github.com:eugeniovaretti/PM10_BAYESIAN
```
In the latter case you have to register your ssh keys on a github account.

After the cloning of the PM_10 project, you need to set up bayesmix to run properly the code.  
To build the executable for the main file `run_mcmc.cc`, please use the following list of commands:
```
git submodule update
cd bayesmix
mkdir build
cd build
cmake .. -DDISABLE_TESTS=ON
make run_mcmc
cd ..
cd ..
```


# Only for "interested" users
To download bayesmix 's updates type
```
cd bayesmix
git pull origin master
cd ..
```
If there are updates, after having verified that your working tree is clean (git status to check) do:
```
git add bayesmix
git commit -m "Downloaded bayesmix updates"
git push
```
