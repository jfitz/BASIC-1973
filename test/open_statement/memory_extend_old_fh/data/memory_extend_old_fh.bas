10 REM TEST OPEN OUTPUT
20 RECORD A,B,C
30 OPEN #2, "data.txt"
40 FOR I = 0 TO 2
50 READ A,B,C
60 PUT #2,20,I+10
70 NEXT I
80 CLOSE #2
90 DATA 11,12,13, 21,22,23, 31,32,33
99 END
