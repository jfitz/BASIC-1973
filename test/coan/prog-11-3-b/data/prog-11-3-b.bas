50 DEF FNT(X)=12*X^3-64*X^2+17*X+195
60 LET A=0
70 FOR X=-5 TO 5
80 LET S1=FNT(X)
90 LET S2=FNT(X+1)
100 IF S1*S2>0 THEN 130
110 LET A=A+1
120 LET S[A]=X
130 NEXT X
190 PRINT "INTERVAL(S) BEGIN AT:"
200 FOR I=1 TO A
210 PRINT S[I];
220 NEXT I
270 END
