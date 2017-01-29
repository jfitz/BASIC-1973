20 DIM A[4,3],B[5,4]
25 DIM C[5,3]
40 MAT READ A
60 DATA 6,3,2,5,3,2,4,3,2,3,2,1
140 MAT READ B
160 DATA 1,3,4,2,1,5,3,6,2,4,2,5,1,6,3,2,3,1,0,2
235 REM  WE STEP THROUGH ROWS OF B  THE CARAVANS
240 FOR R=1 TO 5
255 REM WE STEP THROUGH COLUMNS OF MAT A
256 REM   THE TOLL BOOTH IDENTIFICATION
260 FOR C=1 TO 3
275 REM INITIALIZE C[R,C] HERE
280 LET C[R,C]=0
295 REM X  STEPS THROUGH THE ROWS OF A AND THE COLUMNS OF B
296 REM  THERE WE FIND 'TRUCKS BUSES CARS MOTORCYCLES'
297 REM  IN EACH ARRAY
300 FOR X=1 TO 4
320 LET C[R,C]=C[R,C]+B[R,X]*A[X,C]
335 REM  GO TO THE NEXT COLUMN OF B AND THE NEXT ROW OF A
340 NEXT X
355 REM GO TO THE NEXT COLUMN OF  MAT A
360 NEXT C
375 REM  GO TO THE NEXT ROW OF MAT B
380 NEXT R
500 PRINT "ROAD","TUNNEL","BRIDGE"
520 MAT PRINT C
999 END
