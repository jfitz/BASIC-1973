echo Removing old directory
if [ -d tests ] ; then rm -r tests ; fi

echo Creating directory tests
mkdir tests

echo Running all tests...
ECODE=0

bash test/bin/run_test.sh kk binom
((ECODE+=$?))
bash test/bin/run_test.sh kk china
((ECODE+=$?))

bash test/bin/run_test.sh kk convert
((ECODE+=$?))
bash test/bin/run_test.sh kk lrgfct
((ECODE+=$?))

bash test/bin/run_test.sh kk roots
((ECODE+=$?))
bash test/bin/run_test.sh kk sales
((ECODE+=$?))

bash test/bin/run_test.sh kk table
((ECODE+=$?))
bash test/bin/run_test.sh kk income
((ECODE+=$?))
bash test/bin/run_test.sh kk rc-sum
((ECODE+=$?))

bash test/bin/run_test.sh kk inverse_7
((ECODE+=$?))
bash test/bin/run_test.sh kk inverse_9
((ECODE+=$?))

bash test/bin/run_test.sh kk define
((ECODE+=$?))

bash test/bin/run_test.sh kk trig-1
((ECODE+=$?))
bash test/bin/run_test.sh kk trig-2
((ECODE+=$?))
bash test/bin/run_test.sh kk trig-3
((ECODE+=$?))

bash test/bin/run_test.sh kk zero-1
((ECODE+=$?))
bash test/bin/run_test.sh kk zero-2
((ECODE+=$?))
bash test/bin/run_test.sh kk zero-3
((ECODE+=$?))
bash test/bin/run_test.sh kk zero-4
((ECODE+=$?))

bash test/bin/run_test.sh kk mati-0
((ECODE+=$?))
bash test/bin/run_test.sh kk mati-1
((ECODE+=$?))
bash test/bin/run_test.sh kk matops
((ECODE+=$?))
bash test/bin/run_test.sh kk matmpy
((ECODE+=$?))
bash test/bin/run_test.sh kk matpwr
((ECODE+=$?))
bash test/bin/run_test.sh kk matinv
((ECODE+=$?))
bash test/bin/run_test.sh kk linequ
((ECODE+=$?))

bash test/bin/run_test.sh kk deal
((ECODE+=$?))
bash test/bin/run_test.sh kk dice
((ECODE+=$?))
bash test/bin/run_test.sh kk needle
((ECODE+=$?))
bash test/bin/run_test.sh kk knight
((ECODE+=$?))
bash test/bin/run_test.sh kk random_float
((ECODE+=$?))
bash test/bin/run_test.sh kk random_int
((ECODE+=$?))
bash test/bin/run_test.sh kk plot
((ECODE+=$?))
bash test/bin/run_test.sh kk plotxy
((ECODE+=$?))

echo
echo Failures: $ECODE

