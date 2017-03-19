7 REM LUNAR1 IS A INTERACTIVE GAME THAT SIMULATES A LUNAR , 

8 REM LANDING SIMILAR TO THAT OF THE APOLLO PROGRAM. 

9 REM THERE IS ABSOLUTELY NO CHANCE INVOLVED. 
10 LET ZS="GO" 

15 LET 31=1 

20 LET M= 17.9.5 

25 LET Fl=5.25 

30 LET N=7.5 

35 LET R0 = 926 

40 LET V0=1.29 

45 LET T = 

50 LET H0 = 60 

55 LET R=R0+H0 

60 LET A=-3.425 

65 LET R1=0 

70 LET Al=8.8436JE-04 

75 LET R3=0 

80 LET A3=0 

85 LET M 1 = 7.45 

90 LET M0=M1 

95 LET 3=750 
100 LET T1=0 
105 LET F-0 ' 
110 LET P=0 
115 LET N=l 
120 LET M2 = 
125 LET S=0 
130 LET C=0 

135 IF Z$="YES" THEN 1150 
140 PRINT 

145 PRINT "LUNAR LANDING SIMULATION" 
150 PRINT 

155 PRINT "HAVE YOU FLOWN ON AN APOLLO/LEM MISSION BEFORE#"; 
160 PRINT "(YES OR NO)"; 
165 INPUT 0$ 

170 IF Q$="YES" THEN 190 
175 IF Q$="NO" THEN 205 

180 PRINT "JUST ANSWER THE QUESTION, PLEASE"; 
185 GOTO 160 
190 PRINT 

195 PRINT "ENTER MEASUREMENT OPTION NUMBER"; 
200. GOTO 225 
205 PRINT 

210 PRINT "WHICH SYSTEM OF MEASUREMENT DO YOU PREFER ?" 
215 PRINT " 1= METRIC 0= ENGLISH" 

220 PRINT "ENTER THE APPROPRIATE NUMBER"; 
225 INPUT K 
230 PRINT 

235 IF K=0 THEN 280 
240 IF K=l THEN 250 
245 GOTO 220 
250 LET Z=1852.8 
255 LET M$="METERS" 
260 LET G3=3.6 
265 LET N$=" KILOMETERS" 
270 LET G5=1300 
275 GOTO 305 
280 LET Z=6080 
285 LET M$="FEET" 
290 LET G3=,592 
295 LET N$=" N. MILES" 
300 LET G5=Z 
305 IF Bl=3 THEN 670 
31? IF QS = "YES" THEN 485 
315 PRINT 

3216 PRINT " YOU ARE ON A LUNAR LANDING MISSION. AS THE PILOT OF" 
325 PRINT "THE LUNAR EXCURSION MODULE, YOU WILL BE EXPECTED TO" 
332 PRINT "GIVE CERTAIN COMMANDS TO THE MODULE NAVIGATION SYSTEM." 

335 PRINT " THE ON BOARD COMPUTER WILL GIVE A RUNNING ACCOUNT" 
340 PRINT "OF INFORMATION NEEDED TO NAVIGATE THE SHIP." 
345 PRINT 
35 PRINT 

355 PRINT "THE ATTITUDE ANGLE CALLED FOR IS DESCRIBED AS FOLLOWS-" 
360 PRINT "+ OR -180 DEGREES IS DIRECTLY AWAY FROM THE MOON" 
365 PRINT "-90 DEGREES IS ON A TANGENT IN THE DIRECTION OF ORBIT" 
370 PRINT "90 DEGREES IS CN A TANGENT FROM THE DIRECTION OF ORBIT" 
375 PRINT "0 (ZERO) DEGREES IS DIRECTLY TOWARD THE MOON" 
380 PRINT 

385 PRINT TA3(30);"-180,180" 
390 PRINT TA3(34):"t" 
395 PRINT TA3(27);"-90 &lt; -+- &gt; 90" 
400 PRINT TAB (34);"!" 
4 35 PRINT TAB(34);"0" 

410 PRINT TA3(23);"« DIRECTION OF ORBIT «" 
415 PRINT 

420 PRINT TAB (27); "SURFACE OF MOON" 
425 PRINT 
430 PRINT 
435 PRINT "ALL ANGLES BETWEEN -180 AND 18 

