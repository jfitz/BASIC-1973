30 DEF FNQ(X)=X^2
60 FOR X=-7 TO 7
62 PRINT
88 REM   LINE 90 HAS THE EFFECT OF NUMBERING THE SPACES
89 REM ACROSS THE PAGE 0 TO 70
90 FOR Y =0 TO 70
120 IF Y=FNQ(X) THEN 210
148 REM   IF Y DOES NOT EQUAL FNQ(X) THEN PRINT A BLANK SPACE
150 PRINT " ";
180 NEXT Y
210 PRINT "*";
212 REM   PLOT THE POINT AND GO TO NEXT X
240 NEXT X
270 END