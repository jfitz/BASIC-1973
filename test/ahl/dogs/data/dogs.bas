5 REM V.NAHIGIAN 8TH GRADE DOG RACE GAME
10 DIM S(10),C(10),J(20),W(10),A(10)
15 DIM N$(20),H$(10),P(20)
20 DIM Y(10),B(U),M5(20)
25 RECORD V
30 RECORD X
35 OPEN 8,"WINS"\OPEN 9, "LOSSES"
40 IF S9=6 THEN 70\FOR I=1 TO 10\GET 8,25,I\V9=V9+V\NEXT I
45 IF V9<25 THEN 60\IF V9>200 THEN 55
50 GOTO 100
55 UNSAVE 8\UNSAVE 9
60 PRINT "PLEASE WAIT, DISREGARD THE 25 BELLS"
65 PRINT\PRINT\PRINT\PRINT\PRINT\S9=6\GOTO 35
70 FOR I=1 TO 26-V9\RANDOMlZE\M=INT(10*RND(X))+1\GET 8,25,H
75 V=V+1\PUT 8,25,H\FOR T=1 TO 10\IF H=T THEN    85
80 GET 9,30,T\X=X+1\PUT 9,30,T
85 NEXT T
90 PRINT CHR$(135);
95 NEXT I
100 PRINT\PRINT\PRINT
105 PRINT TAB(10);"WELCOME TO ROOK-A-DAY RACE TRACK!!!"
110 PRINT\PRINT
115 PRINT "DO YOU WANT THE INSTRUCTIONS";\INPUT I$\GOTO 215
120 PRINT "THIS IS A DOG RACE GAME, THERE ARE 10 DOGS"
125 PRINT "WHICH RUN IN THIS RACE, THE WINS AND LOSSES OF"
130 PRINT "EACH DOG ARE RECORDED SO THAT EVEN AFTER YOU"
135 PRINT "LOG-OFF, THE WINS AND LOSSES OF THE DOGS WILL STILL"
140 PRINT "BE RECORDED,"
145 PRINT " THE WINNER OF THE RACE WILL BE DETERMENED BY HOW"
150 PRINT "MANY WINS AND LOSSES EACH DOG HAS, AFTER THE WINS AND"
155PRINT "LOSSES OF EACH DOG HAVE BEEN POSTED, YOU WILL HAVE A "
160 PRINT "CHANCE TO BET, NO MORE THAN 19 PEOPLE ARE ALLOWED"
165 PRINT "TO BET IN THIS GAME, WHEN BETTING, YOU CANNOT BET OVER"
170 PRINT "$500,00 AND MUST BET AT LEAST $2,00, MORE THAN 1"
175 PRINT "PERSON MAY BET ON THE SAME DOG, AFTER THE BETS"
180 PRINT "ARE MADE THE ODDS WILL BE FIGURED AND POSTED AND THE "
185 PRINT "RACE WILL BEGIN,"
190 PRINT " THE STRADGY OF THIS GAME IS TO PICK THE WINNER"
195 PRINT " INSUCH A WAY THAT THE ODDS ON THAT DOG ARE GOOD"
200 PRINT "IN YOUR FAVOR."
210 PRINT\PRINT TAB(10);"GOOD LUCK!|"\GOTO 220
215 IF I$="YES" THEN 120\GOTO 220
220 GOSUB 225\GOTO 255
225 PRINT\PRINT\PRINT "DOG","NUMBER","WINS","LOSSES"
230 FOR I=1 TO 10
235 READ H$(I)
240 GET 8,25,I\GET 9,30,I
245 PRINT H$(I),T,V,X
250 NEXT I\RETURN
255 PRINT\PRINT\PRINT "HOW MANY WISH TO BET";
260 INPUT G\IF Q<20 THEN 270
265 PRINT "NO MORE THAN. 19 ALLOWED"\PRINT\GOTO 255
270 FOR Z=1 TO Q
275 PRINT "BETTOR'S NAME";\INPUT N$(Z)
280 PRINT "DOG'S NUMBER";\INPUT J(Z)
285 PRINT "AND YOUR BET";\INPUT P(Z)
290 IF P(Z)<2 THEN 300\IF P(Z)>500 THEN 315
295 PRINT\NEXT Z\GOTO 325
300 PRINT "YOU MUST BET AT LEAST $2,00, TRY AGAIN "N$(Z)
305 PRINT "YOUR BET";\INPUT P(Z)
310 GOTO 290
315 PRINT "YOU CAN'T BET OVER 500,00 "N$(Z)" TRY AGAIN"
320 GOTO 305
325 FOR I=1 TO 10
330 B(11)=B(11)+P(I)
335 NEXT I
340 FOR I=1 TO Q 'AMOUNT OF PEOPLE PLAYING
345 FOR I3=1 TO 10'DOGS
350 IF J(I)<>I3 THEN 360
355 A(I3)=A(I3)+P(I)
360 NEXT I3
365 NEXT I
370 FOR I=1 TO 10
375 IF A(I)>=2 THEN 390
380 B(I)=INT(B(11)*RND(X))+1
385 GOTO 395
390 B(I)=INT((B(11)-A(I))/(A(I)-(.17*A(I))))
395 IF B(I)<=2 THEN 405
400 GOTO 410
405 B(I)=2
410 NEXT I
415 PRINT
420 PRINT "DOG","NUMBER","ODDS"
425 FOR I=1 TO 10
430 PRINT H$(I),I,B(I)": 1"
435 NEXT I
440 FOR I=1 TO 10
445 GET 8,25,I\GET 9,30,I\IF V+X<=0 THEN 470
450 RANDOMIZE
455 Y(I)=INT(V/ABS((V+X))+INT(V*RND(X))*1)
460 IF Y(I)<7 THEN 470
465 GOTO 475
470 Y(I)=INT(7*RND(X))+1
475 NEXT I
480 FOR R=1 TO 10
485 S(R)=0
490 NEXT R
495 PRINT
500 PRINT TAB(2);"-1 2 3 4 5 6 7 8 9 10", "AND THEY'RE OFF!!!"
505 PRINT CHR$(135);CHR$(135);CHR$(135);CHR$(135);CHR$(135)
510 FOR R=1 TO 10
515 RANDOMIZE
520 C(R)=INT(Y(R)*RND(X))+1
525 S(R)=S(R)+C(R)
530 NEXT R
535 PRINT TAB(2);"XXXXXXXXSTARTXXXXXXXX"
540 FOR P=1 TO 20
545 FOR R=1 TO 10
550 IF P=S(R) THEN 580
555 IF S(R)>20 THEN 590
560 NEXT R
565 PRINT
570 NEXT P
575 GOTO 625
580 PRINT TAB(R*2);R;CHR$(141)
585 GOTO 560
590 IF W(1)<>0 THEN 605
595 W(1)=R
600 GOTO 560
605 D=2
610 W(D)=R
615 D=D+1
620 GOTO 560
625 IF W(1)<>0 THEN 640
630 PRINT TA8(2);"XXXXXXXFINISHXXXXXXXX"
635 GOTO 510
640 FOR Y=2 TO 22
645 PRINT TAB(Y);"X";TAB(Y);CHR$(135);
650 IF Y=7 THEN 665
655 NEXT Y
660 GOTO 680
665 PRINT " FINISH";
670 Y=13
675 GOTO 655
680 PRINT
685 PRINT "  ";
690 FOR I=2 TO 22\PRINT "*";\NEXT I\PRINT
695 IF D<=1 THEN 735
700 G=W(1)
705 FOR I2=1 TO D
710 IF S(W(I2))<S(W(I2+1)) THEN 725
715 NEXT I2
720 GOTO 735
725 G=W(I2+1)
730 GOTO 715
735 PRINT
740 PRINT
745 PRINT "AND THE WINNER IS DOG NUMBER";G,H$(G)
750 PRINT\GOTO 970
755 RESTORE
760 FOR E=1 TO Q
765 IF G=J(E) THEN 790
770 M5(E)=M5(E)-P(E)
775 N7=N7+P(E)
780 NEXT E
785 GOTO 835
790 IF B(G)=2 THEN 800
795 GOTO 805
800 B(G)=1
805 M=INT(100*(B(G)*P(E)*P(E))/100)
810 PRINT "CONGRATULATION "N$(E)" YOU HAVE WON $";M
815 M5(E)=M5(E)+M
820 N7=N7-M
825 PRINT
830 GOTO 780
835 PRINT "WOULD YOU AVID RACE FANS LIKE TO PLAY AGAIN";
840 INPUT L$
845 IF L$="YES" THEN 870
850 PRINT\PRINT "PERSON", "AMOUNT "\FOR I=1 TO Q
855 PRINT N$(I),M5(I)\NEXT I\PRINT "COMP",N7 
860 FOR I=1 TO 5\PRINT\NEXT I\GOTO 1085
865 GOTO 1085
870 FOR K=1 TO 10
875 A(K)=0
880 S(K)=0
885 W(K)=0
890 C(K)=0
895 J(K)=0
900 B(11)=0
905 B(K)=0
910 NEXT K\GOSUB 225
915 PRINT "ANY NEWCOMERS";\INPUT C$
920 FOR I=1 TO Q
925 PRINT N$(I);" YOUR DOGS NUMBER" I\INPUT J(I)
930 PRINT "AND YOUR BET";\INPUT P(I)
935 IF P(I)<2 THEN 950\IF P(I)>500 THEN 960\NEXT I
940 IF C$="NO" THEN 325
945 GOTO 1025
950 PRINT "YOU MUST BET AT LEAST $2.00 "N$(I)"YOUR BET";
955 INPUT P(I)\GOTO 935
960 PRINT "YOU CAN'T BET OVER $500.00 "N$(I)" TRY AGAIN"
965 GOTO 930
970 FOR I=1 TO 10
975 SET 8,25,I\GET 9,30,I
980 IF I=G THEN 995
985 X=X+1\PUT 9,30,I
990 GO TO 1000
995 V=V+1\PUT 8,25,I
1000 NEXT T
1005 GOTO 755
1010 DATA "FASTER ","ZELDA", "SPEEDY", "ZIFFLE", "KILLER"
1015 DATA "BURBON","BUGZY", "SNOOPY", "LASSIE", "WINNER"
1020 GOTO 1085
1025 PRINT\PRINT "HOW MANY NEWCOMERS";\Q4=0\INPUT J6\Q4=Q+J6
1030 IF Q4>=20 THEN 1035\Q=Q4\Q4=0\GO TO 1040
1035 PRINT "NO MORE THAN 19 ALLOWED, YOU U NOW HAVE "Q\Q4=0\GOTO 1025
1040 FOR Z=I TO Q
1045 PRINT "BETTORS NAME";\INPUT N$(Z)
1050 PRINT "DOGS NUMBER";\INPUT J(Z)
1055 PRINT "AND YOUR BET";\INPUT P(Z)\IF P(Z)<2 THEN 1070
1060 IF P(Z)>500 THEN 1075
1065 PRINT\NEXT Z\GOTO 325
1070 PRINT "YOU MUST BET AT LEAST $2.00"\GOTO 1055
1075 PRINT "YOuU CAN'T BET OVER $500,00"\GOTO 1055
1080 GOTO 325
1085 CLOSE 8\CLOSE 9
1090 REM
1095 END
