for iloop in $(ls *.yaml | grep -v secrets | grep -v local_) ; do
   echo
   echo "#########################################"
   echo Converting $iloop to local_$iloop
   python ./tools/convert_to_local_source.py $iloop || exit 1
done
for iloop in $(ls local_*.yaml); do
   filename=$(basename $iloop)
   echo
   echo Verifying $iloop
   esphome config $iloop || exit 1
done
for iloop in $(ls local_*.yaml); do
   echo
   echo Compiling $iloop
   esphome compile $iloop || exit 1
done
