10 REM -- BATTLE WRITTEN BY RAY WESTERGARD 10/70
20 REM COPYRIGHT 1971 BY THE REGENTS OF THE UNIV. OF CALIF,
30 REM PRODUCED AT THE LAWRENCE HALL OF SCIENCE, BERKELEY
40 DIM F[6,6],H[6,6],A[4],B[4],C[6],L[3]
50 MAT F=ZER
60 FOR I=1 TO 3
70 N=4-I
80 FOR J=1 TO 2
90 A=INT(6*RND(0))+1
100 B=INT(6*RND(0))+1
110 D=INT(4*RND(0))+1
120 IF F[A,B]>0 THEN 90
130 M=0
140 GOTO D OF 150,340,550,740
150 B[1]=B
160 B[2]=B[3]*7
170 FOR K=1 TO N
180 IF M>1 THEN 240
190 IF B[K]=6 THEN 230
200 IF F[A,B[K]+1]>0 THEN 230
210 B[K+1]=B[K]+1
220 GOTO 280
230 M=2
240 Z=((B[1] MIN _ B[2]) MIN _ B[3])
250 IF Z<1 THEN 90
260 IF F[A,Z-1]>0 THEN 90
270 B[K+1]=Z-1
280 NEXT K
290 F[A,B]=9-2*I-J
300 FOR K=1 TO N
310 F[A,B[K+1]]=F[A,B]
320 NEXT K
330 GOTO 990
340 A[1]=A
350 B[1]=B
360 A[2],A[3],B[2],B[3]=0
370 FOR K=1 TO N
380 IF M>1 THEN 460
390 IF A[K]=1 OR B[K]=1 THEN 450
400 IF F[A[K]-1,B[K]-1]>0 THEN 450
410 IF F[A[K]-1,B[K]]>0 AND F[A[K]-1,B[K]]=F[A[K],B[K]-1] THEN 450
420 A[K+1]=A[K]-1
430 B[K+1]=B[K]-1
440 GOTO 530
450 M=2
460 Z1=((A[1] MAX _ A[2]) MAX _ A[3])
470 Z2=((B[1] MAX _ B[2]) MAX _ B[3])
480 IF Z1=6 OR Z2=6 THEN 90
490 IF F[Z1+1,Z2+1]>0 THEN 90
500 IF F[Z1,Z2+1]>0 AND F[Z1,Z2+1]=F[Z1+1,Z2] THEN 90
510 A[K+1]=Z1+1
520 B[K+1]=Z2+1
530 NEXT K
540 GOTO 950
550 A[1]=A
560 A[2],A[3]=7
570 FOR K=1 TO N
580 IF M>1 THEN 640
590 IF A[K]=6 THEN 630
600 IF F[A[K]+1,B]>0 THEN 630
610 A[K+1]=A[K]+1
620 GOTO 680
630 M=2
640 Z=((A[1] MIN _ A[2]) MIN _ A[3])
650 IF Z=1 THEN 90
660 IF F[Z-1,B]>0 THEN 90
670 A[K+1]=Z-1
680 NEXT K
690 F[A,B]=9-2*I-J
700 FOR K=1 TO N
710 F[A[K+1],B]=F[A,B]
720 NEXT K
730 GOTO 990
740 A[1]=A
750 B[1]=B
760 A[2],A[3]=7
770 B[2],B[3]=0
780 FOR K=1 TO N
790 IF M>1 THEN 870
800 IF A[K]=6 OR B[K]=1 THEN 860
810 IF F[A[K]+1,B[K]-1]>0 THEN 860
820 IF F[A[K]+1,B[K]]>0 AND F[A[K]+1,B[K]]=F[A[K],B[K]-1] THEN 860
830 A[K+1]=A[K]+1
840 B[K+1]=B[K]-1
850 GOTO 940
860 M=2
870 Z1=((A[1] MIN _ A[2]) MIN _ A[3])
880 Z2=((B[1] MAX _ B[2]) MAX _ B[3])
890 IF Z1=1 OR Z2=6 THEN 90
900 IF F[Z1-1,Z2+1]>0 THEN 90
910 IF F[Z1,Z2+1]>0 AND F[Z1,Z2+1]=F[Z1-1,Z2] THEN 90
920 A[K+1]=Z1-1
930 B[K+1]=Z2+1
940 NEXT K
950 F[A,B]=9-2*I-J
960 FOR K=1 TO N
970 F[A[K+1],B[K+1]]=F[A,B]
980 NEXT K
990 NEXT J
1000 NEXT I
1010 PRINT
1020 PRINT "THE FOLLOWING CODE OF THE BAD GUYS' FLEET DISPOSITION"
1030 PRINT "HAS BEEN CAPTURED BUT NOT DE-CODED."
1040 PRINT
1050 MAT H=TRN(F)
1060 MAT PRINT H
1070 PRINT
1080 PRINT "DE-CODE IT AND USE IT IF YOU CAN" 
1090 PRINT "BUT KEEP THE DE-CODING METHOD A SECRET."
1100 PRINT 
1110 MAT H=ZER
1120 MAT L=ZER
1130 C[1],C[2]=2
1140 C[3],C[4]=1 
1150 C[5],C[6]=0
1160 S,H=0
1170 PRINT "START GAME"
1180 INPUT X,Y
1190 IF X<1 OR X>6 OR INT(X)#ABS(X) THEN 1210
1200 IF Y>0 AND Y<7 AND INT(Y)=ABS(Y) THEN 1230
1210 PRINT "INVALID INPUT, TRY AGAIN."
1220 GOTO 1180
1230 R=7-Y
1240 C=X
1250 IF F[R,C]>0 THEN 1290
1260 S=S+1
1270 PRINT "SPLASH! TRY AGAIN."
1280 GOTO 1180
1290 IF C[F[R,C]]<4 THEN 1340
1300 PRINT "THERE USED TO BE A SHIP AT THAT POINT, BUT YOU SUNK IT."
1310 PRINT "SPLASH! TRY AGAIN."
1320 S=S+1
1330 GOTO 1180
1340 IF H[R,C]>0 THEN 1420
1350 H=H+1
1360 H[R,C]=F[R,C]
1370 PRINT "A DIRECT HIT ON SHIP NUMBER"; F[R,C]
1380 C[F[R,C]]=C[F[R,C]]+1
1390 IF C[F[R,C]]>=4 THEN 1470
1400 PRINT "TRY AGAIN."
1410 GOTO 1180
1420 PRINT "YOU HAVE ALREADY PUT A HOLE IN SHIP NUMBER";F[R,C];
1430 PRINT "AT THAT POINT."
1440 PRINT "SPLASH! TRY AGAIN."
1450 S=S+1
1460 GOTO 1180
1470 L[INT((F[R,C]-1)/2)+1]=L[INT((F[R,C]-1)/2)+1]+1
1480 PRINT "AND YOU SUNK IT, HURRAH FOR THE GOOD GUYS."
1490 PRINT "SO FAR THE BAD GUYS HAVE LOST"
1500 PRINT L[1];"DESTROYER(S), "; L[2];"CRUISER (S) , AND ";
1510 PRINT L[3];"AIRCRAFT CARRIER(S)."
1520 PRINT "YOUR CURRENT SPLASH/HIT RATIO IS";S/H
1530 IF (L[1]+L[2]+L[3])<6 THEN 1180
1540 PRINT
1550 PRINT "YOU HAVE TOTALLY WIPED OUT THE BAD GUYS' FLEET"
1560 PRINT "WITH A FINAL SPLASH/HIT RATIO OF";S/H
1570 IF S/H>0 THEN 1590
1580 PRINT "CONGRATULATIONS — A DIRECT HIT EVERY TIME."
1590 PRINT
1600 PRINT "*******************"
1610 PRINT
1620 GOTO 50 
1630 END
