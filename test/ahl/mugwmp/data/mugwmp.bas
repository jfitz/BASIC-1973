1 REM COURTESV OF PEOPLE'S COMPUTER COMPANV 

2 REM MUQWMP 

Z&lt; REM *** CONVERTED TO RSTS/E BV DAVID AHL, DIGITAL 

5 RANDOMISE 

18 DIM P&lt;4, 2&gt; 

28 PRINT "THE OBJECT Of THIS GAME IS TO FIND FOUR MUGWUMPS" 

38 PRINT "HIDDEN ON A 18 BV 18 GRID. HOMEBASE IS POSITION 0,8" 

40 PRINT "ANV GUESS VOU MAKE MUST BE TWO NUMBERS WITH EACH" 

50 PRINT "NUMBER BETWEEN AND 9/ INCLUSIVE. FIRST NUMBER" 

60 PRINT "IS DISTANCE TO RIGHT OF HOMEBASE AND SECOND NUMBER" 

70 PRINT "IS DISTANCE ABOVE HOMEBASE. " 

80 PRINT 

90 PRINT "VOU GET 10 TRIES. AFTER EACH TRV, I WILL TELL" 

100 PRINT "VOU HOW FAR VOU ARE FROM EACH MUGWUMP. " 

110 PRINT 

240 GOSUB 1008 

250 T=8 

260 T = T+1 

278 PRINT 

275 PRINT 

290 PRINT "TURN NO. "T; "WHAT IS VOUR GUESS"; 

300 INPUT M, N 

318 FOR 1=1 TO 4 

220 IF P&lt;I,1&gt;=-1 THEN 488 

330 IF P&lt;I,l&gt;OM THEN 388 

348 IF P&lt;I/2&gt;ON THEN 388 

350 PU,1&gt; = -1 

368 PRINT "VOU HAVE FOUND MUGWUMP" ; I 

378 GOTO 400 

388 D=Si3R &lt; &lt; P (. 1 , 1 &gt; -M &gt; -2+ &lt; P &lt; 1 , 2 &gt; -N &gt; ~2 &gt; 

398 PRINT "VOU ARE"INTCD+10&gt;/18"UNITS FROM MUGWUMP"! 

480 NEXT I 

41*3 FOR J=l TO 4 

420 IF P(J, DO-1 THEN 470 

430 NEXT J 

440 PRINT 

458 PRINT "VOU GOT THEM ALL IN"; T; "TURNS ! " 

468 GOTO 588 

478 IF T&lt;18 THEN 268 

488 PRINT 

498 PRINT "SORRV, THAT' S 18 TRIES. HERE IS WHERE THE V' RE HIDING" 

548 FOR 1=1 TO 4 

558 IF P(I,1&gt;=-1 THEN 578 

568 PR INT " MUGWUMP " ; I ; " I S AT C " ;P(L1 &gt; ; " .• " ; P &lt;.' I &gt; 2 &gt; ; " &gt; " 

570 NEXT I 

588 PRINT 

600 PRINT "THAT WAS FUN! LET'S PLAV AGAIN " 

610 PRINT "FOUR MORE MUGMUMPS ARE NOW IN HIDING. " 

628 GOTO 240 

1000 FOR J=l TO 2 

1818 FOR 1=1 TO 4 

1028 P&lt;I, J&gt; = INT&lt;10*RND&lt;0&gt;;' 

1030 NEXT I 

1848 NEXT J 

1858 RETURN 

1099 END 

