10 READ N
20 FOR D=2 TO SQR(N)
30 IF N/D=INT(N/D) THEN 70
40 NEXT D
50 PRINT N;"IS PRIME"
60 GOTO 10
70 PRINT N/D;"IS THE GREATEST FACTOR OF";N
80 GOTO 10
90 DATA 1946,1949,1009,1003
100 DATA 11001,240,11
110 END

