10 DIM D(20)
200 RANDOMIZE
202 LET L=1
205 PRINT"DO YOU WANT INSTRUCTIONS";
206 INPUT Z$
207 IF Z$="NO" THEN 400
210 PRINT"HELLO, ALL YOU BLOODLOVERS AND AFICIONADOS"
220 PRINT"HERE IS YOUR BIG CHANCE TO KILL A BULL"
230 PRINT
240 PRINT"ON EACH PASS OF THE BULL, YOU MAY TRY"
250 PRINT"0 - VERONICA (DANGEROUS INSIDE MOVE OF THE CAPE)"
260 PRINT"1 - LESS DANGEROUS OUTSIDE MOVE OF THE CAPE"
270 PRINT"2 - ORDINARY SWIRL OF THE CAPE"
280 PRINT
290 PRINT"INSTEAD OF THE ABOVE, YOU MAY TRY TO KILL THE BULL"
300 PRINT"ON ANY TURN: 4 (OVER THE HORNS), 5 (IN THE CHEST)"
310 PRINT"BUT IF I WERE YOU,"
320 PRINT"I WOULDN'T TRY IT BEFORE THE SEVENTH PASS"
330 PRINT
340 PRINT"THE CROWD WILL DETERMINE WHAT AWARD YOU DESERVE"
350 PRINT"POSTHUMOUSLY IF NECESSARY"
360 PRINT"THE BRAVER YOU ARE, THE BETTER THE AWARD YOU RECIEVE"
370 PRINT
380 PRINT"THE BETTER A JOB THE PICADORES AND TOREADORES DO,"
390 PRINT"THE BETTER YOUR CHANCES ARE"
400 PRINT
410 PRINT
420 LET D(5)=1
430 LET D(4)=1
450 DIM L$(5)
455 LET A=INT(RND(0)*5)+1
460 FOR I=1 TO 5
463 READ L$(I)
467 NEXT I
470 DATA "SUPERB", "GOOD", "FAIR", "POOR", "AWFUL"
490 PRINT"YOU HAVE DRAWN A ";L$(A);" BULL"
500 IF A>4 THEN 530
510 IF A<2 THEN 550
520 GOTO 570
530 PRINT"YOU'RE LUCKY"
540 GOTO570
550 PRINT"GOOD LUCK. YOU'LL NEED IT"
560 PRINT
570 PRINT
590 LET A$="PICADO"
595 LET B$="RES"
600 GOSUB 1610
610 LET D(1)=C
630 LET A$ = "TOREAD"
635 LET B$="ORES"
640 GOSUB 1610
650 LET D(2)=C
660 LET E=E
670 PRINT
680 IF Z=1 THEN 1310
690 LET D(3)=D(3)+1
700 PRINT"PASS NUMBER "D(3)
710 IF D(3)<3 THEN 760
720 PRINT"HERE COMES THE BULL! TRY FOR A KILL";
730 GOSUB 1930
735 ON Z1 GOTO 1130,740
740 PRINT "CAPE MOVE";
750 GOTO 800
760 PRINT"THE BULL IS CHARGING AT YOU! YOU ARE THE MATADOR--"
770 PRINT"DO YOU WANT TO KILL THE BULL";
780 GOSUB 1930
785 ON Z1 GOTO 1130,790
790 PRINT"WHAT MOVE DO YOU MAKE WITH THE CAPE";
800 INPUT E
810 IF E<>INT(ABS(E))THEN 830
820 IF E<3 THEN 850
830 PRINT"DON'T PANIC, YOU IDIOT! PUT DOWN A CORRECT NUMBER"
840 GOTO 800
850 LET D=D
860 IF E=0 THEN 920
870 IF E=1 THEN 900
880 LET M=0.5
890 GOTO 930
900 LET M=2
910 GOTO 930
920 LET M=3
930 LET L=L+M
940 LET F=(6-A+M/10)*RND(0)/((D(1)+D(2)+D(3)/10)*5)
950 IF F<0.51 THEN 660
960 PRINT"THE BULL HAS GORED YOU"
970 ON FNA(0) GOTO 980,1010
980 PRINT"Y0U ARE DEAD"
990 LET D(4)=1.5
1000 GOTO 1310
1010 PRINT"YOU ARE STILL ALIVE"
1020 PRINT"DO YOU RUN FROM THE RING";
1030 GOSUB 1930
1035 ON Z1 GOTO 1040,1070
1040 PRINT "COWARD"
1050 LET D(4)=0
1060 GOTO 1310
1070 PRINT"YOU ARE BRAVE. STUPID, BUT BRAVE"
1080 ON FNA(0) THEN 1090,1110
1090 LET D(4)=2
1100 GOTO 660
1110 PRINT"Y0U ARE GORED AGAIN"
1120 GOTO 970
1130 LET C=C
1140 LET Z=1
1150 PRINT"IT IS THE MOMENT OF TRUTH. HOW DO YOU TRY TO KILL THE BULL";
1160 INPUT H
1170 IF H=4 THEN 1230
1180 IF H=5 THEN 1230
1210 PRINT"YOU PANICKED. THE BULL GORED YOU."
1220 GOTO 970
1230 LET K=(6-A)*10*RND(0)/((D(1)+D(2))*5*D(3))
1240 IF J=4 THEN 1290
1250 IF K>0.2 THEN 960
1260 PRINT"YOU KILLED THE BULL"
1270 LET D(5)=2
1280 GOTO 1320
1290 IF K>0.8 THEN 960
1300 GOTO 1260
1310 PRINT
1320 PRINT
1330 PRINT
1340 IF D(4)<>0 THEN 1390
1350 PRINT"THE CROWD BOOS FOR TEN MINUTES. IF YOU EVER DARE TO SHOW"
1360 PRINT"YOUR FACE IN A RING AGAIN. THEY SWEAR THEY WILL KILL YOU—-"
1370 PRINT"UNLESS THE BULL DOES FIRST"
1380 GOTO 1580
1390 DEF FNC(Q)=(4.5+L/6-(D(1)+D(2))*2.5+4*D(4)+2*D(5)-(D(3)^2)/120-A)*0.5
1400 IF D(4)<>2 THEN 1430
1410 PRINT"THE CROW CHEERS WILDLY"
1420 GOTO 1450
1430 IF D(5)<>2 THEN 1450
1440 PRINT"THE CROWD CHEERS"
1450 PRINT "THE CROWD AWARDS YOU ";
1451 PRINT "(";Q;",";FNC(Q);") ";
1460 IF FNC(Q)<2.4 THEN 1570
1470 IF FNC(Q)<4.9 THEN 1550
1480 IF FNC(Q)<7.4 THEN 1520
1500 PRINT"OLE! YOU ARE 'MUY HOMBRE'! OLE! OLE!"
1510 GOTO 1580
1520 PRINT"BOTH EARS OF THE BULL"
1530 PRINT"OLE!"
1540 GOTO 1580
1550 PRINT"ONE EAR OF THE BULL"
1560 GOTO 1580
1570 PRINT"NOTHING"
1580 PRINT
1590 PRINT "ADIOS"
1600 GOTO 2030
1610 LET B=3/A*RND(0)
1620 IF B<0.37 THEN 1740
1630 IF B<0.5 THEN 1720
1640 IF B<0.63 THEN 1700
1650 IF B<0.87 THEN 1680
1660 LET C=0.1
1670 GOTO 1750
1680 LET C=0.2
1690 GOTO 1750
1700 LET C=0.3
1710 GOTO 1750
1720 LET C=0.4
1730 GOTO 1750
1740 LET C=0.5
1750 LET T=INT(10*C+0.2)
1760 PRINT"THE "A$;B$" DID A "L$(T);" JOB"
1770 IF 4>T THEN 1900
1780 IF 5=T THEN 1870
1790 ON FNA(K) GOTO 1800,1900
1800 IF A$="TOREAD" THEN 1820
1810 PRINT"0NE OF THE HORSES OF THE "A$;B$" WAS GORED"
1820 ON FNA(K) GOTO 1830,1850
1830 PRINT"ONE OF THE "A$;B$" WAS KILLED"
1840 GOTO 1900
1850 PRINT"NO "A$;B$" WERE KILLED"
1860 GOTO 1900
1870 IF A$="TOREAD" THEN 1890
1880 PRINT FNA(K);" OF THE HORSES OF THE "A$;B$;" GORED"
1890 PRINT FNA(K);" OF THE "A$;B$;" KILLED"
1900 PRINT
1910 RETURN
1920 DEF FNA(K)=INT(RND(0)*2)+1
1930 INPUT A$
1950 IF A$="YES" THEN 1990
1960 IF A$="NO" THEN 2010
1970 PRINT"INCORRECT ANSWER, PLEASE PRINT 'YES' OR 'NO'";
1980 GOTO 1930
1990 LET Z1=1
2000 GOTO 2020
2010 LET Z1=2
2020 RETURN
2030 END

