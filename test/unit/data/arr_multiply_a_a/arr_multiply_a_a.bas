10 REM ARRAY ASSIGNMENT
20 DIM A(6), B(6)
30 DATA 1,2,3,4,5,6
40 DATA 7,8,9,10,11,12
100 FOR I = 0 TO 5
120 READ A(I)
140 NEXT I
150 PRINT "ARRAY A"
160 ARR PRINT A;
200 FOR I = 0 TO 5
220 READ B(I)
240 NEXT I
250 PRINT "ARRAY B"
260 ARR PRINT B;
300 ARR C = A*B
310 PRINT "ARRAY C"
320 ARR PRINT C;
999 END
