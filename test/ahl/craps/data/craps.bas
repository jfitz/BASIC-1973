80 RANDOMIZE
90 FOR I = 1 TO 10\PRINT\NEXT I
100 PRINT"THIS DEMONSTRATION SIMULATES A CRAP GAME WITH THE COMPUTER"
110 PRINT"AS YOUR OPPONENT.  THE RULES ARE SIMPLE:"
120 PRINT
130 PRINT"  *A 7 OR 11 ON THE FIRST ROLL WINS"
140 PRINT"  *A 2, 3 OR 12 ON THE FIRST ROLL LOSES"
150 PRINT
160 PRINT"ANY OTHER NUMBER ROLLED BECOMES YOUR 'POINT'* YOU CONTINUE"
170 PRINT"TO ROLL.  IF YOU GET YOUR POINT, YOU WIN. IF YOU ROLL A 7,"
180 PRINT"YOU LOSE. THE CHANGE HANDS WHEN THIS HAPPENS."
185 PRINT "JUST BET $0 TO QUIT."
190 PRINT
200 PRINT
210 LET Z=5*INT(10+11*RND(0))
215 PRINT"ARE YOU READY";\INPUT B$
216 IF B$="YES" THEN 220\IF B$="NO" THEN PRINT "I'LL REPEAT MYSELF THEN"
217 GOTO 90
220 PRINT "SPLENDID... YOU ARE GIVEN ";Z;"DOLLARS TO PLAY WITH."
230 PRINT
240 PRINT
250 IF N-2*INT(N/2)=0 THEN 310
260 LET W=-1
270 PRINT "I'LL ROLL FIRST..."
280 PRINT
290 PRINT
300 GOTO 350
310 LET W=1
320 PRINT "YOU ROLL FIRST..."
330 PRINT
340 PRINT
350 LET Q=0
360 PRINT "HOW MUCH DO YOU WANT TO BET";
370 INPUT B
380 PRINT
390 IF B=INT(B) THEN 430
400
410 PRINT "NO COINS PERMITTED... JUST BILLS, PLEASE."
420 GOTO 360
430 IF B=0 THEN 1090
440 IF B<Z+1 THEN 470
450 PRINT "DON'T TRY MORE THAN YOU HAVE, PLEASE."
460 GOTO 360
470 LET D1=INT(6*RND(0)+1)
480 LET D2=INT(6*RND(0)+1)
490 LET Q=Q+1
500 S=D1+D2
510 IF W>0 THEN 540
520 PRINT "  I ROLL  ";D1;"AND  ";D2;
530 GOTO 550
540 PRINT "YOU ROLL  ";D1;"AND  ";D2;
550 IF Q<>1 THEN 860
560 IF (S-2)*(S-3)*(S-12)=0 THEN 640
570 IF (S-7)*(S-11)=0 THEN 710
580 IF W>0 THEN 610
590 PRINT "SO MY POINT IS";S
600 GOTO 620
610 PRINT "SO YOUR POINT IS";S
620 LET P=S
630 GOTO 470
640 PRINT "AND CRAP OUT..."
650 LET C=1
660 IF W>0 THEN 690
670 LET Z=Z+B
680 GOTO 770
690 LET Z=Z-B
700 GOTO 770
710 PRINT "AND PASS..."
720 LET C=1
730 IF W>0 THEN 760
740 LET Z=Z-B
750 GOTO 770
760 LET Z=Z+B
770 PRINT
780 IF Z<1 THEN 1060
790 PRINT "YOU NOW HAVE";Z;"DOLLARS"
800 IF C>0 THEN 830
810 PRINT "CHANGE DICE NOW..."
820 PRINT
830 LET W=W+C
840 LET Q=0
850 GOTO 360
860 IF S<>7 THEN 940
870 PRINT "AND LOSE..."
880 LET C=-1
890 IF W>0 THEN 920
900 LET Z=Z+B
910 GOTO 770
920 LET Z=Z-B
930 GOTO 770
940 IF S=P THEN 970
950 PRINT "   ROLL AGAIN."
960 GOTO 470
970 IF W>0 THEN 1020
980 PRINT "AND MAKE MY POINT"
990 LET C=1
1000 LET Z=Z-B
1010 GOTO 770
1020 PRINT "AND MAKE YOUR POINT"
1030 LET C=1
1040 LET Z=Z+B
1050 GOTO 700
1060 PRINT
1070 PRINT "YOU HAVE RUN OUT OF MONEY... SORRY ABOUT THAT."
1080 GOTO 1110
1090 PRINT "THANKS FOR THE GAME... AND CONGRATULATIONS"
1100 PRINT "FOR BEING ABLE TO QUIT WHILE YOU WERE AHEAD."
1110 PRINT\PRINT\PRINT
1120 CHAIN "DEMOES"
1130 END
