1 REM    PROGRAM WRITTEN BY RAYMON W. MISEYKA
2 REM    SENIOR AT   BUTLER SENIOR HIGH SCHOOL
3 REM                BUTLER, PENNSYLVANIA 16001
4 REM    DATE 1/30/73
5 REM    COMPUTER SUPERVISION- MR. WILLIAM ELLIS
6 REM    COMPUTER TOPICS INSTRUCTION- MR. ALBERT STEWERT
7 REM         I WROTE THIS PROGRAM BECAUSE OF THE CHALLENGE
8 REM    INVOLVED IN OVERCOMING THE COMPLEXITIES OF SUCH A GAME
9 REM
10 REM
100 RANDOMIZE
120 DIM A(20),B(20),C(40),H(2),T(2),W(2),X(2),Y(2),Z(2)
130 DIM M$(2),D(2)
140 PRINT "RAMIS ENTERPRISES PRESENTS N. F. U. FOOTBALL (NO FORTRAN USED)"
145 PRINT\PRINT
150 PRINT "DO YOU WISH INSTRUCTIONS?";\INPUT A$
160 IF A$="NO" THEN 290\IF A$<>"YES" THEN 150
170 PRINT "THIS IS A GAME FOR 2 TEAMS IN WHICH EACH PLAYER MUST"
180 PRINT "PREPARE A TAPE WITH A DATA STATEMENT (1770 FOR TEAM 1"
190 PRINT "1780 FOR TEAM 2) IN WHICH EACH TEAM SCRAMBLES NOS. 1-20"
195 PRINT "THESE NUMBERS ARE THEN ASSIGNED TO 20 GIVEN PLAYS."
200 PRINT "A LIST OF NOS. AND THEIR PLAYS ARE PROVIDED WITH"
210 PRINT "BOTH TEAMS HAVING THE SAME PLAYS. THE MORE SIMILAR THE"
220 PRINT "PLAYS THE LESS YARDAGE GAINED. SCORES ARE GIVEN"
223 PRINT "WHENEVER SCORES ARE MADE. SCORES MAY ALSO BE OBTAINED"
225 PRINT "BY INPUTING 99, $9 FOR PLAY NOS., TO PUNT OR ATTEMPT A"
227 PRINT "FIELDGOAL.. INPUT 77.- 77 FOR PLAY NOS,. QUESTIONS WILL BE"
230 PRINT "ASKED THEN. ON 4TH DOWN YOU WILL ALSO BE ASKED WHETHER"
240 PRINT "VOU WANT TO PUNT OR ATTEMPT A FIELD GOAL. IF THE ANSWER"
250 PRINT "TO BOTH QUESTIONS IS NO, IT WILL BE ASSUMED YOU WANT TO"
260 PRINT "TRY AND GAIN YARDAGE. ANSWER ALL QUESTIONS YES OR NO. "
270 PRINT "GAME IS PLAYED UNTIL PLAYERS TERMINATE (CONTROL-C)."
280 PRINT "PLEASE PREPARE A TAPE AND RUN, "\STOP
290 PRINT\PRINT "INPUT SCORE LIMIT ON GAME";\INPUT E
300 FOR I=1 TO 40\READ N\IF I<20 THEN 350
330 A(N)=I\GOTO 360
350 B(N)=I-20
360 C(I)=N\NEXT I
380 L=0\T=1
410 PRINT " TEAM" T" PLAY CHART"
420 PRINT "NO.       PLAY"\PRINT
430 PRINT C(1+L);TAB(6);"PITCHOUT"
440 PRINT C(2+L);TAB(6);"TRIPLE REVERSE"
450 PRINT C(3+L);TAB(6);"DRAW"
460 PRINT C(4+L);TAB(6);"QB SNEAK"
470 PRINT C(5+L);TAB(6);"END AROUND"
480 PRINT C(6+L);TAB(6);"DOUBLE REVERSE"
490 PRINT C(7+L);TAB(6);"LEFT SWEEP"
500 PRINT C(8+L);TAB(6);"RIGHT SWEEP"
510 PRINT C(9+L);TAB(6);"OFF TACKLE"
520 PRINT C(10+L);TAB(6);"WISHBONE OPTION"
530 PRINT C(11+L);TAB(6);"FLARE PASS"
540 PRINT C(12+L);TAB(6);"SCREEN PASS"
550 PRINT C(13+L);TAB(6);"ROLL OUT OPTION"
560 PRINT C(14+L);TAB(6);"RIGHT CURL"
570 PRINT C(15+L);TAB(6);"LEFT CURL"
580 PRINT C(16+L);TAB(6);"WISHBONE OPTION"
590 PRINT C(11+L);TAB(6);"SIDELINE PASS"
600 PRINT C(12+L);TAB(6);"HALF-BACK OPTION"
610 PRINT C(13+L);TAB(6);"RAZZLE DAZZLE"
620 PRINT C(14+L);TAB(6);"BOMB!!!!!!!!!"
630 L=L+20\T=2
640 PRINT\PRINT "TEAR OFF HERE -------------------------------------------------------"
660 FOR X=1 TO 11\PRINT\NEXT X
670 FOR Z=1 TO 3000\NEXT Z
680 IF L=20 THEN 410
690 D(1)=0\D(2)=3\M$(1)="--->"\M$(2)="<---"
700 H(1)=0\H(2)=0\T(1)=2\T(2)=1
710 W(1)=-1\W(2)=1\X(1)=100\X(2)=0
720 Y(1)=1\Y(2)=-1\Z(1)=0\Z(2)=100
725 GOSUB 1910
730 PRINT "TEAM 1 DEFENDS 0 YD   GOAL--TEAM 2 DEFENDS 100 YD  GOAL"
740 T=INT(2*RND(0)+1)
760 PRINT\PRINT "THEN COIN IS FLIPPED"
765 P=X(T)-Y(T)*40
770 GOSUB 1860\PRINT\PRINT "TEAM "T"RECEIVES KICK-OFF"
780 K=INT(26*RND(0)+40)
790 P=P-Y(T)*K
794 IF W(T)*P<Z(T)+10 THEN 810\PRINT\PRINT "BALL WENT OUT OF ENDZONE"
796 PRINT "--AUTOMATIC TOUCHBACK--"\GOTO 870
810 PRINT "BALL WENT"K"YARDS, NOW ON"P\GOSUB 1900
830 PRINT "TEAM"T" DO YOU WANT TO RUNBACK";\INPUT A$
840 IF A$="YES" THEN 1430\IF A$<>"NO" THEN 830
850 IF W(T)*P<Z(T) THEN 880
870 P=Z(T)-W(T)*20
880 D=1\S=P
885 PRINT "========================================================================"
890 PRINT\PRINT "TEAM"T" DOWN"D" ON"P;
893 IF D<>1 THEN 900
895 IF Y(T)*(P+Y(T)*10)>=X(T) THEN 898
897 C=4\GOTO 900
898 C=8
900 IF C=8 THEN 904
901 PRINT TAB(27);10-(Y(T)*P-Y(T)*S); "YARDS TO 1ST DOWN"
902 GOTO 910
904 PRINT TAB(27);X(T)-Y(T)*P; "YARDS TO GO"
910 GOSUB 1900\IF D=4 THEN 1180
920 RANDOMIZE
930 U=INT(3+RND(0)-1)\GOTO 940
936 PRINT "ILLEGAL PLAY NUMBER, CHECK AND"
940 PRINT "INPUT OFFENSIVE PLAY, DEFENSIVE PLAY";
950 IF T=2 THEN 970
960 INPUT P1,P2\GOTO 975
970 INPUT P2,P1
975 IF P1=77 THEN 1180
980 IF P1>20 THEN 1800\IF P1<1 THEN 1800
990 IF P2>20 THEN 1800\IF P2<1 THEN 1800
995 P1=INT(P1)\P2=INT(P2)
1000 Y=INT(ABS(A(P1)-B(P2))/19*((X(T)-Y(T)*P+25)*RND(0)-15))
1005 PRINT\IF T=2 THEN 1015
1010 IF A(P1)<11 THEN 1048\GOTO 1820
1015 IF B(P2)<11 THEN 1048
1020 IF U<>0 THEN 1035\PRINT "PASS INCOMPLETE TEAM"T
1030 Y=0\GOTO 1050
1035 G=RND(0)\IF G<.025 THEN 1040\IF Y>2 THEN 1045
1040 PRINT "QUARTERBACK SCRAMBLED "\GOTO 1050
1045 PRINT "PASS COMPLETED "\GOTO 1050
1048 PRINT "THE BALL WAS RUN"
1050 P=P-W(T)*Y
1060 PRINT\PRINT "NET YARDS GAINED ON DOWN"D"ARE "Y
1070 G=RND(0)\IF G>.025 THEN 1110
1080 PRINT\PRINT "** LOSS OF POSSESSION FROM TEAM "T" TO TEAM"T(T)
1100 GOSUB 1850\PRINT\T = T(T)\GOTO 830
1110 IF Y(T)*P>=X(T) THEN 1320
1120 IF W(T)*P>=Z(T) THEN 1230
1130 IF Y(T)*P-Y(T)*S>=10 THEN 880
1140 D=D+1\IF D<>5 THEN 885
1160 PRINT\PRINT "CONVERSION UNSUCCESSFUL TEAM"T\T=T(T)
1170 GOSUB 1850\GOTO 880
1180 PRINT "DOES TEAM"T"WANT TO PUNT";\INPUT A$
1185 IF A$="NO" THEN 1280\IF A$<>"YES" THEN 1180
1190 PRINT\PRINT "TEAM"T"WILL PUNT"\G=RND(0)\IF G<.025 THEN 1080
1195 GOSUB 1850\K=INT(25*RND(0)+35)\T=T(T)\GOTO 790
1200 PRINT "DOES TEAM"T"WANT TO ATTEMPT A FIELD-GOAL";\INPUT A$
1210 IF A$="YES" THEN 1640\IF A$<>"NO" THEN 1280\GOTO 920
1230 PRINT\PRINT "SAFETY AGAINST TEAM"T"------------------------- OH OH"
1240 H(T(T))=H(T(T))+2\GOSUB 1810
1280 PRINT " TEAM" T "DO YOU WANT TO PUNT INSTEAD OF A KICKQFF";\INPUT A$
1290 P=Z(T)-W(T)*20\IF A$="YES" THEN 1190
1320 PRINT\PRINT "TOUCHDOWN BY TEAM"T "**************** YEA TEAM"
1340 Q=7\G=RND(0)\IF G>.1 THEN 1380
1360 Q=6\PRINT "EXTRA POINT NO GOOD"\GOTO 1390
1380 PRINT "EXTRA POINT GOOD"
1390 H(T)=H(T)+Q\GOSUB 1810
1420 T=T(T)\GOTO 765
1430 K=INT(9*RND(0)+1)
1440 R=INT(((X(T)-Y(T)*P+25)*RND(0)-15)/K)
1460 P=P-W(T)*R
1480 PRINT\PRINT "RUNBACK TEAM "T; R"YARDS"
1485 RANDOMIZE\G=RND(0)\IF G<.025 THEN 1080
1490 IF Y(T)*P>=X(T) THEN 1320
1500 IF W(T)*P>=Z(T) THEN 1230\GOTO 880
1640 PRINT\PRINT "TEAM "T "WILL ATTEMPT A FIELDGOAL"
1645 RANDOMIZE\G=RND(0)\IF G<.825 THEN 1080
1650 F=INT(35*RND(0)+20)
1660 PRINT\PRINT "KICK IS"F" YARDS LONG"
1680 P=P-W(T)*F\RANDOMIZE\G=RND(0)
1690 IF G<.35 THEN 1735
1700 IF Y(T)*P<X(T) THEN 1740
1710 PRINT "FIELDGOAL GOOD FOR TEAM"T"*****************YEA"
1720 Q=3\GOTO 1390
1735 PRINT" BALL WENT WIDE"
1740 PRINT "FIELDGOAL UNSUCCESSFUL TEAM"T"--------------------- TOO BAD"
1742 GOSUB 1850\IF Y(T)*P<X(T)+10 THEN 1745\T=T(T)\GOTO 794
1745 PRINT\PRINT "BALL NOW ON "P
1750 T=T(T)\GOSUB 1900\GOTO 830
1770 DATA 17, 8, 4, 14, 19, 3, 10, 1, 7, 11, 15, 9, 5, 20, 13, 18, 16, 2, 12, 6
1780 DATA 20, 2, 17, 5, 8, 18, 12, 11, 1, 4, 19, 14, 18, 7, 9, 15, 6, 13, 16, 3
1800 IF P1<>99 THEN 936
1810 PRINT\PRINT "TEAM 1 SCORE IS"H(1)
1820 PRINT "TEAM 2 SCORE IS"H(2)\PRINT
1825 IF H(T)<E THEN 1830\PRINT "TEAM"T"WINS *************"\GOTO 2000
1830 IF P1=99 THEN 940\RETURN
1850 PRINT
1860 PRINT "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
1870 RETURN
1900 PRINT TAB(D(T)+5+P/2);M$(T)
1910 PRINT "TEAM 1 [0    10    20    30    40    50    60    70    80    90    100] TEAM 2" 
1920 PRINT
1930 RETURN
2000 END
