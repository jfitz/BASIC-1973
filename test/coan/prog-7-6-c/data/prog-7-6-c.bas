94 REM * READ SCORE - WRITE SCORE1
100 FILES "score.txt"; "score1.txt"
110 SCRATCH #2
120 READ #1, N$,X1,X2,X3,X4,X5,X6
130 PRINT N$
140 WRITE #2, N$; (X1+X2+X3+X4+X5+X6)/6
150    IF MORE(#1) THEN 120
160 END
