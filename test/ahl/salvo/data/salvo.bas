1000 REM *** SALVO BY LARRY SIEGEL
1010 REM *** LAST REVISION 6/9/73
1020 REM *** CHECKED OUT ON RSTS/E BY DAVE AHL, DIGITAL
1030 REM ***
1040DIMA(10,10),B(10,10),C(7),D(7),E(12),F(12),G(12),H(12),K(10,10)
1050LETZ8=0
1060FORW=1TO12
1070LETE(W)=-1
1080LETH(W)=-1
1090NEXTW
1100FORX=1TO10
1110FORY=1TO10
1120LETB(X,Y)=0
1130NEXTY
1140NEXTX
1150FORX=1TO12
1160LETF(X)=0
1170LETG(X)=0
1180NEXTX
1190FORX=1TO10
1200FORY=1TO10
1210LETA(X,Y)=0
1220NEXTY
1230NEXTX
1240FORK=4TO1STEP-1
1250LETU6=0
1260GOSUB2910
1270DEFFNA(K)=(5-K)*3-2*INT(K/4)+SGN(K-1)-1
1280DEFFNB(K)=K+INT(K/4)-SGN(K-1)
1290IFV+V2+V*V2=0THEN1260
1300IFY+V*FNB(K)>10THEN1260
1310IFY+V*FNB(K)<1THEN1260
1320IFX+V2*FNB(K)>10THEN1260
1330IFX+V2*FNB(K)<1THEN1260
1340LETU6=U6+1
1350IFU6>25THEN1190
1360FORZ=0TOFNB(K)
1370LETF(Z+FNA(K))=X+V2*2
1380LETG(Z+FNA(K))=Y+V*Z
1390NEXTZ
1400LETU8=FNA(K)
1410FORZ2=U8TOU8+FNB(K)
1420FORZ3=1TOU8-1
1430IFSQR((F(Z3)-F(Z2))^2+(G(Z3)-G(Z2))^2)<3.59THEN1260
1440NEXTZ3
1450NEXTZ2
1460FORZ=0TOFNB(K)
1470LETA(F(Z+U8),G(Z+U8))=.5+SGN(K-1)*(K-1.5)
1480NEXTZ
1490NEXTK
1500PRINT"ENTER COORDINATES FOR..."
1510PRINT"BATTLESHIP"
1520FORX=1TO5
1530INPUTY,Z
1540LETB(Y,Z)=3
1550NEXTX
1560PRINT"CRUISER"
1570FORX=1TO3
1580INPUTY,Z
1590LETB(Y,Z)=2
1600NEXTX
1610PRINT"DESTROYER<A>"
1620FORX=1TO2
1630INPUTY,Z
1640LETB(Y,Z)=1
1650NEXTX
1660PRINT"DESTROYER<B>"
1670FORX=1TO2
1680INPUTY,Z
1690LETB(Y,Z)=.5
1700NEXTX
1710PRINT"DO YOU WANT TO START";
1720INPUTJ$
1730IFJ$<>"WHERE ARE YOUR SHIPS?"THEN1890
1740PRINT"BATTLESHIP"
1750FORZ=1TO5
1760PRINTF(Z);G(Z)
1770NEXTZ
1780PRINT"CRUISER"
1790PRINTF(6);G(6)
1800PRINTF(7);G(7)
1810PRINTF(8);G(8)
1820PRINT"DESTROYER<A>"
1830PRINTF(9);G(9)
1840PRINTF(10);G(10)
1850PRINT"DESTROYER<B>"
1860PRINTF(11);G(11)
1870PRINTF(12);G(12)
1880GOTO1710
1890LETC=0
1900PRINT"DO YOU WANT TQ SEE MY SHOTS";
1910INPUTK$
1920PRINT
1930IFJ$<>"YES"THEN2620
1940REM**************START
1950IFJ$<>"YES"THEN1990
1960LETC=C+1
1970PRINT
1980PRINT"TURN"C
1990LETA=0
2000FORW=.5TO3STEP.5
2010FORX=1TO10
2020FORY=1TO10
2030IFB(X,Y)=WTHEN2070
2040NEXTY
2050NEXTX
2060GOTO2080
2070LETA=A+INT(W+.5)
2080NEXTW
2090FORW=1TO7
2100LETC(W)=0
2110LETD(W)=0
2120LETF(W)=0
2130LETG(W)=0
2140NEXTW
2150LETP3=0
2160FORX=1TO10
2170FORY=1TO10
2180IFA(X,Y)>10THEN2200
2190LETP3=P3+1
2200NEXTY
2210NEXTX
2220PRINT"YOU HAVE" A"SHOTS"
2230IFP3>=ATHEN2260
2240PRINT"THE NUMBER OF YOUR SHOTS EXCEEDS THE NUMBER OF BLANK SQUARES"
2250GOTO2890
2260IFA<>0THEN2290
2270PRINT"I HAVE WON"
2280STOP
2290FORW=1TOA
2300INPUTX,Y
2310IFX<>INT(X)THEN2370
2320IFX>10THEN2370
2330IFX<1THEN2370 
2340IFY<>INT(Y)THEN2370 
2350IFY>10THEN2370 
2360IFY>=1THEN2390
2370PRINT"ILLEGAL. ENTER AGAIN"
2380GOTO2300
2390IFA(X,Y)>10THEN2440
2400LETC(W)=X
2410LETD(W)=Y
2420NEXTW
2430GOTO2460
2440PRINT"YOU SHOT THERE BEFORE ON TURN" A(X,Y)-10
2450GOTO2300
2460FORW=1TOA
2470IFA(C(W),D(W))=3THEN2540
2480IFA(C(W),D(W))=2THEN2560
2490IFA(C(W),D(W))=1THEN2580
2500IFA(C(W),D(W))=.5THEN2600
2510LETA(C(W),D(W))=10+C
2520NEXTW
2530GOTO2620
2540PRINT"YOU HIT MY BATTLESHIP"
2550GOTO2610
2560PRINT"YOU HIT MY CRUISER"
2570GOTO2510
2580PRINT"YOU HIT MY DESTROYER<A>"
2590GOTO2510
2600PRINT"YOU HIT MY DESTROYER<B>"
2610GOTO2510
2620LETA=0
2630IFJ$="YES"THEN2670
2640LETC=C+1
2650PRINT
2660PRINT"TURN"C
2670LETA=0
2680FORW=.5TO3.1STEP.5
2690FORX=1TO10
2700FORY=1TO10
2710IFA(X,Y)=WTHEN2750
2720NEXTY
2730NEXTX
2740GOTO2760
2750LETA=A+INT(W+.5)
2760NEXTW
2770LETP3=0
2780FORX=1TO10
2790FORY=1TO10
2800IFB(X,Y)>10THEN2820 
2810LETP3=P3+1
2820NEXTY
2830NEXTX
2840PRINT"I HAVE"A"SHOTS"
2850IFP3>ATHEN2880
2860PRINT"THE NyMBER OF MY SHOTS EXCEEDS THE NUMBER QF BLANK SQUARES"
2870GOTO2270
2880IFA<>0THEN2960
2890PRINT"YOU HAVE WON"
2900STOP
2910LETX=INT((RND(-1)*10)+1) 
2920LETY=INT((RND(-1)*10)+1)
2930LETV=INT(3*RND(-1)-1)
2940LETV2=INT(3*RND(-1)-1)
2950RETURN
2960FORW=1TO12
2970IFH(W)>0THEN3800
2980NEXTW
2990REM**************RANDOM
3000LETW=0
3010LETR3=0 
3020GOSUB2910 
3030RESTORE 
3040LETR2=0
3050LETR3=R3+1
3060IFR3>100THEN3010
3070IFX>10THEN3110
3080IFX>0THEN3120
3090LETX=1+INT(RND(-1)*2.5)
3100GOTO3120
3110LETX=10-INT(RND(-1)*2.5)
3120IFY>10THEN3160
3130IFY>0THEN3270
3140LETY=1+INT(RND(-1)*2.5)
3150GOTO3270
3160LETY=10-INT(RND(-1)*2.5)
3170GOTO3270
3180LETF(W)=X
3190LETG(W)=Y
3200IFW=ATHEN3380
3210IFR2=6THEN3030
3220READX1,Y1
3230LETR2=R2+1
3240DATA1,1,-1,1,1,-3,1,1,0,2,-1,1
3250LETX=X+X1
3260LETY=Y+Y1
3270IFX>10THEN3210
3280IFX<1THEN3210
3290IFY>10THEN3210
3300IFY<1THEN3210
3310IFB(X,Y)>10THEN3210
3320FORQ9=1TOW
3330IFF(Q9)<>XTHEN3350
3340IFG(Q9)=YTHEN3210
3350NEXTQ9
3360LETW=W+1
3370GOTO3180
3380IFK$<>"YES"THEN3420
3390FORZ5=1TOA
3400PRINTF(Z5);G(Z5)
3410NEXTZ5
3420FORW=1TOA
3430IFB(F(W),G(W))=3THEN3500
3440IFB(F(W),G(W))=2THEN3520 
3450IFB(F(W),G(W))=1THEN3560 
3460IFB(F(W),G(W))=.5THEN3540 
3470LETB(F(W),G(W))=10+C
3480NEXTW
3490GOTO1950
3500PRINT"I HIT YOUR BATTLESHIP"
3510GOTO3570
3520PRINT"I HIT YOUR CRUISER"
3530GOTO3570
3540PRINT"I HIT YOUR DESTROYER<B>"
3550GOTO3570
3560PRINT"I HIT YOUR DESTROYER<A>"
3570FORQ=1TO12
3580IFE(Q)<>-1THEN3730
3590LETE(Q)=10+C
3600LETH(Q)=B(F(W),G(W))
3610LETM3=0
3620FORM2=1TO12
3630IFH(M2)<>H(Q)THEN3650 
3640M3=M3+1
3650NEXTM2
3660IFM3<>INT(H(Q)+.5)+1+INT(INT(H(Q)+.5)/3)THEN3470
3670FORM2=1TO12
3680IFH(M2)<>H(Q)THEN3710
3690LETE(M2)=-1
3700LETH(M2)=-1
3710NEXTM2
3720GOTO3470
3730NEXTQ
3740PRINT"PROGRAM ABORT:"
3750FORQ=1TO12
3760PRINT"E("Q")="E(Q)
3770PRINT"H("Q")="H(Q)
3780NEXTQ
3790STOP
3800REM**************USINGEARRAY
3810FORR=1TO10
3820FORS=1TO10
3830LETK(R,S)=0
3840NEXTS
3850NEXTR
3860FORU=1TO12
3870IFE(U)<10THEN4020
3880FORR=1TO10
3890FORS=1TO10
3900IFB(R,S)<10THEN3930
3910LETK(R,S)=-1000000
3920GOTO4000
3930FORM=SGN(1-R)TOSGN(10-R)
3940FORN=SGN(1-S)TOSGN(10-S)
3950IFN+M+N*M=0THEN3980
3960IFB(R+M,S+N)<>E(U)THEN3980
3970LETK(R,S)=K(R,S)+E(U)-2*INT(H(U)+5)
3980NEXTN
3990NEXTM
4000NEXTS
4010NEXTR
4020NEXTU
4030FORR=1TOA
4040LETF(R)=R
4050LETG(R)=R
4060NEXTR
4070FORR=1TO10
4080FORS=1TO10
4090LETW9=1
4100FORM=1TOA
4110IFK(F(M),G(M))>K(F(Q9),G(Q9))THEN4130
4120LETQ9=M
4130NEXTM
4131 IF R>ATHEN4140
4132 IF R=S THEN 4210
4140IFK(R,S)<K(F(Q9),G(Q9))THEN4210
4150FORM=1TOA
4160IFF(M)<>RTHEN4190
4170IFG(M)=STHEN4210
4180NEXTM
4190LETF(Q9)=R
4200LETG(Q9)=S
4210NEXTS
4220NEXTR
4230GOTO3380
4240END
