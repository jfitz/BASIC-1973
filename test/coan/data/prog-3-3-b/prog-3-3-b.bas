10 REM 20 TO 40 READ THE A LIST
20 FOR I=1 TO 4
30 READ A[I]
40 NEXT I
45 REM 50 TO 65 READ THE B LIST
50 FOR J=1 TO 4
60 READ B[J]
65 NEXT J
67 REM HERE IS ANOTHER NESTED LOOP
70 FOR K=1 TO 4
80 FOR L=1 TO 4
90 PRINT A[K];B[L],
91 REM *** NOTICE THE USE OF THE SEMICOLON AND THE COMMA
100 NEXT L
110 PRINT
120 NEXT K
500 DATA 1,3,5,7
510 DATA 2,3,6,9
999 END
