90 REM * DEMONSTRATE CHANGE STATEMENT
100 DIM A(30)
110 PRINT "STRING";
120 INPUT A$
130 CHANGE A$ TO A
140 PRINT LEN(A$); "CHARACTERS IN '"; A$; "'"
150 PRINT
160 LET B(0) = 1
170 PRINT "CHAR ASCII CODE"
180 FOR I = 1 TO A(0)
210    PRINT "'"; EXT$(A$,I,I); "'  "; A(I)
220 NEXT I
230 END

