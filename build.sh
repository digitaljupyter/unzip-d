export DMD=gdmd

"$DMD" --version > /dev/null || DMD=dmd

mkdir output > /dev/null || echo "output exists!"

gdmd unzip.d -release -inline -O -ofoutput/unzip

rm unzip.o