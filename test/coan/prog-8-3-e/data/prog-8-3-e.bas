4 PRINT "INPUT THE NUMBER OF SPACES DESIRED TO THE LEFT OF ZERO";
5 INPUT M
6 PRINT
8 PRINT "    ";
10 FOR X=0 TO 50 STEP 10
12 PRINT "    ";X;
14 NEXT X
15 PRINT
16 FOR X=1 TO 70
18 IF X/10=INT(X/10) THEN 24
20 PRINT "-";
22 GOTO 26
24 PRINT "^";
26 NEXT X
30 DEF FNQ(X)=X^2
60 FOR X=-7 TO 7
62 PRINT
90 FOR Y = -M TO 70-M
92 IF Y <> 0 THEN 120
94 IF X=0 THEN 98
95 PRINT "'";
96 GOTO 100
98 PRINT "0";
100 IF FNQ(X)>0 THEN 180
102 REM IF  FNQ(X) > 0 GO FIND WHERE IT IS
103 REM OTHERWISE GET THE NEXT VALUE OF X
106 GOTO 240
120 IF Y=FNQ(X) THEN 210
148 REM   IF Y DOES NOT EQUAL FNQ(X) THEN PRINT A BLANK SPACE
150 PRINT " ";
180 NEXT Y
210 PRINT "*";
212 REM   PLOT THE POINT AND GO TO NEXT X
240 NEXT X
270 END
