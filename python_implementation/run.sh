
niter=240
nburn=40
a=38.55

for M in 0.01
do
    echo M = $M    a = $a
    python3 -W ignore script.py $a $M $niter $nburn
    echo
done
