100 REM *** PROGRAM SIMULATES TV PROGRAM STARTREK
110 REM *** WRITTEN BY MIKE MAYFIELD, CENTERLINE ENGINEERING
120 REM *** DEBUGGING AND MINOR REViSIONS BY LEO LAVERDURE, IRA POTEL,
130 REM *** MARY COLE, AND DAVE AHL OF DIGITAL
170 RANDOMIZE
180 PRINT "                  * * * STAR TREK * * *":PRINT
200 INPUT "DO VOU WANT INSTRUCTIONS (THEY'RE LONG!)";A$
210 IF AS$<>"YES" THEN 230
220 GOTO 5820
230 REM *** PROGRAM BEGINS HERE
240 Z$,R$,Q$="
260 DIM G(8,8),C(9,2),K(3,3),N(3),Z(8,8)
290 T0,T=INT(RND(1)*20+20)*100
300 T9=30:D0=0:E0,F=3000:P0,P=10:S9=200:S,H8=0
360 DEF FND(D)=SQR((K(I,1)-S1)**2(+K(I,2)-82)**2)
370 Q1=INT(RND(1)*8+1)
380 Q2=INT(RND(1)*8+1)
390 S1=INT(RND(1)*8+1)
400 S2=INT(RND(1)*8+1)
410 T7=TIME(0)
420 C(2,1),C(3,1),C(4,1),C(4,2),C(5,2),C(6,2)=-1
430 C(1,1),C(3,2),C(5,1),C(7,2),C(9,1)=0
440 C(1,2).C(2,2),C(6,1),C(7,1),C(8,1),C(8,2),C(9,2)=1
450 MAT D=ZER
460 D$="WARP ENGINESS.R.SENSORSL.R.SENSORSPHASER CNTRL"
470 D$=D$+"PHOTON TUBESDAMAGE CNTRL"
480 E$="SHIELD CNTRLCOMPUTER"
490 B9,K9=0
491 REM *** SETS UP WHAT EXISTS IN GALAXY
500 FOR I=1TO8
510 FOR J=1TO8
520 R1=RND(1)
530 IF R1>.98 THEN 580
540 IF R1>.95 THEN 610
550 IF R1>.8 THEN 640
560 K3=0:GOTO 660
580 K3=3:K9=K9+3:GOTO 660
610 K3=2;K9=K9+2:GOTO 660
640 K3=1:K9=K9+1
660 R1=RND(1)
670 IF R1>.96 THEN 700
680 B3=0:GOTO 720
700 R3=1:B9=B9+1
720 S3=INT(RND(1)*8+1)
730 G(I,J)=K3*100+B3*10+S3
740 Z(I,J)=0
750 NEXT J
760 NEXT I
770 K7=K9
775 PRINT:PRINT
780 PRINT"YOU MUST DESTROY"K9" KLINGONS IN"T9" STARDATES WITH "B9" STABBASES"
790 IP B9>0 THEN 810
800 G(6,3)=114
810 K3,B3,S3=0
820 IF Q1<1 OR Q1>8 OR Q2<1 OR Q2>8 THEN 990
830 X=G(Q1,Q2)*.01
840 K3=INT(X)
850 B3=INT((X-K3)*10)
860 S3=G(Q1,Q2)-INT(G(Q1,Q2)*.1)+10
870 IF K3=0 THEN 910
880 IF S>200 THEN 910
890 PRINT"COMBAT AREA      CONDITION RED"
900 PRINT"   SHIELDS DANGEROUSLY LOW"
910 MAT K=ZER
920 FOR I=1TO3
930 K(I,3)=0
940 NEXT I
950 Q$=Z$:R$=Z$
970 S$=MID$(Z$,1,48)
971 REM *** PUT ENTERPRISE SOMEWHERE
980 A$="<*>"
990 Z1=S1
1000 Z2=S2
1010 GOSUB 5510
1020 FOR I=1TOK3
1030 GOSUB 5380
1031 REM *** PUT KLTNGONS SOMEWHERE
1040 A$="+++"
1050 Z1=R1
1060 Z2=R2
1070 GOSUB 5510
1080 K(I,1)=R1:K(I,2)=R2:K(I,3)=S9
1110 NEXT I
1120 FOR I=1TOB3
1130 GOSUB 5380
1131 REM *** PUT STARBASE(S) SOMEWHERE
1140 A$=">1<":Z1=R1:Z2=R2
1170 GOSUB 5510
1180 NEXT I
1190 FOR I=1TOS3
1200 GOSUB 5360
1201 REM *** PUT STARS SOMEWHERE
1210 A$=" * ":Z1=R1:Z2=R2
1240 GOSUB 5510
1250 NEXT I
1260 GOSUB 4120
1270 INPUT "COMMAND:";A
1290 IF A=0 GOTO 1410
1291 IF A=1 GOTO 1260
1292 IF A=2 GOTO 2330
1293 IF A=3 GOTO 2530
1294 IF A=4 GOTO 2800
1295 IF A=5 GOTO 3460
1296 IF A=6 GOTO 3560
1297 IF A=7 GOTO 4630
1298 IF A=8 GOTO 6510
1310 PRINT:PRINT"   0 = SET COURSE"
1320 PRINT"   1 = SHORT RANGE SENSOR SCAN"
1330 PRINT"   2 = LONG RANGE SENSOR SCAN"
1340 PRINT"   3 = FIRE PHASERS"
1350 PRINT"   4 = FIRE PHOTON TORPEDOES"
1360 PRINT"   5 = SHIELD CONTROL"
1370 PRINT"   6 = DAMAGE CONTROL REPORT"
1380 PRINT"   7 = CALL ON LIBRARY COMPUTER"
1390 PRINT"   8 = END THE CONTEST":PRINT
1400 GOTO 1270
1401 REM *** COURSE, CONTROL CODE BEGIMS HERE
1410 INPUT "COURSE (1-9):";C1
1430 IF C1=0 THEN 1270
1440 IF C1<1 OR C1>9 THEN 1410
1450 INPUT "WARP FACTOR (0-8):";W1
1470 IF W1<1 OR W1>8 THEN 1410
1480 IF D(1)>0 OR W1<=.2 THEN 1810
1490 PRINT "WARP ENGINES ARE DAMAGEO. MAXIMUM SPEED = WARP .2"
1500 GOTO 1410
1510 IF K3<=0 THEN 1560
1520 GOSUB 3790
1530 IF K3<=0 THEN 1560
1540 IF S<0 THEN 4000
1550 GOTO 1610
1560 IF E>0 THEN 1610
1570 IF S<1 THEN 3920
1580 PRINT "YOU HAVE"E" UNITS OF ENERGY"
1590 PRINT "SUGGEST YOU GET SOME FROM YOUR SHIELDS WHICH HAVE"S" UNITS LEFT"
1600 GOTO 1270
1610 FOR I=1TO8:IF D(I)>0 THEN 1640
1611 REM *** FIX ANY DAMAGED DEVICE
1630 D(I)=D(I)=1
1640 NEXT I
1650 IF RND(&)>.2 THEN 1810
1660 B1=INT(RND(1)*8=1)
1670 IF RND(1)>= .5 THEN 1750
1680 D(B1)=D(B1)-(RND(1)*5+1)
1690 PRINT:PRINT "DAMAGE CONTROL REPORT:";
1710 GOSUB 5610
1720 PRINT" DAMAGED":PRlNT:GOTO 1810
1750 D(B1)=D(B1)+(RND(1)*5+1))
1760 PRTNT:PRINT "DAMAGE CONTROl REPORT:";
1780 GOSUB 5610
1790 PRINT" STATE OF REPAIR IMPROVED":PRINT
1810 N=INT(W1*8):A$="   ":Z1=S1:Z2=S2
1850 GOSUB 5510
1860 X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1))
1870 X=S1;Y=S2
1890 X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1))
1900 X2=C(C1,2)+(C(C1+1,2)-C(C1,2))*(C1-INT(C1))
1910 FOR I=1T0N:S1=S1+X1:S2=S2+X2
1940 IF S1<1 OR S1>=9 OR S2<1 OR S2>=9 THEN 2170
1950 S8=S1*24+S2*3-26: IF S8>72 THEN 1990
1970 IF MID(Q$,S8,3)="   " THEN 2070
1980 GOTO 2030
1990 IF S8>144 THFN 2020
2000 IF MID(R$,S8-79,3)="   " THEN 2070
2010 GOTO 2030
2020 IF MID(S$,S8-144,3)="   " THEN 2070
2030 PRINT"WARP ENGINES SHUTDOWN AT SECTOR "S1"."S2" DUE TO BAD NAVAGATION"
2040 S1=S1-X1:S2=S2-X2:G0T0 2080
2070 NEXT I
2080 A$=:<*>":Z1=S1:Z2=S2
2110 GOSUB 5510
2120 E=E-N+5:IF W1<1 THEN 2150
2140 T=T+1
2150 IF T>T0+T9 THEN 3970
2160 GOTO 1260
2170 X=Q1*8+X+X1*N:Y=Q2*8+Y+X2*N
2190 Q1=INT(X/8):Q2=INT(Y/8):S1=INT(X-Q1*8):S2=INT(Y-Q2*8)
2230 IF S1<>0 THEN 2260
2240 Q1=Q1-1:S1=8
2260 IF S2<>0 THEN 2290
2270 Q2=Q2-1:S2=8
2290 T=T+1:F=F-N+5
2310 IF T>T0 + T9 THEN 3970
2320 GOTO 810
2321 REM *** LONG RANGE SENSOR SCAN CODE BEGINS HERE
2330 IF D(3)>0 THEN 2370
2340 PRINT "LONG RANGE SENSORS ARE INOPERABLE"
2360 GOTO 1270
2370 PRINT "LONG RANGE SENSOR SCAN FOR QUADRANT "Q1"."Q2
2380 PRINT"-------------------"
2390 FOR I=Q1-1 TO Q1+1
2400 MAT N=ZER
2410 FOR J=Q2-1 TO Q2+1
2420 IF I<1 OR I>8 OR J<1 OR J>8 THEN 2460
2430 N(J-Q2+2)=G(I,J)
2440 IF D(7)<0 THEN 2460
2450 Z(I,J)=G(I,J)
2460 NEXT J
2470 P1$=": ### : ### : ### :"
2471 PRINT USING P1$N(1),N(2),N(3)
2480 PRINT"------------------"
2490 NEXT I
2500 GOTO 1270
2501 REM *** PHASER CONTROL CODE BEGINS HERE
2530 IF K3<=0 THEN 3670
2540 IF D(4)>0 THEN 2570
2560 GOTO 1270 
2570 IF D(7)>0 THEN 2590
2580 PRINT " COMPUTER FAILURE HAMPERS ACCURACY"
2590 PRINT"PHASERS LOCKED ON TARGET, ENERGY AVAILABLE="E
2600 INPUT "NUMBER OF UNITS TO FIRE:";X
2620 IF X<0 1270
2630 IF E-X<0 THEN 2570
2640 E=E-X
2650 GOSUB 3790
2660 IF D(7)>0 THEN 2680
2670 X=X*RND(1)
2680 FOR I=1TO3
2690 IF K(I,3)<=0 THEN 2770
2700 H=INT((X/K/FND(0))*(2*RND(1)))
2710 K(I,3)=K(I,3)-H
2720 PRINTH" UNIT HIT ON KLINGON AT SECTOR "K(I,1)"."K(I,2);
2730 PRINT"    ("K(I,3)" LEFT)"
2740 IF K(I,3)>0 THEN 2770
2750 GOSUB 3690
2760 TF K9<=0 THEN 4040
2770 NEXT I
2780 IF E<0 THEN 4000
2790 GOTO 1270
2791 REM *** PHOTON TORPEDO CODE BEGINS HERE
2800 IF D(5)>=0 THEN 2830 
2810 PRINT "PHOTON TUBES ARE NOT OPERATIONAL"
2820 GOTO 1270
2830 IF P>0 THEN 2860
2840 PRTNT "ALL PHOTON TORPEDOES EXPENDED"
2850 GOTO 1270
2860 INPUT "TORPEDO COURSE (1-9):";C1
2880 IF C1<0 THEN 1270
2890 IF C1<1 OR C1>9 THEN 2860
2900 X1=C(C1,1)+(C(C1+1,1)-C(C1,1))*(C1-INT(C1))
2910 X2=C(C1,2)+(C(C1+1,2)-C(C1,2))*(C1-INT(C1))
2920 X=S1:Y=S2:P=P-1
2950 PRINT "TORPEDO TRACK:"
2960 X=X+X1:Y=Y+Y2
2980 IF X<1 OR X>=9 OR Y<1 OR Y>=9 THEN 3420
2990 PRINT"               "X"."Y
3010 A$="   ";Z1=X:Z2=Y
3040 GOSUB 5680
3050 IF Z3=0 THEN 3220
3060 GOTO 2960
3070 A$="***":Z1=X:Z2=Y
3100 GOSUB 5680
3110 IF Z3=0 THEN 3220
3120 PRINT "*** KLINGON DESTROYED ***"
3130 K3=K3-1:K9=K9-1
3150 IF K9<=8 THEN 4040
3160 FOR I=1TO3:IF INT(X)=K(I,1) THEN 3190
3100 IF INT(Y)<>K(I,2) THEN 3200
3190 NEXT I
3200 K(I,3)=0:GOTO 3360
3220 A$=" * ":Z1=X:Z2=Y
3230 GOSUB 5680
3240 IF Z3=0 THEN 3290
3270 PRINT "YOU CAN'T DESTROY STARS, SILLY"
3280 GOTO 3420
3290 A$=">1<":Z1=X:Z2=Y
3320 GOSUB 5660
3330 IF Z3=0 THEN 2690
3340 PRINT "*** STAR BASE DESTROYED *** .......CONGRATULATIONS"
3350 B3=B3-1
3360 A$="   ":Z1=X:Z2=Y
3390 GOSUB 5510
3400 G(Q1,Q2)=K3*100+B3*10+S3
3410 GOTO 3430
3420 PRINT "TORPEDO MISSED"
3430 GOSUB 3790
3440 IF E<0 THEN 4000
3450 GOTO 1270
3431 REM *** SHIELD CONTROL CODE BEGINS HERE
3460 IF D(7)>=0 THEN 3490
3470 PRINT "SHIELD CONTROL IS NON-OPERATIONAL"
3480 GOTO 1270
3490 PRINT "ENERGY AVAILABLE ="F*S;
3500 INPUT "   NUMBER OF UNTTS TO SHIELDS:";X
3510 IF X<=0 THEN 1270
3520 IF E+S-X<0 THEN 3490
3530 F=E+S-X:S=X
3550 GOTO 1270
3551 REM *** DAMAGE CONTROL RFPORT CODE BEGINS HERE
3560 IF D(6)>0 THEN 3590
3570 PRINT "DAMAGE CONTROL REPORT IS NOT AVAILABLE"
3580 GOTO 1270
3590 PRINT\PRINT "DEVICE STATE OF REPAIR"
3610 FOR R1=1TO8
3620 GOSUB 5610
3630 PRINTD(R1)
3640 NEXT R1:PRINT
3660 GOTO 1270
3670 PRINT"SHORT RANGE SENSORS REPORT NO KLINGONS IN THIS QUADRANT"
3680 GOTO 1270
3690 PRINT "KLINGON AT SECTOR "K(I,1)","K(I,2)"DESTROYED ***"
3710 K3=K3-1:K9=K9-1:A$="   ":Z1=K(I,1):Z2=K(I,2)
3760 GOSUB 5510
3770 G(Q1,Q2)=K3*100+B3*10+S3
3780 RETURN
3790 IF C$<>"DOCKED" THEN 3820
3800 PRINT "STAR BASE SHIELDS PROTECT THE ENTERPISE"
3810 RETURN
3820 IF K3<=0 THEN 3910
3830 FOR I=1T03:IF K(I,3)<=0 THEN 3900
3850 H=INT((K(l,3)/FND(0))*(2+RND(1))):S=S-H
3670 PRINTH" UNIT HIT ON ENTERPRISE AT SECTOR "K(I,1)","K(I,2);
3871 PRINT"     ("S" LEFT)"
3890 IF S<0 THEN 4000
3900 NEXT I
3910 RETURN
3920 PRINT "THE ENTERPRISE IS DFAD IN SPACE. IF YOU SURVIVE ALL IMPENDING"
3930 PRINT "ATTACKS YOU WILL RE DEMOTED TO THE RANK OF PRIVATE"
3940 IF K3<=0 THEN 4020
3950 GOSUB 3790
3960 GOTO 3940
3970 PRINT\PRINT "IT IS STARDATE"T
3990 GOTO 4020
3991 REM *** NO ENERGY LEFT
4000 PRINT:PRINT"THE ENTERPRISE HAS BEEN DESTROYED. THF FEOERATION WILL BE CONQUERED"
4020 PRINT "THERE ARE STILL "K9" KLINGON BATTLE CRUISERS"
4030 PRINT:PRINT:PRINT;PRINT "YOU GET ANOTHER CHANCE...":GOTO 230
4040 PRINT:PRINT"THF LAST KLINGON BATTLE CRUISER IN THE GALAXY HAS BEEN DESTROYED"
4050 PRINT"THF FEDERATION HAS BEEN SAVED!!!!!":PRINT
4075 E5=((K7/(T-T0))*1000)
4080 PRINT "YOUR EFFICIENCY RATING ="E5
4100 PRINT"YOUR ACTUAL TIME OF MISSION ="INT((TIME(0)-T7)/60:" MINUTES"
4105 PRINT:PRINT;PRINT
4106 INPUT"DO YOU WANT TO TRY AGAIN";R$
4107 IF R$ = "YES" THEN 250
4110 GOTO 6510
4111 REM *** SHORT RANGE SENSOR SCAN AND STARTING POINT CODE
4120 FOR I=S1-1TO S1+1
4130 FOR J=S2-1TO S2+1
4140 IF I<1 OR I>8 OR J<1 OR J>8 THEN 4200
4150 A$=">1<":Z1=I:Z2=J
4100 GOSUB 5680
4190 IF Z3=1 THEN 4240
4200 NEXT J
4210 NEXT I
4220 D0=0:GOTO 4310
4240 D0=1:C$="DOCKED":E=3000:P=10
4200 PRINT "SHIELDS DROPPED FOR DOCKING PURPOSES"
4290 S=0:GOTO 4380
4300 IF K3>0 THEN 4350
4320 IF E<E0 *.1 THEN 4370
4330 C$="GREEN"
4340 GOTO 4360
4300 C$="REO":GOTO 4380
4370 C$="YELLOW":
4300 IF D(2)>=0 THEN 4430
4390 PRINT:PRINT"*** SHORT RANGE SENSORS ARE OUT ***":PRINT
4420 GOTO 4530
4430 O1$="—-----—-----—----------—--------"
4430 PRINT USING O1$
4440 O2$" \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \"
4445 PRINT USING O2$,MID(O$,1,3),MID(O$,4,3),MID(O$,7,3),MID(O$,10,3),MID(O$,13,3),MID(O$,16,3),MID(O$,19,35),MID(O$,22,3)
4450 O3$=O2$+"        STARDATE         #####"
4455 PRINT USING O3$,MID(O$,25,3),MID(O$,28,3),MID(O$,31,3),MID(O$,34,3),MID(O$,37,3),MID(O$,40,3),MID(O$,43,35),MID(O$,46,3),T
4560 O4$=O2$+"        CONDITION        \    \"
4565 PRINT USING O4$,MID(O$,49,3),MID(O$,52,3),MID(O$,55,3),MID(O$,58,3),MID(O$,61,3),MID(O$,64,3),MID(O$,67,35),MID(O$,70,3),C$
4570 O5$=O2$+"        QUADRANT         "
4475 PRINT USING O5$,MID(R$,1,3),MID(R$,4,3),MID(R$,7,3),MID(R$,10,3),MID(R$,13,3),MID(R$,16,3),MID(R$,19,35),MID(R$,22,3),Q1
4476 PRINT ",";Q2
4480 O6$=O2$+"        SECTOR           #"
4485 PRINT USING O6$,MID(R$,25,3),MID(R$,28,3),MID(R$,31,3),MID(R$,34,3),MID(R$,37,3),MID(R$,40,3),MID(R$,43,35),MID(R$,46,3),S1;
4486 PRINT ",";S2
4490 O7$=O2$+"        TOTAL ENERGY   ######"
4495 PRINT USING O7$,MID(R$,49,3),MID(R$,52,3),MID(R$,55,3),MID(R$,58,3),MID(R$,61,3),MID(R$,64,3),MID(R$,67,35),MID(R$,70,3),E
4500 O8$=O2$+"        PHOTON TORPEDOES  ###"
4505 PRINT USING O8$,MID(S$,1,3),MID(S$,4,3),MID(S$,7,3),MID(S$,10,3),MID(S$,13,3),MID(S$,16,3),MID(S$,19,35),MID(S$,22,3),P
4510 O9$=O2+"         SHIELDS        ######"
4515 PRINT USING O6$,MID(S$,25,3),MID(S$,28,3),MID(S$,31,3),MID(S$,34,3),MID(S$,37,3),MID(S$,40,3),MID(S$,43,35),MID(S$,46,3),S
4520 PRINT USING O1$
4530 RETURN
4620 REM *** LIBRARY COMPUTER CODE BEGINS HERE"
4630 IF D(8)>=0 THEN 4660
4640 PRINT "COMPUTER DISABLED":GOTO 1270
4660 INPUT "CDMPUTER ACTIVE AND AWAITING COMMAND:";A
4680 IF A=0 GOTO 4740
4681 IF A=1 GOTO 4830
4682 IF A=2 GOTO 4880
4690 PRINT "FUNCTIONS AVAILABLE FROM COMPUTER"
4700 PRINT "   0 = CUMULATIVE GALACTIC RECORD"
4710 PRINT "   1 = STATUS REPORT"
4720 PRINT "   2 = PHOTON TORPEDO DATA"
4730 GOTO 4660
4731 REM *** CUMULATIVE GALACTIC RECORD CODE BEGINS HERE
4740 PRINT"COMPUTER RECORD OF GALAXY FOR QUADRANT "Q1","Q2
4760 PRINT"     1     2     3     4     5     6     7     8" 
4770 PRINT"   ----- ----- ----- ----- ----- ----- ----- -----"
4780 FOR I=1TO8
4790 N1$="#   ###   ###   ###   ###   ###   ###   ###   ###"
4795 PRINT USING N1$,I,Z(I,1),Z(I,2),Z(I,3),Z(I,4),Z(I,5),Z(I,6),Z(I,7),Z(I,8)
4800 PRINT"   ----- ----- ----- ----- ----- ----- ----- -----"
4810 NEXT I
4820 GOTO 1270
4821 REM *** STATUS REPORT CODE BEGINS HERE
4830 PRINT "   STATUS REPORT"
4840 PRINT "NUMBER OF KLINGONS LEFT ="K9
4850 V5=(T0+T9)-T
4851 PRJNT "NUMRER OF STARDATES LFFT =";V5
4860 PRINT "NUMBER OF STARBASES LEFT ="B9
4870 GOTO 3560 
4880 PRINT:H8=0
4881 REM *** PHOTON TORPEDO DATA CODE BEGINS HERE
4900 FOR I=1TO3
4910 IF K(I,3)<=0 THEN 5260
4920 C1=S1:A=S2:W1=K(I,1):X=K(I,2)
4960 GOTO 5010
4970 PRINT"YOU ARE AT QUADRANT ( "Q1","Q2" ) SECTOR ( "S1","S2" )"
4990 INPUT "SHIP ANO TARGET COORDINATES ARE:";C1,A,W1,X
5010 X=X-A:A=C1-W1
5030 IF X<0 THEN 3130
5031 IF A<0 THEN 5190
5050 IF X>0 THEN 5070
5050 IF A=0 THEN 3150
5070 C1=1
5080 IF ABS(A) <= ABS(X) THEN 5110
5085 V5=C1(((ABS(A)-ABS(X))+ABS(A))/ABS(A)
5090 PRINT "DIRECTION ="V5
5100 GOTO 5240
5110 PRINT "DIRECTION ="C1+(ABS(A)/ABS(X))
5120 GOTO 5240
5130 IF A>0 THEN 5170
5140 IF X=0 THEN 5190
5150 C1=5:GOTO 5080
5170 C1=3:GOTO5200
5190 C1=7
5200 IF ABS(A)>=ABS(X) THEN 5230
5210 PRINT "DIRECTION ="C1+(((ABS(X)-ABS(A))+ABS(X))/ABS(X)
5220 GOTO 5240
5230 PRINT "DIRECTION ="C1+(ABS(X)/ABS(A))
5240 PRINT "DISTANCE ="SQR(X**2*A**2)
5250 IF H8=1 THEN 5320
5260 NEXT I
5270 H8=0
5280 INPUT "DO YOU WANT TO USE THE CALCULATOR";A$
5300 IF A$="YES" THEN 4970
5310 IF A$<>"NO" THEN 5280
5320 GOTO 1270
5321 REM *** END OF. LIBRARY COMPUTER CODE
5380 R1=INT(RND(1)*8+1):R2=INT(RND(1)*8+1):A$="    ":Z1=R1:Z2=R2
5430 GOSUB 5680
5440 IF Z3=0 THEN 5380
5450 RETURN
5510 REM *** INSERTION IN STRING ARRAY FOR QUADRANT ***

S8»Z«.*24 + Z9*3«?6^IF S8&gt;72 THEN 558« 

Q$fLPFT(Q$7s«"n*AS*RlSHT (OS. 88*35 

GOTO 5600 

IF S8M44 THEN, 5590 

RS|LPFT(R$.S8i.73UA$*RTGHTrR«,38»69 5 

GOTO 5600 

SS»LFFT(SS.S8«.T455iAS*RlGHT(S$7sB"V415 

RETURN 

REM *** PRINTS DEVICE NAME FROM ARRAY*** 

58"R1*12»11 IIF.S8&gt;72 THEM 3660 

PRJNT MlO(OS.S8 f H1. »GQTO 3670 

PRINT MID(E$.SB»72,115. 

RETURN 



203 



5680 
5600 
57!&gt;0 
5730 
5750 
5760 
5770 
5790 
5800 
5810 
5820 
5821 
58?2 
58S»3 
5830 
3840 
5850 
5870 
5880 
5890 
5900 
5910 
5920 
5930 
5940 
5950 
5960 
5970 
5980 
5990 
6000 
6005 
60f0 
6020 
6030 
6040 
6045 
6060 
6070 
6080 
6090 
6100 
6110 
61?0 
6130 
6140 
6150 
6160 
6170 
6180 
6190 
6200 
6210 
6220 
6230 
6240 
6250 
6251 
6260 
6270 
6280 
6290 
6300 
6310 
6320 
6330 
6340 
6350 
6360 
6370 
6380 
6390 
6400 
6500 
651*0 



REM ***STRING COMPARISON IN QUADRANT ARRAY*** 

88»ZJ*?4+Z?*3»?6»Z3"aiTF S8&gt;72 THEM 5750 

IF MTDfO*,88.3W&gt;A* THPN 5810 

73«l»GPTn «58[0 

IF 88&gt;1 44 THFN 5790 

TF MTOfR*, 88-79. 3i&lt;&gt;A$ THEM 5810 

73-lfGOTft 5810 

TF MTDfS*. 88-144. 31&lt;&gt;A* THFN S'«l« 

73"1 

RETURN 

ft" INSTRUCTIONS" 

ft|ft«THF GALAVY.IS DIVIDED TNTO AN S.S OUADPANT GRID" 

RW.WHICW IS IN TURN DTVTDFD INTO AN fl.fl SECTOR GRID*." 

ft|ft"THE CAST OF CHARACTERS IS AS FOLLOWS*!" 

*««*» ■ FNTERPRI8E" 

ftn**.* « KLTNttON" 

»,»&gt;!« « STARRASE"!* " * ■ STAR" 

R»COMMANO «■■ WARP ENGTNF, CONTROL I " 

ft" COURSE IS TN A CTRpui'AP NUMERICAL 4 3 2" 

ft" VECTOR ARRANGEMENT A* SHOWN. \ a /" 

ft" INTEGER AND REAL VALUE* MAY BE W« 

ft" USED. THEREFORE COURSF f&gt; TS 5 — — 1" 

I" HALF WAY BFTWEEN 1 AND 2. /X\ « 



ft" 
*" 



ft" 



A VECTOR OF 9 IS UMDPFTNPD. 
VALUES MAY APPROACH 0.« 



RUT 



8« 



ONF WARP FACTOR TS T M E STZF Of" 
ONE OUADRANt'. THEREFORE TO GET" 

from quadrant 6.5 to 5.5 you w0(jld" 
usf course 3. warp factor i« 



ft"CQMMAND 1 ■ SHORT RAMG* SENSOR SCAWH 

ft" PRTNT THF OUADRANT YOU ARE CURRENT! Y IN. INCLUDING" 

ft" STARS. KLINGONS. STARBASFsT AND THF ENTERPRISE^ ALONG" 

M WITH OTHER PFRTINATE INFORMATION*. « 

ft|ft«COMMAND ? m LONG RANGE SFNSOR SCAN" 

ft" SHOWS CONDITIONS IN SPAeF FOR DNF QUADRANT ON EACH STDF« 

%» OF THE ENTFRPRISF TN THE MTDDLF OF THE SCAN. THE SCAN" 

ft" TS CODFD IN THE FORM XYX. WHFRF THF UNTTS DIGIT 1$ THE « 

t" MUMBFR OF STARS. THE T^NS DIGIT TS THE NUMBER OF STAR-" 

ft" PASES. THF HUNDREDS DTGTT IS THF MUMBFR QF KlTmGOMs'." 

ft|ft«CO M MAND 3 « PHASFR CONTROL" 

ft" ALLOWS YOU. TO DESTROY T H F KLTNftQNS BY MITTTNR HIM WITH" 

ft" SUTTABI Y LARGE NUMBERS OF PNFRGY UNITS. TO DEPLFTF HIS " 

ft" SHIELD POWFRl KFEP TN MTNf&gt; THAT WHEN YOU SHOOT AT HIM." 

ft" HE GONNA SHOOT AT VO". TOO!" 

ft|ft«COMMAND A ■ PHOTON TORPEDO CONTROL" 

ft" COURSE IS THF SAME AS I'SFO IN WARP ENGTNF OONTRO! '..* 

ft" TF YOU. HIT THE Kt INGON^ HE IS DESTROYED AND' CANNOT FTRF" 

ft" PACK AT VOU. IF YOU MTS8. YOU ARE SUBJECT TO HIS « 

ft" PHASFR FTRF." 

ft*ft« NOTE! THE LIBRARY COMPUTER '("COMMAND, 7i HAS AN OPTTQN" 

ft" TO COMPUTE TORPEDO TRAJECTORY FflR YQIJ ("OPTION ?)'.» 

HtHWCOMMANn 5 ■ SHIELD CONTROL" 

ft" DEFINES NUMBER OF FNFRGY UNITS TO BE ASSIGNED TO SHIFLDS" 

ft" FNFRGY IS TAKEN FRDM_TOTAL SHIPIS FNPRGY*." 

ft" NOTE THAT TOTAL FNFRV TNCL.HDFS SHIFLD FNFRGyI" 

ft|ft«COMMAND 8 * DAMAGE CONTROL REPORT" 

ft" GIVES STATP OF RFPAIRS OF ALL DEVICES. A STAT? OF RFpAIR" 

ft" LESS THAN 7ER0 SHOWS THAT THF DEVICE IS TEMPORARALY" 

ft" DAMAGED." 

ft|ft»CO M MAND 7 « LIBRARY COMPUTER" 

ft" THE i IRRARY COMPUTFR, CONTAINS THREF OPTIONSV 

ft" OPTION 0b CUMULATTVF GAIACTTC RFCORD" 

HM WHICH SHOWS COMPMTFR MFMORY OF THE RFSHLTS" 

ft" OF ALL PREVIOUS i'ONG RANGE SENSOR SCANS" 

ft" OPTION 1 * STATUS REPORT" 

ft" WHICH SHOWS NUM8PR F KLTNGQNS. STARDATES." 

ft" AND STARBASES lEPT*." 

ft" OPTION 2_» pHOTQM TOPPFOO DATA" 

ft" GIVES TRAJECTORY AND OTSTANCF RETWFEM THE". 

ft" FNTERPRISE AND AIL Kl'lWGONS in YOUR OUAOPANT" 

GOTO 230 

FND 

