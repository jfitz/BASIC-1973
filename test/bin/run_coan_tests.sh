echo Removing old directory
if [ -d tests ] ; then rm -r tests ; fi

echo Creating directory tests
mkdir tests

echo Running all tests...
ECODE=0

bash test/bin/run_coan_test.sh read-data
((ECODE+=$?))
bash test/bin/run_coan_test.sh let
((ECODE+=$?))
bash test/bin/run_coan_test.sh input
((ECODE+=$?))
bash test/bin/run_coan_test.sh page_7_1
((ECODE+=$?))
bash test/bin/run_coan_test.sh page_7_2
((ECODE+=$?))
bash test/bin/run_coan_test.sh page_7_3
((ECODE+=$?))
bash test/bin/run_coan_test.sh page_8_1
((ECODE+=$?))

echo
echo Failures: $ECODE

