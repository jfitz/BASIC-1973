00001 REM PROGRAM SUBMITTED BY JESSE LYNCH, ST, PAUL, MN.
00002 J=0
00003 L=0
00005 PRINT "OLYMPIC BOXING — 3 ROUNDS"
00007 PRINT
00010 PRINT "INPUT YOUR OPPONENT'S NAME"
00020 INPUT J$
00030 PRINT "INPUT YOUR MAN'S NAME"
00040 INPUT L$
00045 PRINT
00050 PRINT "DIFFERENT PUNCHES ARE 1 FULL SWING 2 HOOK 3 UPPERCUT 4 JAB"
00060 PRINT "WHAT IS YOUR MANS BEST";
00064 INPUT B
00070 PRINT "AND WHAT IS HIS VULNERABILITY";
00080 INPUT D
00085 PRINT 
00090 B1=INT(4*RND+1)
00100 D1=INT(4*RND+1)
00110 IF B1=D1 THEN 90
00120 PRINT J$" ADVANTAGE IS "B1; " AND DISADVANTAGE IS SECRET"
00130 FOR R=1 TO 3
00140 IF J>= 2 THEN 1040
00150 IF L>=2 THEN 1060 
00160 X=0
00170 Y=0
00175 PRINT
00180 PRINT "ROUND "R" BEGINS..."
00181 PRINT ""
00185 FOR R1= 1 TO 7
00190 I=INT(10 *RND+1)
00200 IF I>5 THEN 600
00210 PRINT L$ "'S PUNCH";
00220 INPUT P
00221 IF P=B THEN 225
00222 GO TO 230
00225 X=X+2
00230 IF P=1 THEN 340
00240 IF P=2 THEN 450
00250 IF P=3 THEN 520
00270 PRINT L$ "JABS AT "J$"S HEAD ";
00271 IF D1=4 THEN 290
00275 C=INT(8 *RND+1)
00280 IF C<4 THEN 310
00290 X=X+3
00300 GO TO 950
00310 PRINT "ITS BLOCKED"
00330 GO TO 950
00340 PRINT L$ " SWINGS AND ";
00341 IF D1=4 THEN 410
00345 X3 =INT(30 *RND+1) 
00350 IF X3<10 THEN 410
00360 PRINT " HE MISSES ";
00375 IF X=1 THEN 950
00380 PRINT
00390 PRINT
00400 GO TO 300
00410 PRINT "HE CONNECTS!"
00420 IF X>35 THEN 980
00425 X=X+15
00440 GO TO 300
00450 PRINT L$ "GIVES THE HOOK ";
00455 IF D1=2 THEN 480
00460 H1 =INT(2*RND+1)
00470 IF H1=1 THEN 500
00475 PRINT "CONNECTS..."
00480 X=X+7
00490 GO TO 300
00500 PRINT "BUT IT'S BLOCKED !!!!!!!"
00510 GO TO 300
00520 PRINT L$ " TRIES AN UPPERCUT ";
00530 IF D1=3 THEN 570
00540 D5=INT(100*RND+1)
00550 IF D5<51 THEN 570
00560 PRINT " AND IT'S BLOCKED (LUCKY BLOCK!)"
00565 GO TO 300
00570 PRINT "AND HE CONNECTS!"
00580 X=X+4
00590 GO TO 300
00600 J7=INT(4*RND+1)
00601 IF J7=B1 THEN 605
00602 GO TO 610
00605 Y=Y*2
00610 IF J7=1 THEN 720
00620 IF J7=2 THEN 810
00630 IF J7 =3 THEN 860
00640 PRINT J$" JABS AND";
00645 IF D=4 THEN 700
00650 Z4 =INT(7*RND+1) 
00655 IF Z4>4 THEN 690
00660 PRINT " IT'S BLOCKED!"
00670 GO TO 300
00690 PRINT " BLOOD SPILLS !!!"
00700 Y=Y+5
00710 GO TO 300
00720 PRINT J$" TAKES A FULL SWING AND";
00730 IF D=1 THEN 770
00740 R6=INT(60*RND+1)
00745 IF R6 <30 THEN 770
00750 PRINT " BUT IT'S BLOCKED !"
00760 GO TO 300
00770 PRINT " POW!!!! HE HITS HIM RIGHT IN THE FACE!"
00780 IF Y>35 THEN 1010
00790 Y=Y+15
00800 GO TO 300
00810 PRINT J$" GETS "L$" IN THE JAW (OUCH!)"
00820 Y=Y+7
00830 PRINT "....AND AGAIN!"
00835 Y=Y+5
00840 IF Y>35 THEN 1010
00850 PRINT
00860 PRINT L$ " IS ATTACKED BY AN UPPERCUT (OH, OH)..."
00865 IF D=3 THEN 890
00870 Q4=INT(200*RND+1)
00880 IF Q4>75 THEN 920
00890 PRINT " AND "J$" CONNECTS..."
00900 Y=Y+8
00910 GO TO 300
00920 PRINT " BLOCKS AND HITS "J$" WITH A HOOK."
00930 X=X+5
00940 GO TO 300
00950 NEXT R1
00951 IF X>Y THEN 955
00952 PRINT J$ " WINS ROUND "R
00953 J=J+1
00954 GO TO 960
00955 PRINT L$ " WINS ROUND "R
00956 L=L+1
00960 NEXT R
00961 IF J>= 2 THEN 1040
00962 IF L>=2 THEN 1060
00981 PRINT J$ "  IS KNOCKED COLD AND " L$" IS THE WINNER AND CHAMP"; 
01000 GO TO 1080
01010 PRINT L$ " IS KNOCKED COLD AND " J$" IS THE WINNER AND CHAMP";
01030 GO TO 1000
01040 PRINT J$ " WINS (NICE GOING )" J$
01050 GO TO 1000
01060 PRINT L$ " AMAZINGLY WINS  "
01070 GO TO 1000
01080 PRINT
01085 PRINT
01090 PRINT "AND NOW GOODBYE FROM THE OLYMPIC ARNEA."
01100 PRINT
01110 END
