gsed "1,2d" $1.xyz > $1.gen
gawk '{print $1}' $1.gen  |sort|uniq > atoms.tmp
atoms=`gawk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' atoms.tmp`
gawk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' atoms.tmp > atoms2.tmp
cat -n $1.gen > $1.tmp
cp $1.tmp $1.gen
line=`wc -l <$1.gen`
#gsed -i "s/Ti/1/g" $1.gen
#gsed -i "s/O/2/g" $1.gen
atomline=`wc -l < atoms.tmp`
for ((i=1; i<=$atomline;i++)); do
atom=`gsed -n "${i}p" atoms.tmp` 
gsed -i "s/$atom/$i/g" $1.gen
done
#for i in $(wc -l < atoms.tmp); do
#gsed -i "s/Ti/$i/g" $1.gen
#done
#gsed -i "2s/^/Ti O\n/" $1.gen
gsed -i "1s/^/$line $2\n/" $1.gen
gsed -i "2s/^/$atoms\n/" $1.gen

if [ $2 == 'S' ]
then
   echo "0.000000 0.000000 0.00000" >> $1.gen
   cat $3 >> $1.gen
   echo ".gen file is generated for periodic system in cartesian coordinate"
else
   echo ".gen file is generated for molecular system in cartesian coordinate"
fi
rm *.tmp

