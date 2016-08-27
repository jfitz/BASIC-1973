echo Removing old directory
if [ -d tests ] ; then rm -r tests ; fi

echo Creating directory tests
mkdir tests

echo Running all tests...
ECODE=0

bash test/bin/run_test.sh ahl bounce
((ECODE+=$?))

echo
echo Failures: $ECODE

