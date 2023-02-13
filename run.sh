
if [ $# -eq 0 ]; then
    a=250
    M=0.567
else
  a=$1
  M=$2
fi

touch bayesmix/examples/ar1nig_hierarchy/in/dp.asciipb
printf "fixed_value {\n  totalmass: "$M"\n  a: "$a"\n}" > bayesmix/examples/ar1nig_hierarchy/in/dp.asciipb

touch used_parameters.txt
printf ""$M"\n"$a"\n" > used_parameters.txt

echo "run the c++ algorithm"
echo
cd bayesmix
examples/ar1nig_hierarchy/runsingle.sh
