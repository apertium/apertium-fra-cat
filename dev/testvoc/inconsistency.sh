TMPDIR=/tmp

if [[ $1 = "cat-fra" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../cat-fra.autobil.bin |\
        lrx-proc -m ../../cat-fra.autolex.bin |\
        apertium-transfer -b ../../apertium-fra-cat.cat-fra.t1x  ../../cat-fra.t1x.bin | tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../cat-fra.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

elif [[ $1 = "fra-cat" ]]; then

lt-expand $2 | grep -v REGEX | grep -v '<prn><enc>' | sed 's/:>:/%/g' | grep -v ':<:' | sed 's/:/%/g' | cut -f2 -d'%' |  sed 's/^/^/g' | sed 's/$/$ ^.<sent>$/g' | tee $TMPDIR/tmp_testvoc1.txt |\
        apertium-pretransfer|\
        lt-proc -b ../../fra-cat.autobil.bin |\
        lrx-proc -m ../../fra-cat.autolex.bin |\
        apertium-transfer -b ../../apertium-fra-cat.fra-cat.t1x  ../../fra-cat.t1x.bin  | tee $TMPDIR/tmp_testvoc2.txt |\
        lt-proc -d ../../fra-cat.autogen.bin > $TMPDIR/tmp_testvoc3.txt
paste -d _ $TMPDIR/tmp_testvoc1.txt $TMPDIR/tmp_testvoc2.txt $TMPDIR/tmp_testvoc3.txt | sed 's/\^.<sent>\$//g' | sed 's/_/   --------->  /g' | grep -v '\^@'

else
	echo "sh inconsistency.sh <direction>";
fi
