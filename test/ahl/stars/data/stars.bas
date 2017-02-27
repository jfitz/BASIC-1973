100 REM *** STARS • PEOPLE'S COMPUTER CENTER, MENLO PARK, CA 

110 PRINT "STARS - A NUMBER GUESSING GAME" 

120 PRINT 

130 RANDOMIZE 

140 REM *** A IS LIMIT ON NUMBER, M IS NUMBER OF GUESSES 

150 LET AM00 

160 LET M«7 

170 PRINT "DO YOU WANT INSTRUCTIONS C1"YES 0*NO) H J 

180 INPUT Z 

190 IP Z«0 THEN 280 

200 REM •*•* INSTRUCTIONS ON HOW TO PLAY 

210 PRINT MI AM THINKING OF A WHOLE NUMBER FROM 1 TO«|A 

220 PRINT "TRY TO GUESS MY NUMBER. AFTER YOU GUE-SS, I" 

230 PRINT "WILL TYPE ONE OR MORE STARS (*), THE MORE" 

240 PRINT "STARS I TYPE, THE CLOSER YOU ARE TO MY NUMBER," 

250 PRINT "ONE STAR (*) MEANS FAR AWAY, SEVEN STARS (*******)" 

260 PRINT "MEANS REALLY CLOSEJ YOU GET" &gt;MI "GUESSES. » 

270 REM *** COMPUTER 'THINKS 1 OF A NUMBER 

280 PRINT 

290 PRINT 

300 LET X«INT(A*RND(0)J+1 

3t0 print "ok, i am thinking of a number, start guessing." 

320 REM *** GUESSING BEGINS, HUMAN GETS M GUESSES 

330 FOR KM TO M 

340 PRINT 

350 PRINT "YOUR GUESS"! 

360 INPUT G 

370 IF GaX THEN 600 

380 LET DMBS(X-G) 



390 


IF D &gt;■ 64 


THEN 


510 








400 


IF D &gt;« 32 


THEN 


500 








410 


IF D &gt;■ 16 


THEN 


490 








420 


IF D &gt;■ 8 


THEN 


480 








430 


IF D &gt;■ 4 


THEN 


470 








440 


IF &gt;i 2 


THEN 


460 








450 


PRINT »*"| 












460 


PRINT »*"J 












470 


PRINT »*»; 












480 


PRINT «*"J 












490 


PRINT »*"| 












500 


PRINT "*«| 












510 


PRINT »*») 












520 


PRINT 












530 


NEXT K 












540 


REM *** DID NOT 


GUESS 


NUMBER 


IN M G 


550 


PRINT 












560 


PRINT "SORRY, THAT'S" 


|Mf« 


GUESSES, N 


580 


GOTO 280 












590 


REM *** WE 


HAVE 


A WINNER 






600 


FOR N»l TO 


50 










610 


PRINT "*"J 












620 


NEXT N 












630 


PRINT "til 


i 










640 


PRINT "YOU 


GOT 


IT IN 


"IKI 


"GUESSESIJ 


650 


GOTO 280 












660 


END 

