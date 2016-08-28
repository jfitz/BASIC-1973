echo Removing old directory
if [ -d tests ] ; then rm -r tests ; fi

echo Creating directory tests
mkdir tests

echo Running all tests...
ECODE=0

bash test/bin/run_test.sh coan prog-1-2-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-4-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-5-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-6-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-6-d
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-6-e
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-6-f
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-6-g
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-6-h
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-1-7-b
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-2-4-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-2-4-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-2-4-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-2-4-d
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-2-4-e
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-2-4-f
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-3-1-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-d
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-e
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-f
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-g
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-1-h
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-3-2-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-2-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-2-c
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-3-3-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-3-b
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-3-4-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-4-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-4-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-3-4-d
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-4-1-a --int-floor
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-1-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-1-c
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-4-2-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-2-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-2-c
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-4-3-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-3-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-3-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-3-d
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-3-e
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-4-4-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-d --ignore-rnd-arg
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-e
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-f
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-g
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-h --implied-semicolon
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-i --implied-semicolon
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-4-4-j --implied-semicolon
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-5-1-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-5-1-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-5-1-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-5-1-d
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-5-2-c
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-5-2-d
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-5-2-e
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-5-3-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-5-3-b
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-6-1-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-6-2-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-6-2-b
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-6-3-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-6-3-b
((ECODE+=$?))

bash test/bin/run_test.sh coan prog-7-1-a
((ECODE+=$?))
bash test/bin/run_test.sh coan prog-7-1-b
((ECODE+=$?))
# don't test programs from chapter 7 section 2
# -- they use subscripts for substrings
bash test/bin/run_test.sh coan prog-7-3-a
((ECODE+=$?))

echo
echo Failures: $ECODE

