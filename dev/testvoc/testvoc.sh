echo "==French->Catalan==========================";
bash inconsistency.sh fra-cat ../../../../languages/apertium-fra/.deps/fra.dix > /tmp/fra-cat.testvoc; bash inconsistency-summary.sh /tmp/fra-cat.testvoc fra-cat 
echo ""
echo "==Catalan->French===========================";
bash inconsistency.sh cat-fra ../../../../languages/apertium-cat/apertium-cat.cat.dix > /tmp/cat-fra.testvoc; bash inconsistency-summary.sh /tmp/cat-fra.testvoc cat-fra
