10 FOR I=1 TO 4
20 LET T[I]=0
30 NEXT I
31 REM EACH ELEMENT IN THE LIST IS NOW ZERO
40 READ N
49 REM TEST FOR THE END OF DATA
50 IF N=-1 THEN 80
60 LET T[N]=T[N]+1
70 GOTO 40
80 PRINT "NO. OF TV'S","NO. OF FAMILIES"
89 REM NOW PRINT THE NUMBER OF SETS AND THE NUMBER OF FAMILIES
90 FOR I=1 TO 4
100 PRINT I,T[I]
110 NEXT I
498 REM EACH ITEM O FDATA IS THE NUMBER OF TV'S IN ONE FAMILY
500 DATA 1,3,4,1,2,1,3,1,1,2,4,1,3,1,2,4,1,3,1,1,1,4,1,3,2,2,1,2
510 DATA 2,1,3,3,2,2,1,1,1,2,2,3,4,4,2,4,1,4,2,4,2,1,2,1
520 DATA -1
999 END

