1 REM THIS PROGRAM PLAYS THE CARD GAME OF WAR. THE ONLY CHANGE
2 REM IS THAT A TIE MAKES NO SCORE AT ALL. THE PACK IS READ IN
3 REM AND THEN SHUFFLES IN A RANDOM WAY. THE COMPUTER THEN DEALS THE
4 REM CARDS TWO AT A TIME AS LONG AS THE GAME CONTINUES, A RUNNING
5 REM SCORE IS KEPT.
100 PRINT "THIS IS THE CARD GAME OF WAR. EACH CARD IS GIVEN BY SUIT-#."
110 PRINT "AS S-7 FOR SPADE 7.";
120 PRINT "DO YOU WANT DIRECTIONS";
130 INPUT B$
140 IF B$="NO" THEN 210
150 IF B$="YES" THEN 180
160 PRINT "YES OR NO, PLEASE.";
170 GO TO 120
180 PRINT "THE COMPUTER GIVES YOU AND IT A 'CARD'. THE HIGHER 'CARD'"
190 PRINT "(NUMERICALLY) WINS. THE GAME ENDS WHEN YOU CHOOSE NOT"
200 PRINT "TO CONTINUE OR WHEN YOU HAVE FINISHED THE PACK."
210 PRINT
220 PRINT
230 DIM A$(52),L(54)
240 FOR I=1 TO 52
250 READ A$(I)
260 NEXT I
270 RANDOM
280 FOR J=1 TO 52
290 LET L(J)=INT(52*RND(X) + 1)
300 FOR K=1 TO J-1
310 IF L(K)<>L(J) THEN 340
320 LET J=J-1
330 GO TO 350
340 NEXT K
350 NEXT J
360 LET P=P+1
370 LET M1=L(P)
380 LET P=P+1
390 LET M2=L(P)
400 PRINT
410 PRINT
420 PRINT "YOU: ";A$(M1);"COMPUTER: ";A$(M2)
430 LET N1=INT((M1-.5)/4)
440 LET N2=INT((M2-.5)/4)
450 IF N1>=N2 THEN 490
460 LET A1=A1+1
470 PRINT "COMPUTER WINS.^G^G^G^G^G   YOU HAVE";B1;"; COMPUTER HAS";A1
480 GO TO 540
490 IF N1=N2 THEN 530
500 LET B1=B1+1
510 PRINT "YOU WIN, YOU HAVE";B1;"; COMPUTER HAS";A1
520 GO TO 540
530 PRINT "TIE, NO SCORE CHANGE."
540 IF L(P+1)=0. THEN 610
550 PRINT "DO YOU WANT TO CONTINUE";
560 INPUT V$
570 IF V$="YES" THEN 360
580 IF V$="NO"THEN 650
590 PRINT "YES OR NO, PLEASE.";
600 GO TO 540
610 PRINT
620 PRINT
630 PRINT "YOU HAVE RUN OUT OF CARDS, FINAL SCORE: YOU --";B1;
640 PRINT " COMPUTER --";A1
650 PRINT "THANKS FOR PLAYING, IT WAS FUN.^G^G"
660 DATA "S-2","H-2","C-2","D-2","S-3","H-3","C-3","D-3","S-4","H-4","C-4","D-4","S-5","H-5","C-5"
670 DATA "D-5","S-6","H-6","C-6","D-6","S-7","H-7","C-7","D-7","S-8","H-8","C-8","D-8","S-9","H-9"
680 DATA "C-9","D-9","S-10","H-10","C-10","D-10","S-J","H-J","C-J","D-J","S-Q","H-Q","C-Q","D-Q"
690 DATA "S-K","H-K","C-K","D-K","S-A","H-A","C-A","D-A"
700 END
