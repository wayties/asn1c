#!/bin/sh

ORIG="./.check-xxber.orig.$$.tmp"
TEST="./.check-xxber.test.$$.tmp"

# Test diff(1) capabilities
diff -a . . 2>/dev/null && diffArgs="-a"		# Assume text files
diff -u . . 2>/dev/null && diffArgs="$diffArgs -u"	# Unified diff output

cat<<EOM > $ORIG
<I O="0" T="[UNIVERSAL 16]" TL="2" V="Indefinite" A="SEQUENCE">
<P O="2" T="[UNIVERSAL 19]" TL="2" V="2" A="PrintableString">&#x55;&#x53;</P>
<C O="6" T="[UNIVERSAL 16]" TL="2" V="6" A="SEQUENCE">
<P O="8" T="[UNIVERSAL 2]" TL="2" V="4" A="INTEGER">&#x31;&#xa6;&#x20;&#x47;</P>
</C O="14" T="[UNIVERSAL 16]" A="SEQUENCE" L="8">
EOM

./enber $ORIG | ./unber -p -i 0 - > $TEST 2>&1
diff $diffArgs $ORIG $TEST >/dev/null 2>&1
diffExitCode=$?

if [ "$diffExitCode" = "0" ]; then
	echo "FAILED: $0: expected failure, got success"
	exit 42;
fi

# Append necessary terminator
echo '</I O="14" T="[UNIVERSAL 0]" TL="2" L="16">' >> $ORIG

# Try trancoding again
./enber $ORIG | ./unber -p -i 0 - > $TEST 2>&1

diff $diffArgs $ORIG $TEST
diffExitCode=$?

rm -f $ORIG $TEST

exit $diffExitCode
