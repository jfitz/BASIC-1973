10 REM MATRIX ASSIGNMENT
20 DIM A(5,5),B(5,5)
30 FOR I = 1 TO 5
40 FOR J = 1 TO 5
50 LET A(I,J) = I+J
52 LET B(I,J) = I*J
60 NEXT J
70 NEXT I
100 MAT C = A + B
110 PRINT "MATRIX A"
120 MAT PRINT A
130 PRINT "MATRIX B"
140 MAT PRINT B
150 PRINT "MATRIX C"
160 MAT PRINT C
999 END

