90 REM * PRINT WITH IF END 'TRAP'
100 FILES TEST
110 IF  END #1 THEN 140
120 READ #1;X
130 GOTO 120
140 FOR I=1 TO 3
150 READ X
160 PRINT #1;X
170 PRINT X;
180 NEXT I
190 DATA 19,2,6
200 END