440 PRINT 

445 PRINT "1 FUEL UNIT = 1 SEC. AT MAX. THRUST" 

450 PRINT "ANY DISCREPANCIES ARE ACCOUNTED FOR IN THE USE OF FUEL" 
4^5 PRINT "FOR AN ATTITUDE CHANGE." 
460 PRINT "AVAILABLE ENGINE POWER: (ZERO) AND ANY VALUE BETWEEN" 

465 PRINT "10 AND 100 PERCENT" 

4 70 PRINT 

475 PRINT "NEGATIVE THRUST OR TIME IS PROHIBITED" 

480 PRINT 

485 PRINT 

490 PRINT "INPUT 

495 PRINT " 

5 00 PRINT " 
505 PRINT 

5 10 IF Q$="YES" THEN 535. 
5 15 PRINT "FOR EXAMPLE:" 
520 PRINT "T,P, A? 10,65,-60" 

525 PRINT "TO ABORT THE MISSION AT ANY TIME, ENTER 0,0,0" 
530 PRINT 

"OUTPUT: TOTAL TIME ELAPSED IN SECONDS" 
HEIGHT IN ";M$ 

DISTANCE FROM LANDING SITE IN ";M$ 
VERTICAL VELOCITY IN ";MS; "/SECOND" 
HORIZONTAL VELOCITY IN ";M$; "/SECOND" 
FUEL UNITS REMAINING" 



DEGREES ARE ACCEPTED. 



TIME INTERVAL IN SECONDS (T)" 

PERCENTAGE OF THRUST (P)" 

ATTITUDE ANGLE IN DEGREES (A)" 



535 PRINT 

5 40 PRINT " 

5 45 PRINT " 

550 PRINT " 

555 PRINT " 

5 60 PRINT " 

5 65 PRINT 

570 GOTO 670 

5 75 PRINT 

5 80 PRINT "T,P, A"; 

585 INPUT T1,F,P 

5 90 LET F=F/100 

595 IF T1&lt;0 THEN 905 

600 IF Ti = THEN 1090 



605 IF ABS(F-.05)&gt;1 THEN 945 

610 IF A3S(F-.05)&lt;.05 THEN 945 

615 IF ABS(P)&gt;180 THEN 925 

620 LET N=20 *;■ 

625 IF Tl&lt;400 THEN 635 

630 LET N=Tl/20 

635 LET T1=T1/N 

640 LET P=P*3. 14159/180 

645 LET S=SIN(P) 

650 LET C=COS(P) 

655 LET M2=M0*T1*F/B 

660 LET R3=-.5*R0*((V0/R)T2)+R*A1*A1 

665 LET A3=-2*R1*A1/R 

670 FOR 1=1 TO N.. '■•■'.■■ . 

675 IF Mi=0 THEN 715 

680 LET MT-M1-M2 

685 IF M1&gt;0 THEN 725 

690 LET F=F*(1+M1/M2) 

695 LET M2=M1+M2 

700 PRINT "YOU ARE OUT OF FUEL" 

705 LET M1=0 

710 GOTO 725 

7 15 LET F = 

720 LET M2 = 

725 LET M=M-.5*M2 

730 LET R4=R3 

735 LET R3=-.5*R0*((V0/R)?2)+R*A1*A1 

