10 REM THIS PROGRAM COMPUTES THE DETERMINANT AND
20 REM INVERSE OF A 2 X 2 MATRIX
30 PRINT "ENTER A11, A12";
40 INPUT A,B
50 PRINT "A21, A22";
60 INPUT C,D
70 LET E = (D*A) - (B*C)
80 LET F = D/E
90 LET G = - B/E
100 LET H = - C/E
110 LET I = A/E
120 PRINT "ORIGINAL MATRIX"
130 PRINT A,B
140 PRINT C,D
150 PRINT
160 PRINT "INVERSE OF MATRIX"
170 PRINT F,G
180 PRINT H,I
190 PRINT
200 PRINT "DETERMINANT = ";E
210 PRINT
220 PRINT "TYPE 1 TO CONTINUE, 0 TO STOP"
230 INPUT L
240 IF L = 1 THEN 30
250 STOP
260 PRINT
270 GOTO 30
280 END