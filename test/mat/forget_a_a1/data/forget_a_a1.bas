10 REM Test the FORGET statement
11 OPTION BASE 1
20 DIM A(3,4)
21 FOR I = 1 TO 3
22 FOR J = 1 TO 4
23 LET A(I,J) = I*J
24 NEXT J
25 NEXT I
30 DIM A1(2,6)
31 FOR I = 1 TO 2
32 FOR J = 1 TO 6
33 LET A1(I,J) = I/J
34 NEXT J
35 NEXT I
40 MAT PRINT A
41 MAT PRINT A1
50 MAT FORGET A
90 MAT PRINT A1
91 MAT PRINT A
99 END