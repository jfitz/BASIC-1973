10 REM TEST MAT PRINT USING
12 OPTION BASE 1
20 DIM A(3,4), B(4,3)
30 FOR I = 1 TO 3
31 FOR J = 1 TO 4
32 LET A(I,J) = I / J
33 NEXT J
34 NEXT I
40 FOR I = 1 TO 4
41 FOR J = 1 TO 3
42 LET B(I,J) = 3.14159 * I / J
43 NEXT J
44 NEXT I
50 PRINT "MAT PRINT WITH COMMA"
52 MAT PRINT USING "###.##", A
60 PRINT "MAT PRINT WITH SEMICOLON"
62 MAT PRINT USING "###.##"; A
99 END
