95 REM * COMPARES STRINGS FOR ORDER
100 PRINT
110 PRINT "A$";
120 INPUT A$
130    IF A$ = "STOP" THEN 240
140 PRINT "B$";
150 INPUT B$
160    IF A$ < B$ THEN 220
170    IF A$ = B$ THEN 200
180 PRINT A$; " IS GREATER THAN "; B$
190 GOTO 100
195 REM
200 PRINT A$; " IS EQUAL TO "; B$
210 GOTO 100
215 REM
220 PRINT A$; " IS LESS THAN "; B$
230 GOTO 100
240 END
