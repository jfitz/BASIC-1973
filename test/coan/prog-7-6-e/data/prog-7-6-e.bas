94 REM * SELECT A NUMBER FROM A FILE AT RANDOM
100 FILES "numb.txt"
110 PRINT "ROW,COL";
120 INPUT R,K
130    IF R = 0 THEN 190
140 SETW 1 TO 6*(R-1) + K
150 READ :1, A
160 PRINT "FOUND"; A
170 PRINT
180 GOTO 110
190 END
