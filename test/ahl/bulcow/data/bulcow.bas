5 GOSUB588
10 DIMD(10,4),B(10),C(18),G(10)
15 RANDOMIZE:PRINT:PRINT:PRINT
20 LETA=0:GOTO200
30 PRINT:PRINT:PRINT:LETJ=0
35 PRINT"YOUR GUESS";:INPUTN:LETN=(N+.1)/100000
40 FORI=0TO4:LETG(I)=INT(10*N):LETN=10*N-INT(10*N)
41 FORK=0TOI-1:IFG(I)=G(I)=G(K)GOTO170
42 NEXTK
43 NEXTI
45 LETP=4:LETA=0:GOSUB300
50 PRINTV"BULL";:IFV<>1THENPRINT"S";
55 IFV=5THENPRINT" - YOU WIN":GOTO20
60 PRINTW-V"COW";:IFW<>V+1THENPRINT"S";
65 IFJ=0THENLETA=1:GOTO200
68 GOSUB400
70 PRINT" - MY GUESS IS ";
75 FORI=0TO4:PRINTCHR$(D(J,I)+48);:NEXTI
80 PRINT " MY SCORE ";:INPUTB(J),C(J):LETC(J)=C(J)+B(J)
81 IFB(J)>-1THENIFB(J)<6THENIFC(J)<6THENIFC(J)-B(J)>-1GOTO80
82 PRINT" - RIDICULOUS! !";: GOTO 70
83 IFB(J)=4THENIFC(J)=5GOTO82
85 IFB(J)=5THENPRINT" - I WIN - MV NUMBER WAS";:GOTO100
98 GOTO35
100 FORI=0TO4:PRINTCHR$(D(0,I)+48);:NEXTI
110 GOTO20
150 PRINT:PRINT "YOU HAVE GIVEN ME IMPOSSIBLE SCORES - GAME SPOILED":GOTO 5
170 PRINT"REPEATED DIGITS NOT ALLOWED":GOTO35
200 FORP=0TO4
210 LETD(A,P)=INT(10*RND(1))
220 FORI=0TOP-1:IFD(A,I)=D(A,P)GOTO210
230 NEXTI
240 NEXTP
250 IFA=0GOTO30
260 LETJ=1:GOTO70
300 LETV=0:LETW=0
310 FORI=0TOP:IFD(A,I)=G(I)THENLETV=V+1
320 FORK=0TO4:IFD(A,K)=G(I)THENLETW=W+1
330 NEXTK
340 NEXTI
350 RETURN
400 LETP=0
405 LETG(P)=D(J,P)
410 FORI=0TOP-1:IFG(I)=G(P)GOTO430
415 NEXTI
420 FORA=1TOJ:GOSUB380
425 IFV<=B(A)THENIFW<=C(A)THENIF4-P>=C(A)-WTHENIF4-P>=B(A)-VGOTO440
430 LETG(P)=G(P)+3:IFG(P)>9THENLETG(P)=G(P)-10
432 IFP=0THENIFG(P)=D(1,0)GOTO150
435 IFG(P)<>D(J,P)GOTO410
440 LETP=P-1:IFP<0THENGOTO150
445 GOTO430
448 NEXTA
450 LETP=P+1:IFP<5GOTO405
455 LETJ=J+1
460 FORI=0TO4:LETD(J,I)=G(I):NEXTI
465 RETURN
580 PRINT:PRINT:PRINT"                 BRADFORD UNIVERSITY BULLS AND COWS GAME"
510 GOTO10
999 END
