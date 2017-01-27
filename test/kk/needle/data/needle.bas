100 LET P = 3.14159265
110 LET C = 0
120 FOR N = 1 TO 1000
130    LET Y = RND(Z)
140    LET R = RND(Z)
150    LET A = P*(R-1/2)
160    LET Y1 = Y - COS(A)
170    LET Y2 = Y + COS(A)
172    LET C2 = COS(A)
180    IF SGN(Y1) = SGN(Y2) THEN 200
190    LET C = C+1
200 NEXT N
210 LET F = C/N
220 PRINT "FRACTION OF CROSSINGS = " F
230 PRINT "ESTIMATE OF PI = " 2/F
240 END
