10 READ N,R
20 GOSUB 500
30 LET C1=C
32 REM  C1 STORES THE NUMBER OF COMMITTEES IN WHICH
33 REM  YOU ARE A MEMBER
40 READ N,R
50 GOSUB 500
60 LET P=C1/C
70 PRINT "THE PROBABILITY THAT YOU GET ON A 4 MEMBER"
75 PRINT "COMITTEE FROM A CLASS OF 29 IS";P
80 STOP
490 REM  FIND COMBINATIONS OF N THINGS TAKEN M AT A TIME
500 LET C=1
510 FOR X=N TO N-R+1 STEP -1
520 LET C=C*X
530 NEXT X
540 FOR Y=R TO 1 STEP -1
550 LET C=C/Y
560 NEXT Y
570 RETURN
600 DATA 28,3
610 DATA 29,4
999 END
