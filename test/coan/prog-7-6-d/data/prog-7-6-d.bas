94 REM * LOAD RANDOM NUMBERS INTO A BINARY FILE
100 FILES NUMB
110 FOR I = 1 TO 3
120    FOR J = 1 TO 6
130       LET X = RND(X)
140       WRITE :1, X
150       PRINT X;
160    NEXT J
170    PRINT
180 NEXT I
190 END
