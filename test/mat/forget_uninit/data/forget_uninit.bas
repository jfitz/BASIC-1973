10 REM Test the FORGET statement
11 OPTION BASE 1
12 OPTION REQUIRE_INITIALIZED TRUE
20 DIM A(3,4)
21 FOR I = 1 TO 3
22 FOR J = 1 TO 4
23 LET A(I,J) = I*J
24 NEXT J
25 NEXT I
30 MAT PRINT A
40 MAT FORGET B
90 MAT PRINT A
99 END
