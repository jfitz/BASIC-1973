10 GOSUB 1000
20 FOR C = 1 TO 5
30    GOSUB 2000
40    GOSUB 3000
50 NEXT C
60 STOP
70
1000 REM SET UP DECK
1010 DIM L(51)
1020 FOR I = 0 TO 51
1030    LET L(I) = I
1040 NEXT I
1050 RETURN
1060
2000 REM DEAL A CARD
2010 LET I = INT(52*RND(1))
2020 LET X = L(I)
2030 IF X < 0 THEN 2010
2040 LET L(I) = -1
2050 RETURN
2060
3000 REM PRINT A CARD
3010 LET S = INT(X/13)
3020 LET V = X - 13*S
3030 IF S > 0 THEN 3060
3040 PRINT "CLUB  ";
3050 GOTO 3500
3060 IF S > 1 THEN 3090
3070 PRINT "DIAMOND  ";
3080 GOTO 3500
3090 IF S > 2 THEN 3120
3100 PRINT "HEART  ";
3110 GOTO 3500
3120 PRINT "SPADE  ";
3130
3500 IF V > 8 THEN 3530
3510 PRINT V + 2
3520 RETURN
3530 IF V > 9 THEN 3560
3540 PRINT "JACK"
3550 RETURN
3560 IF V > 10 THEN 3590
3570 PRINT "QUEEN"
3580 RETURN
3590 IF V > 11 THEN 3620
3600 PRINT "KING"
3610 RETURN
3620 PRINT "ACE"
3630 RETURN
9999 END