740 LET R2=(3*R3-R4)/2+.0(?526*Fl*F*C/M 

745 LET A4 = A3 

750 LET A3=-2*R1*A1/R 

755 LET A2=(3*A3-A/&lt;)/2+.30526*Fl*F*S/(M*R) 

760 LET X=R1*T1+.5*R2*T1*T1 

765 LET R=R+X 

770 LET H0=H0+X 

775 LET R1=R1+R2*T1 

780 LET A= UAT*T1 + .5*A2*T1*T1 

785 LET A1=A1+A2*T1 

790 LET M=M-.5*M2 

795 LET T=T+TT 

800 IF H0&lt;3. 28782SE-04 THEN 813 

825 NEXT I 

810 LET H=H0*Z 

815 LET H1=R1*Z 

820 LET D=R0*A*Z 

825 LET D1 = R*A1*Z 

830 LET T2=M1*B/M.0 

835 PRINT TAB(1);T;TAB(10);H;TAB(23);D; 

843 PRINT TAB(37);H1;TAB(49);D1;TA3(60);T2 

845 IF H0&lt;3.28782SE-24 THEN 883 

S5E IF R0*A&gt;164.4736 THEN 1050 

855 IF M1&gt;0 THEN 580 

860 LET Tl = 20 

LET F=0 

LET P=0 

GOTO 623 

I.F Rl&lt;-8.2l957E-04 THEN 1020 

IF ABS(R*Al)&gt;4.931742E-04 THEN 1020 

IF H0&lt;-3. 287828E-34 THEN 1020 

IF ABS(D)&gt;10*Z THEN 1065 

GOTO 995 

PRINT 

PRINT "THIS SPACECRAFT IS NOT ABLE TO VIOLATE THE SPACE-"; 

PRINT "TIME CONTINUUM" 

GOTO 5 75 

PRINT 

PRINT "IF YOU WANT TO SPIN AROUND, GO OUTSIDE THE MODULE"; 

PRINT "FOR AN E.V.A" 

GOTO 575 

PRINT 

PRINT "IMPOSSIBLE THRUST- VALUE "; 

IF F&lt;0 THEN 985 

IF F-.05&lt;.05 THEN 975 

PRINT "TOO LARGE" 

GOTO 5 75 

PRINT "TOO SMALL" 

GOTO 575 - 

PRINT "NEGATIVE" 

GOTO 575 

PRINT 

PRINT "TRANQUILITY BASE HERE -- THE EAGLE HAS LANDED" 

PRINT "CONGRATULATIONS - THERE WAS NO SPACECRAFT DAMAGE" 

PRINT "YOU MAY NOW PROCEED WITH SURFACE EXPLORATION." 

GOTO 1100 

PRINT 

PRINT "CRASH !!! ! ! ! ! ! ! !" 

PRINT "YOUR IMPACT CREATED A CRATER" ;ABS (H) ;M$; " DEEP" 

X1=SQR(D1*D1+H1*H1)*G3 

PRINT "AT CONTACT YOU WERE TRAVELLI NG"; XI ;N$; "/HR ." 

GOTO 1100 

PRINT 

PRINT "YOU HAVE BEEN LOST IN SPACE WITH NO HOPE OF RECOVERY" 

GOTO 1100 

PRINT "YOU ARE DOWN SAFELY - " 

PRINT 

PRINT "BUT MISSED THE LANDING SITE BY"; ABS(D/G5 ); N$ 

GOTO 1100 

PRINT 

PRINT "MISSION ABORTED" 

PRINT 

PRINT "DO YOU WANT TO FLY IT AGAIN ? (YES OR NO)"; 

INPUT ZS 

IF Z$="YES" THEN 23 

IF Z$="NO" THEN 1130 

GOTO 1105 

PR I NT 

TOO BAD, THE SPACE PROGRAM HATES TO LOSE EXPERIENCED"; 
ASTRONAUTS." 



186 



870 
875 
880 
885 
890 
895 
900 
935 
910 
915 
920 
925 
930 
935 
940 
945 
950 
955 
960 
965 
970 
975 
980 
985 
993 
995 
1030 
1005 
1010 
1015 
1020 
1025 
1032 
1035 
1040 
1045 
1050 
1055 
1063 
1065 
1075 
1080 
1385 
1090 
1095 
1100 
1105 
1110 
1115 
1120 
1 1 25 
1130 
1135 
1140 
1145 
1150 
1155 
1 1 60 
1165 
1170 
1175 
1180 
1185 
1190 
1195 
1200 
1205 
1213 
1215 



PRINT 

PRINT 

STOP 

PRINT 

PRINT "OK, DO YOU WANT THE COMPLETE INSTRUCTIONS OR THE INPUT- 
PRINT "OUTPUT STATEMENTS ?" 
PRINT' "1 = COMPLETE INSTRUCTIONS" 
PRINT "2=INPUT-0UTPUT STATEMENTS" 
PRINT "3= NEITHER" 
INPUT Bl 
LET QS="NO" 
IF 81=1 THEN 205 
LET Q$="YES" 
IF 31=2 THEN 190 
IF Bl=3 THEN 190 
GOTO 1165 
END 
