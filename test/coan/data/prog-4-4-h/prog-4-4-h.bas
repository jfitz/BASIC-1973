10 FOR P=1 TO 10
20 LET T=INT(12*RND(1)+1)
30 LET H=INT(36*RND(1)+1)
40 LET S=T+H
50 IF S <= 12 THEN 80
60 LET S=S-12
70 GOTO 50
80 PRINT H"HOURS FROM"T"O'CLOCK IT WILL BE"S"O'CLOCK"
90 NEXT P
100 END
