10 REM TEST FOR EPSILON OPTION
100 PRINT "VALUES WITH EPSILON 1E-4"
110 LET A = 1/7
120 OPTION EPSILON 1E-4
130 FOR I = 1 TO 10
140 PRINT A
150 LET A = A / 10
160 NEXT I
200 PRINT "VALUES WITH EPSILON 1E-10"
210 LET A = 1/7
220 OPTION EPSILON 1E-10
230 FOR I = 1 TO 12
240 PRINT A
250 LET A = A / 10
260 NEXT I
999 END
