10 REM TEST PROGRAM FOR PACK$() FUNCTION
20 READ N
30 DIM A(N)
40 A(0) = N
50 FOR I = 1 TO N
60 READ A(I)
70 NEXT I
80 A$ = PACK$(A)
90 PRINT "A$ IS '"; A$; "'"
190 DATA 13,72,69,76,76,79,44,32,87,79,82,76,68,33
199 END

