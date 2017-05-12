echo "==French->Catalan==========================";
bash inconsistency.sh fra-cat ../../../apertium-fra/.deps/fra.dix > /tmp/fra-cat.testvoc; bash inconsistency-summary.sh /tmp/fra-cat.testvoc fra-cat 
echo ""
echo "==Catalan->French===========================";
bash inconsistency.sh cat-fra ../../../apertium-cat/apertium-cat.cat.dix > /tmp/cat-fra.testvoc; bash inconsistency-summary.sh /tmp/cat-fra.testvoc cat-fra
