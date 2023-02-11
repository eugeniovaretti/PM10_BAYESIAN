
niter=2000
nburn=1000
a=38.55

for a in 10 20 30 40 50 60
do
    for M in 0.1 0.5 1 1.5 2
    do
        echo M = $M    a = $a
        python3 -W ignore script.py $a $M $niter $nburn
        echo
    done
done
