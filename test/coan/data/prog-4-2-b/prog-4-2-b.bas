5 PRINT "NUMERATOR","DENOMINATOR","REMAINDER","INTEGER QUOTIENT"
10 READ N,D
15 REM FIND THE REMAINDER WHEN 'N' IS DIVIDED BY 'D'
20 LET R=N-INT(N/D)*D
30 PRINT N,D,R,INT(N/D)
40 GOTO 10
50 DATA 93,12,100,25,365,52,365,7
52 DATA 365,12,52,13,5280,440,55,6
60 END

