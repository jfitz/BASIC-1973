10 REM TEST ARR PRINT USING
12 OPTION BASE 1
20 DIM A(4), B(5)
30 FOR I = 1 TO 4
31 LET A(I) = 10 / I
32 NEXT I
40 FOR I = 1 TO 5
41 LET B(I) = 3.14159 * I
42 NEXT I
50 PRINT "ARR PRINT WITH COMMA"
52 ARR PRINT USING "##.##", A, B
60 PRINT "ARR PRINT WITH SEMICOLON"
62 ARR PRINT USING "##.##"; A; B
99 END
