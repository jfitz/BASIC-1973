TESTROOT=test
TESTBED=tests

echo Removing old directory
if [ -d "$TESTBED" ] ; then rm -r "$TESTBED" ; fi

echo Creating directory tests
mkdir "$TESTBED"

echo Running all tests...
ECODE=0

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" ahl bounce
((ECODE+=$?))

echo
echo Failures: $ECODE

