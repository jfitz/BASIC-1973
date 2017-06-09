100 REM THIS PROGRAM USES A STRATEGY AS PRESENTED IN 'GAMES OF FUN AND
105 REM STRATEGY', A PUBLICATION OF THE MATHEMATICAL SERVICES DEPART-
110 REM MENT OF COMPUTER CONTROL CO., INC.
115 PRINT "THIS PROGRAM PLAYS NIM."
120 PRINT "DO YOU WANT INSTRUCTIONS";\INPUT Q$
125 IF Q$="YES" THEN 135\IF Q$="NO" THEN 190
130 PRINT "TYPE YES OR NO."\INPUT Q$\GOTO 125
135 PRINT
140 PRINT "    NIM IS PLAYED BY TWO PEOPLE PLAYING ALTERNATELY, BEFORE"
145 PRINT "THE PLAY STARTS, AN ARBITRARY NUMBER OF STICKS OR OBJECTS IS"
150 PRINT "PUT INTO AN ARBITRARY NUMBER OF PILES, IN ANY DISTRIBUTION"
155 PRINT "WHATEVER, THEN EACH PLAYER IN HIS TURN REMOVES AS MANY"
160 PRINT "STICKS AS HE WISHES FROM ANY PILE—BUT FROM ONLY ONE PILE,"
165 PRINT "AND AT LEAST ONE STICK, THE PLAYER WHO TAKES THE LAST STICK"
170 PRINT "IS THE WINNER."
175 PRINT "    THIS PROGRAM ALLOWS YOU TO SET UP THE INITIAL ARRANGEMENT"
180 PRINT "OF PILES AND STICKS. IT WILL NOT ACCEPT MORE THAN TWENTY"
185 PRINT "PILES OR STICKS IN EACH PILE."
190 RANDOM
195 REM-------------------CONFIGURATION INPUT----------------------------
200 DIM X(20,4),S(20),L(20),S2(20),N2(4),C(20),S3(20),V(20)
205 PRINT\PRINT "HOW MANY PILES";\INPUT P\IF P>20 THEN 215
210 IF P>INT(P) THEN 215\IF P<=0 THEN 215\GO TO 220
215 PRINT "ILLEGAL PILE NUMBER. "\PRINT\GO TO 205
220 PRINT\FOR I=1 TO P
225 PRINT "HOW MANY STICKS IN PILE"I;\INPUT L(I)\IF L(I)>20 THEN 235
230 IF L(I)>INT(L(I)) THEN 235\IF L(I)<=0 THEN 235\GO TO 240
235 PRINT "ILLEGAL STICK NUMBER"\PRINT\GO TO 225
240 NEXT I
245 FOR I=1 TO P\S(I)=L(I)\G=G+L(I)\NEXT I
250 PRINT\PRINT "DO YOU WANT TO GO FIRST";
255 INPUT Q$\IF Q$="YES" THEN 340\IF Q$="NO" THEN 390
260 PRINT "TYPE YES OR NO."\GO TO 255
265 REM — CONTROL OF GAME REPEATS AND TESTS FOR END OF GAME- —
270 IF G=0 THEN 275\IF F=1 THEN 390\GO TO 320
275 IF F=1 THEN 315
280 PRINT\PRINT "I WON. DO YOU WANT TO PLAY AGAIN";
285 INPUT Q$\IF Q$="NO" THEN 290\IF Q$="YES" THEN 300\GO TO 295
290 STOP
295 PRINT "TYPE YES OR NO."\GO TO 285
300 PRINT\PRINT "SAME ARRANGEMENT";
305 INPUT Q$\IF Q$="NO" THEN 205\IF Q$="YES" THEN 345
310 PRINT "TYPE YES OR NO."\GO TO 305
315 PRINT\PRINT "YOU WON, DO YOU WANT TO PLAY AGAIN";\GO TO 285
320 PRINT\PRINT "PlLE NUMBER","STICKS LEFT"
325 FOR I=1 TO P\IF S(I)=0 THEN 330\PRINT I,S(I)
330 NEXT I
335 REM -------------------PLAYER'S MOVE-—------------------------
340 PRINT\PRINT "WHICH PILE DO YOU WANT STICKS FROM";\INPUT N
345 IF N>P THEN 355\IF N>INT(N) THEN 355\IF N<=0 THEN 355
350 IF S(N)=0 THEN 355\GO TO 360
355 PRINT "ILLEGAL PILE NUMBER."\PRINT\GO TO 340
360 PRINT\PRINT "HOW MANY STICKS";\INPUT T
365 IF T>S(N) THEN 370\IF T>INT(T) THEN 370\IF T<=0 THEN 370\GO TO 375
370 PRINT "ILLEGAL STICK NUMBER."\PRINT\GO TO 360
375 S(N)=S(N)-T\G=G-T
380 F=1\GO TO 270
385 REM -------------------MACHINE'S MOVE-------------------------
390 FOR I=0 TO 4\V(I)=0\NEXT I
395 FOR I=1 TO P
400    C(I)=S(I)
405    FOR E=4 TO 0 STEP -1
410       IF S(I)<2^E THEN 415\S2(I)=S2(I)+10^E\S(I)=S(I)-2^E
415    NEXT E
420    FOR Y=4 TO 0 STEP -1
425       X(I,Y)=INT(S2(I)/10^Y)\S2(I)=S2(I)-X(I,Y)*10^Y
430       V(Y)=V(Y)+X(I,Y)
435    NEXT Y
440 NEXT I
445 R=0
450 FOR Y=4 TO 0 STEP -1
455    IF V(Y)/2-INT(V(Y)/2)=0 THEN 480
460    IF R=1 THEN 470\Q=INT(P*RND(X))+1
465    IF X(Q,Y)<>1 THEN 460\X(Q,Y)=0\R=1\GO TO 480
470    IF X(Q,Y)=1 THEN 475\X(Q,Y)=1\GO TO 480
475    X(Q,Y)=0
480 NEXT Y
485 FOR I=1 TO P
490    S2(I)=0
495    FOR Y=4 TO 0 STEP -1
500       S3(I)=X(I,Y)*10^Y\S2(I)=S2(I)+S3(I)
505    NEXT Y
510    FOR E=4 TO 0 STEP -1
515       IF S2(I)<10^E THEN 520\S(I)=S(I)+2^E\S2(I)=S2(I)-10^E
520    NEXT E
525 NEXT I 
530 IF R=1 THEN 535\Q=INT(P*RND(X))+1\IF S(Q)=0 THEN 530\S(Q)=S(Q)-1
535 D=C(Q)-S(Q)\G=G-D
540 IF D=1 THEN 550
545 PRINT\PRINT "I'LL TAKE";D;"STICKS FROM PILE";Q;"."\GO TO 555
550 PRINT\PRINT "I'LL TAKE 1 STICK FROM PILE";Q;"."
555 F=0\GO TO 270
560 END
