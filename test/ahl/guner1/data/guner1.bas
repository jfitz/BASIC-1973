100 REM ARTILLERY FIRING GAME
110 DIM A$(3)
120 RANDOMIZE
130 PRINT "DO YOU WANT INSTRUCTIONS";
140 INPUT A$
150 PRINT
160 IF A$="NO" THEN 370
170 PRINT "    THIS GAME TESTS YOUR ABILITY TO HIT A MOVING TARGET,"
180 PRINT "YOU MUST DESTROY IT BEFORE IT DESTROYS YOU OR MOVES OUT"
190 PRINT "OF RANGE. THE TARGET WILL MOVE RAMDOMLY."
200 PRINT
210 PRINT "    TYPE CTRL/C TO TERMINATE THE PROGRAM. TO THE QUESTION"
220 PRINT "'ENTER SPEED' TYPE A NUMBER BETWEEN 1 AND 100. THIS IS THE "
230 PRINT "RELATIVE SPEED OF THE TARGET WHERE 1 IS THE SLOWEST AND 100"
240 PRINT "IS THE FASTEST."
250 PRINT
260 PRINT "TO THF QUESTION 'ENTER DISTANCE' ENTER THE MAXIMUM DISTANCE"
270 PRINT "YOU CAN HIT FR?OM THE TARGET AND STILL DESTROY IT. THIS IS"
280 PRINT "THE KILL RADIUS AND 5000 IS SUGGESTED FOR STARTERS."
290 PRINT
300 PRINT "ELEVATION IS THE ELEVATION OF YOUR GUN IN DEGREES WHEN YOU"
310 PRINT "FIRE AT THE TARGET. THE MAXIMUN RANGE IS AT 45 DEGREES"
320 PRINT
330 PRINT "ENTER SPEED";
340 INPUT S
350 IF S<1 THEN 330
360 IF S>100 THEN 330
370 PRINT "ENTER DISTANCE";
380 INPUT D
390 IF D<0 THEN 370
400 IF D>10000 THEN 370
410 M=100000-75000*RND(0)
420 PRINT
430 PRINT "THE MAXIMUM RANGE OF YOUR GUN IS "M" YARDS"
440 FOR K=1 TO M/10000
450 LET K1=RND(0)
460 NEXT K
470 R=.95*M-.6*M*RND(0)
480 LET N=0
490 GOTO 520
500 IF R>M THEN 840
510 IF R<(M/2.5) THEN 860
520 PRINT "TARGET RANGE IS"R" YARDS"
530 PRINT "ELEVATION":
540 INPUT E
550 IF E<0 THEN 840
560 IF E> 89 THEN 800
570 IF E <1 THEN 820
580 N=N+1
590 K=INT(R-M*SIN(2*E/57.3))
600 K=ABS(K)
610 IF K1<D THEN 650
620 IF K>D THEN 720
630 IF K<-D THEN 740
640 STOP
650 PRINT "*** TARGET DESTROYED ***"
660 GOSUB 940
670 D1=K
680 FOR K=1 TO N+D/100
690 K1=RND(0)
700 NEXT K
710 GOTO 410
720 PRINT "SHORT OF TARGET BY "K1" YARDS"
730 GOTO 745
740 PRINT "OVER TARGFT BY "K1"YARDS"
745 LET C=INT(2*RND(0)+1)
746 IF C=1 THEN 750
748 LET C=-1
749 GOTO 760
750 LET C=1
760 C1=M*S/100*RND(0)
770 C1=C*C1
780 R=R+C1
790 GOTO 500
800 PRINT "MAXIMUM EVEVATION IS 89 DEGREES"
810 GOTO 530
820 PRINT "MINIMUM ELEVATION IS 1 DEGREE"
830 GOTO 530
840 PRINT "* TARGET OUT OF RANGE *"
850 GOTO 670
860 PRINT "THE TARGET HAS DESTROYED YOU!"
870 GOTO 670
940 IF N=1 THEN 970
950 PRINT N" ROUNDS EXPENDED"
960 RETURN
970 PRINT "***** DIRECT HIT *****"
980 RETURN
990 END 
