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



To download bayesmix 's updates type
```
cd PM10_BAYESIAN/bayesmix
git pull origin master
cd ..
```

To build the executable for the main file `run_mcmc.cc`, please use the following list of commands:
```
mkdir build
cd build
cmake .. -DDISABLE_TESTS=ON
make run_mcmc
cd ..
```

If there are updates, after having verified that your working tree is clean (git status to check) do:
```
git add bayesmix
git commit -m "Downloaded bayesmix updates"
git push
```
