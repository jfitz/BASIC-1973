10 REM THIS PROGRAM COMPUTES VALUE DEPRECIATION
20 REM BY THE STRAIGHT LINE METHOD
30 PRINT "ORIGINAL VALUE = ";
40 INPUT A
50 PRINT "LIFETIME IN YEARS = ";
60 INPUT B
70 LET C = A/B
80 PRINT "YEARLY DEPRECIATION = ";C
90 PRINT
100 PRINT "YEAR","VALUE"
110 LET X = 0
120 LET X = X + 1
130 LET A = A - C
140 IF A < 0 THEN 160
150 GOTO 170
160 LET A = 0
170 PRINT X,A
180 IF X < B THEN 120
190 PRINT "********************"
200 PRINT "TYPE 1 TO CONTINUE, 0 TO STOP"
210 INPUT L
220 IF L = 1 THEN 240
230 STOP
240 PRINT
250 GOTO 30
260 END
