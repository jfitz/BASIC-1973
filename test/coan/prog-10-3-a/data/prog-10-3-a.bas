10 PRINT "TAKE ROOTS OF COMPLEX NUMBERS IN POLAR FORM"
20 READ R,G,N
30 PRINT "THE";N;",";N;"TH ROOTS OF (";R;",";G;") ARE:"
40 FOR X=1 TO N
50 PRINT "(";R^(1/N);",";G/N;")"
60 LET G=G+360
70 NEXT X
80 PRINT
90 GOTO 20
100 DATA 1,0,4
110 DATA 1,0,3
120 DATA 1,45,2
130 DATA 3,90,3
140 END