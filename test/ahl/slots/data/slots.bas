100 RANDOMIZE
110 DIM D(3)
120 PRINT "THIS IS A SIMULATION OF A SLOT MACHINE USING A COMPUTER."
130 PRINT "EACH TIME YOU 'PULL-' I WILL ASK YOU IF YOU WISH TO PLAY AGAIN."
140 PRINT "JUST ANSWER WITH A 'Y' FOR YES OR A 'N' FOR NO."
150 PRINT "PLEASE PLACE 4 QUARTERS ON MY CPU FOR EACH PLAY. " 
160 PRINT
170 FOR B1=1 TO 3
180 LET D(B1)=INT(RND(0)*6)+1
190 NEXT B1
200 FOR G1 = 1 TO 3
210 IF D(G1)=1 THEN 280
220 IF D(G1)=2 THE N 300
230 IF D(G1)=3 THEN 320
240 IF D(G1)=4 THEN 340
250 IF D(G1)=5 THEN 360
260 IF D(G1)=6 THEN 380
270 GOTO 580 
280 PRINT TAB(G1*7);" BELL";
290 GOTO 390
300 PRINT TAB(G1*7);" BAR";
310 GOTO 390
320 PRINT TAB(G1*7);"CHERRY";
330 GOTO 390
340 PRINT TAB(G1*7);"APPLE";
350 GOTO 390
360 PRINT TAB(G1*7);"LEMON";
370 GOTO 390
380 PRINT TAB(G1*7);" *";
390 NEXT G1
400 PRINT TAB(28);
410 IF D(1)<>D(2) THEN 440
420 IF D(2)=D(3) THEN 530
430 IF D(1)=D(2) THEN 460
440 IF D(1)<>D(3) THEN 490
450 GO TO 510
460 IF D(1)/2=INT(D(1)/2) THEN 510
470 LET B=B + 5\PRINT "KENO. . YOU WIN $5. . TOTAL=$";B;
480 GO TO 550
490 LET B=B-1\PRINT "YOU HAVE LOST $1 — TOTAL=$";B;
508 GOTO 550
510 LET B=B+1\PRINT "YOU HAVE WON $1 — TOTAL=$";B;
520 GOTO 550
530 LET B = B + 20\PRINT CHR$(7); "JACKPOT... $20. .. TOTAL=$";B;CHR$(7);
540 GOTO 550
550 PRINT "AGAIN?"; 
560 INPUT $A\PRINT\IF A=#V THEN 160\IF A<>#N THEN 560
570 PRINT" IT'S BEEN NICE OPERATING FOR YOU COME BACK SOON!"
580 END
