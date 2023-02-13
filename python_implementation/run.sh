
niter=10
nburn=0
a=2

for M in 0.567
do
    echo M = $M    a = $a
    python3 -W ignore script.py $a $M $niter $nburn
    echo
done
