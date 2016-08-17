echo Removing old directory
if [ -d tests ] ; then rm -r tests ; fi

echo Creating directory tests
mkdir tests

echo Running all tests...
ECODE=0

bash test/bin/run_coan_test.sh prog-1-2-a
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-4-a
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-5-a
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-6-a
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-6-d
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-6-e
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-6-f
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-6-g
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-6-h
((ECODE+=$?))
bash test/bin/run_coan_test.sh prog-1-7-b
((ECODE+=$?))

echo
echo Failures: $ECODE

