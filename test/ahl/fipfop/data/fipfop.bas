5 REM *** CONVERTED TO RSTS/E BV DAVID AHL, DIGITAL
10 REM *** CREATED BV MICHAEL KASS   HERRICKS HS, NV
20 PRINT "THE OBJECT OF THIS PUZZLE IS TO CHANGE THIS:"
30 PRINT
40 PRINT "X X X X X X X X X X"
50 PRINT
60 PRINT "TO THIS:"
70 PRINT
80 PRINT "O O O O O O O O O O"
90 PRINT
100 &"BY TYPING IN THE NUMBER CORRESPONDING TO THE POSITION OF THE LETTER"
120 &"ON SOME NUMBERS, ONE POSITION WILL CHANGE, ON OTHERS, TWO WILL CHANGE"
140 &"TO RESET THE LINE TO ALL X' S, TYPE A 0 (ZERO) AND TO START A NEW"
160 &"IN THE MIDDLE OF A GAME, TYPE 11 (ELEVEN)"
170 PRINT
180 RANDOMIZE
190 LET Q=RND(Y)
200 PRINT "HERE IS THE STARTING LINE OF X'S:"
210 PRINT
220 LET C=0 
230 PRINT "1 2 3 4 5 6 7 8 9 10"
240 PRINT "X X X X X X X X X X"
250 PRINT
260 DIM A$(20)
270 FOR X=1 TO 10
280 LET A$(X)="X"
290 NEXT X
300 GO TO 320
310 PRINT "ILLEGAL ENTRY— TRY AGAIN"
320 PRINT "INPUT THE NUMBER";
330 INPUT N
340 IF N<>INT (N) THEN 310
350 IF N=22 THEN 180
360 IF N>11 THEN 310
370 IF N=0 THEN 230
380 IF M=N THEN 510
390 LET M=N 
400 IF A$(N)="O" THEN 480
410 LET A$(N)="O"
420 LET R=TAN(Q+N/Q-N)-SIN(Q/N)+336*SIN(.8*N)
430 LET N=R-INT(R)
440 LET N=INT(10*N)
450 IF A$(N)="O" THEN 480
460 LET A$(N) = "O"
470 GO TO 610 
480 LET A$(N) = "X"
490 IF M=N THEN 420
500 GO TO 610
510 IF A$(N)="O" THEN 590
520 LET A$(N)="O"
530 LET R=.592*COT(Q/N+Q)/SIN(N*2+Q)-COS(N)
540 LET N=R-INT(R)
550 LET N=INT(10*N)
560 IF A$(N)="O" THEN 590
570 LET A$(N)="O"
580 GO TO 610
590 LET A$(N)="X"
600 IF M=N THEN 520
610 PRINT"1 2 3 4 5 6 7 8 9 10"
620 PRINT A$(Z);" ";FOR Z=1 TO 10
630 LET C=C+1
640 PRINT
650 FOR Z=1 TO 10
660 IF A$(2)<>"O" THEN 320
670 NEXT Z
680 IF C>12 THEN 710
690 PRINT"VERY GOOD. YOU GUESSED IT IN ONLY "C"GUESSES!!!!"
700 GO TO 720
710 PRINT "TRY HARDER NEXT TIME, IT TOOK YOU "C"GUESSES"
728 PRINT "DO VOU WANT TO DO ANOTHER PUZZLE";
738 INPUT X$
740 IF X$="NO" THEN 780
760 PRINT
770 GO TO 180
780 END
