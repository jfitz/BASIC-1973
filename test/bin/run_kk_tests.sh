TESTROOT=test
TESTBED=tests

echo Removing old directory
if [ -d "$TESTBED" ] ; then rm -r "$TESTBED" ; fi

echo Creating directory tests
mkdir "$TESTBED"

echo Running all tests...
ECODE=0

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk binom
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk china
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk convert
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk lrgfct
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk roots
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk sales
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk table
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk income
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk rc-sum
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk inverse_7
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk inverse_9
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk define
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk trig-1
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk trig-2
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk trig-3
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk zero-1
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk zero-2
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk zero-3
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk zero-4
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk mati-0
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk mati-1
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk matops
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk matmpy
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk matpwr
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk matinv
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk linequ
((ECODE+=$?))

bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk deal
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk dice
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk needle
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk knight
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk random_float
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk random_int
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk plot
((ECODE+=$?))
bash "$TESTROOT/bin/run_test.sh" "$TESTROOT" "$TESTBED" kk plotxy
((ECODE+=$?))

echo
echo Failures: $ECODE

