100 PRINT "YOU ARE ON A BATTLEFIELD WITH 4 PLATOONS AND YOU"
110 PRINT "HAVE 25 OUTPOSTS AVAILABLE WHERE THEY MAY BE PLACED."
120 PRINT "YOU CAN ONLY PLACE ONE PLATOON AT ANY ONE OUTPOST."
130 PRINT "THE COMPUTER DOES THE SAME WITH ITS FOUR PLATOONS."
135 PRINT
140 PRINT "THE OBJECT OF THE GAME IS TO FIRE MISSILES AT THE"
150 PRINT "OUTPOSTS OF THE COMPUTER. IT WILL DO THE SAME TO YOU."
160 PRINT "THE ONE WHO DESTROYS ALL FOUR OF THE ENEMY'S PLATOONS"
170 PRINT "FIRST IS THE WINNER."
180 PRINT
190 PRINT "GOOD LUCK, AND TELL US WHERE YOU WANT THE BODIES SENT!"
200 PRINT
210 PRINT "TEAR OFF THE MATRIX AND USE IT TO CHECK OFF THE NUMBERS."
220 FOR R=1 TO 5\PRINT\NEXT R
250 RANDOMIZE
260 DIM M(100)
270 FOR R=1 TO 5
280 I=(R-1)*5+1
290 PRINT I,I+1,I+2,I+3,I+4
300 NEXT R
350 FOR R=1 TO 10\PRINT\NEXT R
380 LET C = INT(RND(N) * 25) + 1
390 D = INT(RND(N) * 25) + 1
400 E = INT(RND(N) * 25) + 1
410 F = INT(RND(N) * 25) + 1
420 IF C = D GOTO 390
430 IF C = E GOTO 400
440 IF C = F GOTO 410
450 IF D = E GOTO 400
460 IF D = F GOTO 410
470 IF E = F GOTO 410
480 PRINT "WHAT ARE YOUR FOUR POSITIONS";
490 INPUT G,H,K,L
500 PRINT "WHERE DO YOU WISH TO FIRE YOUR MISSILE";
510 INPUT Y
520 IF Y = C GOTO 710
530 IF Y = D GOTO 710
540 IF Y = E GOTO 710
550 IF Y = F GOTO 710
560 GOTO 630
570 M = INT(RND(N) * 25) + 1
575 GOTO 1160
580 IF X = G GOTO 920
590 IF X = H GOTO 920
600 IF X = L GOTO 920
610 IF X = K GOTO 920
620 GOT 670
630 PRINT "HA,HA YOU MISSED, MY TURN NOW"
640 PRINT\PRINT\GOTO 570
670 PRINT "I MISSED YOU, YOU DIRTY RAT. I PICKED";M;". YOUR TURN."
680 PRINT\PRINT\GOTO 500

710 Q = Q +1
720 IF Q = 4 GOTO 890
730 PRINT "YOU GOT ONE OF MY OUTPOSTS."
740 IF Q = 1 GOTO 770
750 IF Q = 2 GOTO 810
760 IF Q = 3 GOTO 850
770 PRINT " ONE DOWN THREE TO GO"
780 PRINT\PRINT\GOTO 570
810 PRINT " TWO DOWN TWO TO GO"
820 PRINT\PRINT\GOTO 570
850 PRINT " THREE DOWN ONE TO GO"
860 PRINT\PRINT\GOTO 570
890 PRINT " YOU GOT ME, I'M GOING FAST, BUT I'LL GET YOU WHEN "
900 PRINT " Y TRANSISTORS RECUPERATE"
910 GOTO 1235
920 Z=Z+1
930 IF Z=4 THEN 1110
940 PRINT "I GOT YOU, IT WON'T BE LONG NOW. POST"X" WAS HIT," 
950 IF Z=1 THEN 990
960 IF Z=2 THEN 1030
970 IF Z=3 THEN 1070
990 PRINT "YOU HAVE ONLY THREE OUTPOSTS LEFT"
1000 PRINT\PRINT\GOTO 500
1030 PRINT "YOU HAVE ONLY TWO OUTPOSTS LEFT."
1040 PRINT\PRINT\GOTO 500
1070 PRINT "YOU HAVE ONLY ONE OUTPOST LEFT."
1080 PRINT\PRINT\GOTO 500
1110 PRINT " YOU'RE DEAD. YOUR LAST OUTPOST WAS AT"X". HA,  HA,  HA!"
1120 PRINT " BETTER LUCK NEXT TIME."
1150 GOTO 1235
1160 P=P+1
1170 N=P-1 
1180 FOR T = 1 TO N
1190 IF M = M(T) GOTO 570
1200 NEXT T
1210 X = M
1220 M(P) = M
1230 GOTO 580
1235 END

