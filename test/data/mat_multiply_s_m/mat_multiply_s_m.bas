10 REM MATRIX ASSIGNMENT
20 DIM A(5,5)
30 FOR I = 1 TO 5
40 FOR J = 1 TO 5
50 LET A(I,J) = I+J
60 NEXT J
70 NEXT I
100 MAT B = 2 * A
110 PRINT "MATRIX A"
120 MAT PRINT A;
130 PRINT "MATRIX B"
140 MAT PRINT B;
999 END

