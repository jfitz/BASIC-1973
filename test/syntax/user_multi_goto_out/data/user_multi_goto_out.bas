10 REM TEST MULTILINE USER FUNCTION
20 PRINT "START"
30 A = FNA(100)
40 PRINT "A IS:"; A
90 PRINT "END"
100 DEF FNA(H)
110 PRINT "START FNA()"
120 FNA = H - 9
125 GOTO 200
130 PRINT "END FNA()"
140 FNEND
200 PRINT "END PROGRAM"
999 END