10 REM THIS PROGRAM COMPUTES THE FIRST DERIVATIVE
20 REM OF A FUNCTION ENTERED BY THE USER
30 PRINT "VALUE OF X = ";
40 INPUT X
50 LET Y = X
60 LET Z = (X*(1E-04))/2
70 LET W = X + Z
80 LET V = X - Z
90 LET X = W
100 GOSUB 280
110 LET A = P
120 LET X = V
130 GOSUB 280
140 LET B = P
150 LET X = Y
160 GOSUB 280
170 LET C = P
180 LET F = (A - B)/(2*Z)
190 PRINT "IF X = ";Y,"THEN F(X) = ";C
200 PRINT "AND F'(X) = ";F
210 PRINT
220 PRINT "TYPE 1 TO CONTINUE, 0 TO STOP"
230 INPUT L
240 IF L = 1 THEN 260
250 STOP
260 PRINT
270 GOTO 40
280 LET P = X^2
290 RETURN
300 END
