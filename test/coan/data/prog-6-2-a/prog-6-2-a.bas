10 READ N
20 PRINT N;"BASE TEN =";
30 FOR E=20 TO 0 STEP -1
40 LET I=INT(N/2^E)
50 PRINT I;
60 LET R=N-I*2^E
70 LET N=R
80 NEXT E
85 PRINT "BASE TWO"
86 PRINT
90 GOTO 10
100 DATA 999999.,1,16
110 END
