100 ' CAN-AM*** (BASIC PROGRAM BEGINS AT LINE 610) WAS PROGRAMMED BY MARK
110 ' MANASSE, TO REPLACE THE AILING VERSION HE WROTE AS A SIXTH GRADER
120 ' AT HANOVER ELEMENTARY SCHOOL.
130 ' LAST CHANGE 12/27/72 BY DIANE MATHER, KIEWIT
140 '
150 ' DESCRIPTION — THE PROGRAM ALLOWS YOU TO RACE AROUND A HIGHLY
160 ' PERILOUS COURSE, RISKING BOTH LIFE AND MACHINE, IN AN
170 ' EFFORT TO RACE FRIENDS OR THE COMPUTER'S VERY OWN SLOW-
180 ' POKE SLIM, WILDMAN WILLY, AND HOTSHOT HARRY
190 '
200 ' INSTRUCTIONS--
210 ' YOU ARE ABOUT TO RACE. RACE ON ONE OF THE FASTEST COURSES
220 ' IN THE WORLD. A ROAD COURSE. A LONG ONE. 5.3 MILES. SPEEDS
230 ' UP TO 200 MPH. YOU CAN RACE FRIENDS(?) OR THE COMPUTER.
240 ' TO RACE THE COMPUTER, TYPE THE SEQUENCE:
250 '
250 ' /OLD CAN-AM***/RUN
270 '
280 ' TO RACE FRIENDS, TYPE:
2S0 '
300 ' /OLD CAN-AM***/LINK <KEYWORD>,N
310 '
320 ' REPLACE <KEYWORD> WITH ANY WORD OF LENGTH 1 THROUGH 8 INCLUSIVE
330 ' THAT YOU CHOOSE. REPLACE N WITH THE NUMBER OF PLAYERS COUNTING
340 ' YOURSELF. HAVE YOUR FRIENDS TYPE:
350 '
350 ' JOIN <KEYWORD>
370 '
330 ' <KEYWORD> SHOULD BE THE KEYWORD YOU USED IN THE 'LINK' COMMAND
350 ' 
400 ' WHEN THE COMPUTER TYPES A QUESTION OF THE FORM
410 '    STRAIGHT A?      OR      CURVE 1:
420 ' RESPOND BY TYPING THE SPEED (IN MPH) YOU DESIRE TO TRAVEL AT,
430 ' AND HIT THE RETURN KEY. GOOD LUCK. YOU MAY NEED IT.
440 '
450 ' IF YOU ARE USING A TERMINAL WITH BOTH UPPER AND LOWERCASE, TYPE
450 ' WORD ANSWERS (SUCK AS YES OR NO) IM CAPITAL LETTERS.
470 '
430 ' TO STOP THIS LISTING, PRESS THE 'S' OR 'ATTN' KEY.
490 '
500 ' FOR MORE INFORMATION ON MULTIPLE-TERMINAL PROGRAMMING, (AS
510 ' WHEN SEVERAL PEOPLE RACE EACH OTHER), SEE TM009 WHICH IS
520 ' AVAILABLE FROM THE KIEWIT DOCUMENT CENTER (SECRETARIAL AREA),
530 ' KIEWIT COMPUTATION CENTER, HANOVER, N. H. 03755, PHONE
540 ' (603) 645-2643.
550 '
550 ' EXPLANATION OF CHANGES--
570 '    12/27/7 2 — TO REWORD INSTRUCTIONS.
580 '
590 '* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
600
610 REM   PLEASE REFER ALL BUGS OR COMMENTS TO DIANE
620 REM   MATHER, PROGRAM LIBRARIAN, 105 KIEWIT
630
640 LET O(0)=2                          'STANDARD MOTIF HEADER 
650 LET O(1) = ASC(SOH)
660 LET O(2) = ASC(N)
670 CHANGE O TO O1$
680 LET 0(2) = ASC(Q)
690 CHANGE O TO O$
700 PRINT O1$;O$;CHR$(13);"XX ARE YOU FAMILIAR WITH THE WAY THIS GAME WORKS'";
710 DATA NON,OUI,PARLEZ-VOUS ANGLAIS ?,NEIN,JA,SPRECHEN SIE ENGLISCH?
720 DATA NOPE,YUP,COMPUTERS ARE SOPHISTICATED MACHINES. USE APPROPRIATE LANGUAGE.
730 LET K9=5                            'TWICE NUMBER OF KNOWN LANGUAGES 
740 FOR X=1 TO K9-1 STEP 2
750      READ F$(X),F$(X+1),R$((X-1)/2+1)
760 NEXT X
770 REM WE HAVE JUST LEARNED FOREIGN LANGUAGES
780 DATA WILDMAN WILLY, HOTSHOT HARRY, SLOWPOKE SAM 'NAMES OF DRIVERS WHO COMPETE AGAINST ONLY ONE PERSON. (AUTO-PILOTS)
790 MAT READ Q$(3)                      'NAME ARRAY
800 DATA -2.9,-2.9,-5                   'AMT. SPEED TO BE SUBTRACTED FROM AUTO-PILOT* SPEEDS
810 MAT READ Q(3)
820 MAT READ M$(3)                      'READ NAKES OF TYPES OF ROADWAY
830 READ X$                             'DEATH MESSAGE
840 INPUT A$                            'RESPONSE TO DO YOU KNOW WHAT YOU'RE DOING?
850 IF A$>"09" THEN 890                 'IF BETWEEN 01 AND 09, THEN MULTI-TERMINAL 
860 IF A$<"01" THEN 890
870 LET O9 = VAL(A$)
880 GOT0 960
890 LET O$=""                           'SET THINGS UP FOR SINGLE TERMINAL
900 GOSUB 2190
910 IF A$="NO" THEN 1070
920 PRINT "RATE YOURSELF AS A DRIVER.  (1-BEST,3-WORST )";
930 INPUT O
940 LET Q(3)=Q(3)*O
950 GOTO 1050
950 LET O(2) = ASC(A)                   'CREATE O$ ARRAY FOR MULTI-TERMINAL
S70 CHANGE O TO O$(10)                  'STANDARD MOTIF
930 FDR I = O TO O9
9S0      LET O(2) = ASC(C) + I
1000      CHANGE O TO O$(I)
1010 NEXT I
1020 PRINT O$(10);"YOU MAY 'DRAFT' (SLIPSTREAM) OFF-OF ANY CAR AHEAD"
1030 PRINT "OF YOU. (BUT NOT MORE THAN 1 SECOND AHEAD). TO DO THIS"
1040 PRINT "TYPE HIS CAR NUMBER+1000 AS YOUR SPEED."
1050 RANDOMIZE
1060 IF A$="YES" THEN 1110
1070 PRINT O$(0)
1080 PRINT "FOR INSTRUCTIONS, PLEASE TYPE LIST AFTER THE COMPUTER SAYS READY."
1090 PRINT
1100 IF A$="NO" THEN 2290
1110 LET F2=INT(RND*10)+6
1120 FOR A=0 TO O9 'ASSIGN NUMBERS AND ADHESION FACTORS 
1130       PRINT O$(A);"YOUR DRIVING NUM3ER IS" ;F2*(A+1)+A 'ADHESION FACTOR IS HOW WELL YOUR CAR GRIPS THE ROAD
1140       LET A(R)=RND*.05+.05
1150       PRINT O$(A);"RBHESION FACTOR"; A(A)*100-5;".  (THE LOWER THE BETTER)"
1150 NEXT A
1170 PRINT O$(10);"YOUR MAX. SPEED IS 200 MPH. TO SEE STANDINGS INPUT"
1180 PRINT "0 AS YOUR SPEED"
1190 PRINT O$(0);"WOULD YOU LIKE TO SEE THE COURSE";CHR$(63*SGN(O9));0$; 'PRINT ? IF ULT-TERM, OTHERWISE DON'T
1200 MAT INPUT A$
1210 PRINT O$(10);
1220 LET A$=A$(NUM)
1230 GOSUB 2190
1240 IF AS="NO" THEN 1450
1250 IF A$<>"YES" THEN 1190
1260 PRINTTAB(4);"--------------" 'PRINT COURSE
1270 PRINTTAB(3);"/1";TAB(11);"B";TAB(19);"2\"
1280 PRINTTAB(2);"/A";TAB(20);"C\"
1290 FRINTTAB(1);"/";TAB(22);"\"
1300 PRINT "/";TAB(21);"3I"
1310 PRINT "^-START*FINISH";TAB(22);"I"
1320 PRINT "^";TAB(22);"I"
1330 FRINT "^";TAB(21);"DI"
1340 PRINT "^";TAB{22);"I"
1350 FRINT "^";TAB(22);"I"
1360 PRINT "^H";TAB(22);"I"
1370 PRINI "^";TAB(22);"I"
1380 PRINT "^";TAB(21);"4I"
1390 PRINT "^";TAB(16);"______/"
1400 PRINT"^8";TAB(15);"T5 E"
1410 PRINT "^";TAB(16);"\"
1420 PRINT "\";TAB(17);"-------------)";CHR$(13);TAB(20);"/PITS\"
1430 FRINT " \7";TAB(14);"G";TAB(21);"F^";TAB(27);"EI"
1440 PRINT"  \_________________________/"
1450 LET N=RND*3+1 
1450 PRINT"NOTE: THIS IS A";INT(N);"LAP RACE."
1470 PRINT"GENTLEMEN, START YOUR ENGINES! THE GREEN GOES DOWN AND"
1480 FRINT"0FF YOU GO!"
1490 DATA STRAIGHT, HAIRPIN, CURVE
1500 DATA MAY I SHOW YOU TO A PLOT? WE HAVE A NICE CHOICE OF HEADSTONES.
1510 LET O=-1
1520 LET H=INT(N)
1530 FOR V=1 TO N                      'WORKING PORTION
1540       LET Y=FNA(M$(1),230,1,3/10,65) 'STRAIGHT R, 200 MAX., 3/10 MILE LONG 
1550       LET Y=FNA(M$(3),125,1,1/10,49) 'CURVE 1, 125 MAX., 1/10 MILE LONG 
1550       LET Y=FNA(M$(1),200,2,13/2Q,65) 'STRAIGHT 3, 200 MAX., 13/20 MILE LONG 
1570       LET Y=FNA(M$(3),125,1,1/10,50) 'CURVE 2, 125 MAX., 1/10 NILE LONG 
1580       LET Y=FNR(M$(1),200,1,1/5,67) 'STRAIGHT C, 200 MAX., 1/5 MILE LONG 
1590       LET Y=FNA(M$(3),150,1,3/20,51) 'CURVE 3, 150 MRX., 3/20 MILE LONG 
1600       LET Y=FNA(M$(1),200,2,3/5,68) 'STRAIGHT D, 200 MR*,, 3/5 MILE LONG 
1610       LET Y=FNA(M$(3),125,1,1/10,52) 'CURVE 4, 125 MAX., 1/10 MILE LONG 
1520       LET Y=FNA(M$(1),230,1,1/4,69) 'STRAIGHT E, 200 MRX., 1/4 MILE LONG 
1630       LET Y=FNA(M$(2),100,.75,3/20,53) 'HAIRPIN 5, 100 MPX., 3/20 MILE LONG 
1643       LET Y=FNA(M$(1),200,1.5,9/20,70) 'STRAIGHT F, 200 MRX., 9/20 MILE LONG 
1550       LET Y=FNA(M$(2),100,.75,3/20,54) 'HAIRPIN 5, 100 MRX., 3/20 MILE LONG 
1660       LET Y=FNA(M$(1),200,2,1,71) 'STRAIGHT G, 200 MRX., 1 MILE LONG 
1570       LET Y=FNA(M$(3),125,1,1/10,55) 'CURVE 7, 125 MAX., 1/10 MILE LONG 
1680       LET Y=FNA(M$(3),150,l,3/20,56) 'CURVE 8, 150 MRX., 3/20 MILE LONG 
1690       LET Y=FNA(M$(1),200,2,7/10,72) 'STRAIGHT H, 20C MRX., 7/10 MILE LONG 
1700       IF V = H THEN 1740
1710       LET Y=FNA("START-FINISH (CURVE 9)",150,1,3/20,127)
1720       REM        NAME OF TRACK          ,MAX,#,LEN ,ASC
1730       REM        START-FINISH, 150 MAX., 3/20 MILE LONG
1740 NEXT V
1750 IF G1=1 THEN 2040                  'ALL DEAD?
1760 PRINT O$(10);"DO YOU MEAN THAT EVERYONE ISN'T DEAD? WELL, HERE ARE " 'NO, SO PRINT OUT RESULTS OF RACE
1770 PRINT"THE RESULTS STRAIGHT FROM THE CHECKERED FLAG:"
1780 LET W=1E+37
1790 IF G9=0 THEN 1820
1800 LET G5=O9
1810 GOTO 1830
1820 LET G5=3
1830 FOR Z=G TO G5
1340      IF O9>0 THEN 1380
1850      IF Z=0 THEN 1880
1850      PRINT Q$(Z);
1870      GOTO 1890
1880      PRINT"GUY #";F2*(Z+1)+Z;
1890      IF D(Z) = 0 THEN 1950
1900      PRINT" IS LOOKIN' RT THEM PEARLY GATES."
1910      IF O9=0 THEN 1990
1920      PRINT O$(Z);"TELL ST. LUCIFER NOT TO EXPECT ME, O.K.?"
1930      PRINT O$(10);
1940      GOTO 1990
1950      PRINT" TOOK";T(Z);"SECONDS. WHICH AVERAGES OUT TO ";3600*5.3*H/T(Z);"MPH" 'T ARRAY IS TIME ARRAY
I960      IF T(Z)>W THEN 1990
1970      LET W=T(Z)                      'NEW LEADING TIME AND DRIVER
1980      LET N=F2*(Z+1)+Z 
1990 NEXT Z
2000 IF O9>0 THEN 2020
2010 IF N>F2 THEN 2040
2020 PRINT OS((N-F2)/(F2+1))?"NICE RACE, MR";N
2030 PRINT O$(10);"AND THAT MEANS THAT GUY #";N;"WINS!!!"
2040 PRINT O$(0);"ANOTHER RACE";CHR$(63*SGN(O9));O$;
2050 MAT INPUT A$
2060 LET A$=A$(NUM)
2070 GOSUB 2190
2080 IF A$="NO" THEN 2290
2090 IF A$<>"YES" THEN 2040
2100 FOR Z=0 TO 10                         'RESET FOR NEXT GRME 
2110      LET T(2)=D(Z)=0
2120 NEXT Z
2130 PRINT 0$(10);"NEW SET-UP. NO RAIN, NO DEBRIS";
2140 IF G1=0 THEN 2160                     'IF EVERYBODY'S DEAD, BE NASTY.
2150 PRINT ", ANT (PLEASE!) BETTER DRIVERS."
2160 PRINT
2170 LET G1=F5=0                           'UNKILL EVERYBODY AND UNCIL THE TRACK 
2180 GOTO 1110
2190 FOR X=1 TO K5                         'FOREIGN LRNGURGE HANDLER 
2200      IF R$=F$(X) THEN 2230
2210 NEXT X 
2220 GOTO 2280
2230 PRINT O$(0);R$((X-1)/2*1)
2240 IF X=INT(X/2)*2 THEN 2270
2250 LET R$="NO"
2260 GOTO 2280
2270 LET A$="YES"
2280 RETURN
2290 STOP
2300                                       ' -------- --------
2310 DEF FNA(A$,R,B,C,D)                   'KIND TRACK, MAX. SPEED, ADHESION FUDGE FACTOR, LENGTH 
2320                                       'ASC(LETTER FOLLOWING KIND OF TRACK)
2330 IF G1«1 THEN 4250                     'ALL DEAD?
2340 GOSUB 2800                            'GET SOME HAZARDS (IE RAIN, OIL)
2350 COSUB 3220                            'GET EVERYONE'S SPEED
2360 FOR G=0 TO O9                         'CHECK FOR SAFE SPEEDS
2370      IF D(G)=1 THEN 2780
2380      IF (B+A(G)+E)*S(G)/B<=R*(1+RND*.1) THEN 2500
2390      PRINT C$(G);X$                   'PRINT DEAD MESSAGE
2400      LET F5=F5+1                      'INCREMENT OIL COUNTER
2410      LET E(F5)=D                      'AND THE 635 SAID "LET THERE BE OIL." AND THERE IT WAS.
2420      FOR Z=0 TO O9                    'AND THE TRACK ABOUNDED WITH OIL. AND THE 635 SAID "BOY, WHAT
2430           IF Z=G THEN 2450            'A MAN TRAP!"
2440           PRINT O$(Z);"GUY #";F2*(G+1)+G;"JUST WIPED REAL GOOD ('N DEAD!)" 'IN THE MEANTIME, IT HAS BEEN BUSY NOTIFYING PEOPLE
2450      NEXT Z                           'OF THEIR COMRADE'S. DEMISE.
2460      LET D(G)=1                       'OFFICIALLY PRONOUNCE DEAD. D IS FOR DEATH
2470      LET Q=Q+1                        'INCREMENT DEAD COUNTER
2480      IF Q=O9 THEN 4230                'EVERYBODY DEAD?
2490      GOTO 2780
2500      LET Y4=T(G)                      'RATS. HE DIDN'T WIPE
2510 IF (B+A(G)+E)*S(G)/B<= R THEN 2530
2520 PRINT 0$(G);'"NEARLY HAD TO SAY GOOD BYE." 'ALMOST WIPED
2530      LET T(G)=T(G)+C/(S(G)/3600)+L(G) 'UPDATE HIS TIME
2540      IF O9>0 THEN 2660                'SEE IF, HEAVEN FORBID, HE PASSED SOMEBODY
2550      FOR X4=1 TO 3
2550           IF D(X4)=1 THEN 2650
2570           LET Z4=T(X4)-(C/(S(X4)/3600))
2580           LET Z1=Y4-Z4
2590           LET Z2=T(G)-T(X4)
2600           IF SGN(Z2)<>-SGN(Z1) THEN 2650
2610           IF SGN(Z2)=1 THEN 2640
2S20           PRINT "YOU JUST PASSED ";Q$(X4)
2630           GOTO 2650
2640           PRINT Q$(X4);" JUST PASSED YOU"
2550      NEXT X4
2660      FOR X4=G+1 TO G9
2570           IF D(X4)=1 THEN 2770
2580           IF S(X4)=0 THEM 2770
2690           IF SGN(Y4-T(X4))=SGN(I(G)-(T(X4)+C/(S(X4)/3600))) THEN 2770
2700           IF SGN(T(G)-(T(X4)+C/(S(X4)/3600)))<>-1 THEN 2740
2710           PRINT O$(X4);"GUY";F2*(G+1)+G;"JUST PASSED YOU."
2720           PRINT O$(G);"YOU JUST PASSED GUY";F2*-(X4+1)+X4
2730           GOTO 2770
2740           IF SGN(T(G)-(T(X4HC/(S(X4)/3600)))=0 THEN 2770
2750           PRINT O$(G);"GUY";F2*(X4+1)+X4;"JUST PASSED YOU."
2760           PRINT 0$(X4);"Y0U JUST PASSED GUY ";F2*(G+1)+G
2770      NEXT X4 
2780 NEXT G                                   'PROCEED TO THE FATE OF THE NEXT VICTIM 
2790 GOTO 4250                                'NO MORE VICTIMS. (THIS TIME!!) 
2800 REM HAZARDS 
2810 PRINT O$(10);
2320 LET E = 0                                'MAKE SURE WE DON'T USE LAST SECTION'S OIL ON THIS SECTION
2830 MAT L=ZER                                'KILL PIT STOPS FROM LAST TIME
2840 LET L(0)=0
2850 IF F5<2 THEN 2900                        'IF COURSE WELL GREASED, DISSOLVE GREASE
2850 PRINT "THE RED FLAG HAS BEEN PUT OUT. CARS REMAIN" 
2870 FRINT "MOTIONLESS UNTIL DEBRIS IS CLEARED" 
2330 MAT E=ZER
2390 LET F5=0
2900 FOR X=1 TO F5                            'SEE IF THOSE PLAYING DESERVE OIL 
2910      IF E(X)=D THEN 2940 
2920 NEXT X
2930 GOTO 2970
2940 PRINT"YIKES! OIL ON THE TRACK!"          'IF SO, NOTIFY SURVIVORS AND OTHERS
2950 LET E=.2
2960 GOTO 3130
2970 IF F3=1 THEN 3130                        'HAVE WE HAD RAIN?
2980 IF RND>.025+G8 THEN 3130                 'SEE IF IT SHOULD BE STOPPED OR STARTED 
2990 IF R(O)<.1 THEN 3080                     'IS IT RAINING?
3000 IF RND>.5 THEN 3130                      'STOP IT?
3010 PRINT "GLORY BE, THE RAIN HAS STOPPED! BUT REMEMBER IT IS STILL WET"
3020 LET F3=1                                 'RAIN, RAIN, GO AWAY, WON'T COME BACK ANOTHER DAY 
3030 FOR A=0 TO O9
3040      LET A(A)= A(A)-.075                 'DELETE MOST OF THE EFFECTS
3050      LET G8=.025                         'MAKE IT LESS LIKELY TO RAIN IN LATER RACES 
3060 NEXT A
3070 GOTO 3130
3080 PRINT "RAIN! SLOW DOWN!!"                'HALLELUJAH, MY RAIN DANCE WORKED
3090 FOR A=0 TO O9                            'MAKE TRACK SLIPPERY
3100      LET A(A)=A(A)+.1
3110      LET G8=.1
3120 NEXT A
3130 IF C<>9/20 THEN 3210                     'PIT STOPS?
3140 IF RND <.125 THEN 3210
3150 FOR X=0 TO O9
3160 IF RND*SGN(O9)<.75 THEN 3200
3170 IF D(X)=1 THEN 3200
3180 LET L(X)=RND*3+5
3190 PRINT O$(X);"Y0U ARE IN THE PITS FOR";L(X);"SECONDS."
3200 NEXT X
3210 RETURN                                   'WE WUZ HERE (AND LEFT!)
3220 REM INPUT 
3230 MAT S=ZER                                'RESET SPEED ARRAY
3240 IF O3>0 THEN 3270                        'PRINT OUT SOMETHING LIKE 'STRAIGHT A'
3250 PRINT A$;" ";CHR$(D);
3260 GOTO 3280 
3270 PRINT O$(10);A$;" ";CHR$(D);": ";O$;
3230 LET S(D)=0                               'GET EVERYBODY'S SPEEDS
3290 FOR A=0 TO O9
3300      IF D(A)=0 THEN 3330
3310      PRINT 0$(A)                         'IF HE'S DEAD, DON'T GIVE HIM A CHANCE TO INPUT 
3320      PRINT 0$; 
3330 NEXT A 
3340 MAT INPUT J                              'INPUT SOMEBODY'S SPEED
3350 IF NUM=1 THEN 3390                       'SOMEBODY TYPED SOMETHING. SET UP SPEED AND TTY#
3350 LET N=J(1)
3370 LET S=J(2)
3380 GOTO 3410
3390 LET S=J(1)
3400 LET N=0
3410 IF D(N)=0 THEN 3450                      'IS THE GUY DEAD?
3420 PRINT O$(N);"BUT I THOUGHT YOU WERE DEAD." 'RE-INFORM HIM THAT HE IS AN UN-PERSON
3430 PRINT O$;
3440 GOTO 3340
3450 IF S(N)=0 THEN 3480                      'HAS THIS GUY ALREADY TOLD US HIS SPEED?
3460 PRINT O$(N);"WAIT A SEC.  I STILL NEED";O9-U-Q;"MORE SPEEDS." 'TELL HIM TO BUZZ OFF
3470 GOTO 3430
3480 LET A=N
3490 IF S<=200 THEN 3620                      'DID HE TRY TO EXCEED HIS MAX. SPEED? 
3500 IF O9=0 THEN 3600
3510 IF S<1000 THEN 3600
3520 LET R4=(S-1000-F2)/(F2+1)                'IT'S OK. HE ONLY WANTS TO DRAFT
3530 IF R4=INT(R4) THEN 3560                  'NOW SEE IF HE PICKED A LEGAL CAR
3540 PRINT O$(N);"ILLEGAL CAR"                'HE DIDN'T
3550 GOTO 3640
3560 IF R4>O9 THEN 3540
3570 IF E(R4)>0 THEN 3540
3580 IF ABS(T{N)-T(R4)~.5)=>.5 THEN 3540
3590 GOTO 3700                                'HE DID!!!
3600 PRINT 0$(N);"MAYBE A LITTLE HARD ON THE PEDDLE? BE REALISTIC." 'OPTIMIST
3610 GOTO 3640
3620 IF S>0 THEN 3660
3630 GOSUB 3990                               'HE WANTS TO SEE HOW HE'S DOING. POOR GUY 
3640 PRINT "HOW FAST";CHR$(63*SGN(O9));O$;
3650 GOTO 3340
3660 IF S=>20 THEN 3690 'WHERE DOES HE THINK HE IS? HE LONG ISLAND EXPRESSWAY?
3670 PRINT O$(N);"I DOUBT YOU WANT TO GO THAT SLOWLY"
3680 GOTO 3640
3690 LET S(N)=S                               'SINCE HE MADE IT THIS FAR, ASSUME THAT IT'S LEGAL
3700 LET U=U+1
3710 IF R4=0 THN 3740
3720 LET H(N)=R4                              'IF HE'S DRAFTING, TELL ME TO WHOM
3730 LET R4=0
3740 IF U<O9-Q THEN 3430                      'ARE WE DONE?
3750 LET U=0                                  'YES!
3760 IF O9>0 THEN 3890                        'SET SPEEDS FOR AUTO-PILCTS
3770 FOR F0=1 TO 3
3780      IF D(F0)=1 THEN 3870
3790      LET S=R*B/(B+.l + E+G8)-»-(RND*3 + Q<F0))
3800      IF (B+.1+G8+E)*S/B<=R THEN 3850
3810      LET D(F0)=1
3820      PRINT 0$(10);Q$(F3);" JUST WIPED"       'AND INFORM US IF THEY WIPE
3830      LET F5=F5+1
3840      LET E(F5)=D
3850      LET T(F0)=T(F0)+C/(S/3600)
3860      LET S(F0)=S
3870 NEXT FO
3880 GOTO 3980
3890 FOR X2=0 TO O9
3900      IF D(X2)=1 THEN 3970
3910      IF S(X2)<>0 THEN 3970
3920      IF S(H(X2))<>0 THEN 3950
3930      LET H(X2)=H(H(X2)) 
3940      GOTO 3920
3950      LET S(X2)=S(H(X2))
3960      LET T(x2)=(T(X2)+I(H(X2)))/2
3970 NEXT X2
3980 RETURN
3990 REM PLACING
4003 PRINT O$(A)
4010 IF 09=0 THEN 4040
4020 LET G5=O9
4030 GOTO 4050
4040 LET J5=3
4050 FOR G=0 TO G5
4060      IF G=A THEN 4200
4070      IF O9>0 THEN 4100
4080      PRINT O$(G);" IS";
4090      GOTO 4110
4100      PRINT "GUY#";F2*(G+1)+G;"IS ";
4110      IF D(G)<>1 THEN 4140
4120      PRINT " OUT OF THE RACE."
4130      GOTO 4200
4140      ON SGN(T(A)-T(G))+2 GOTO 4150,4170,4190 'BUSINESS PART 
4150      PRINT T(G)-T(A);"SECONDS BEHIND YOU" 'GOOD NEWS
4160      GOTO 4200
4170      PRINT " RIGHT BESIDE YOU."           'SO SO
4180      GOTO 4200
4190      PRINT T(A)-T(G);"SECONDS AHEAD OF YOU." 'BAD NEWS
4200 NEXT G
4210 PRINT"YOU'VE TAKEN";T(A);"SECONDS."  'MORE BAD NEWS
4220 RETURN 'AND AN ANTI-CLIMACTIC ENDING. (STOLEN FROM SPIEL*** AND SPACEWAR) 
4230 PRINT O$(10);"GUY#";F2*(G+1)+G;", THE LAST OF THE GREAT RACERS, JUST WIPED."
4240 LET G1=1    'ALL HUMANS ARE DEAD, SO GRIND THIS MANGLE TO A HALT, AND SET A FLAG TO THAT EFFECT 
4250 FNEND 'AND RETURN FROM WHENCE WE CAME
4250 END 



4060 
4070 
4380 
4090 
4100 
4110 
4120 
4130 
4140 
4150 
4160 
4170 
4180 
419U 



"NOW HANILE DRAFTERS. 



•SET HIS SPEED TO .HIS DRAFTEES, AND 
'HALVE THE DISTANCE BETWEEN THEM 



•NOW GO COUNT SURVIVORS AND INCREMENT TIMES; 
'TELL ME HOW I'M DOHG 



•I AM RACING AGAI.NST AUTO-PILOTS 
»I AM RACING AGAINST FRIENDSC?) 



•IF COMPETITOR HAS MET HIS MAKER, SAy SO 



71 

