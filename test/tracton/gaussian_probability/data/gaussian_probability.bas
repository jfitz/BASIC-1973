10 REM THIS PROGRAM COMPUTES THE GAUSSIAN PROBABILITY
20 REM FUNCTION OF X
30 PRINT "X = ";
40 INPUT X
50 LET A = EXP(-(X^2)/2)
60 LET B = .398942
70 LET C = B*A
80 PRINT "F(X) = ";C
90 PRINT
100 PRINT "TO CONTINUE TYPE 1, 0 TO STOP"
110 INPUT L
120 IF L = 1 THEN 140
130 STOP
140 PRINT
150 GOTO 30
160 END
