10 REM TEST PLOT TO FILE
20 FILES "output.txt"
30 ARR LET A = RND1(20)
40 ARR LET A1 = A - 0.5
50 ARR LET A2 = A - 0.9
60 ARR LET A3 = A - 20
70 ARR PLOT #1;A,A1,A2,A3
99 END