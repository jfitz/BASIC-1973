100 PRINT"  THIS PROGRAM WILL PLAY CHECKERS. THE COMPUTER IS X,"
200 PRINT"AND YOU ARE O. THE COMPUTER WILL GO FIRST,-NOTE: SQUARES"
300 PRINT"ARE IN THE FORM-(X,Y) AND SQ. 1,1 IS THE BOTTOM LEFT!"
400 PRINT"DO NOT ATTEMPT A DOUBLE JUMP OR YOUR PIECE MIGHT JUST "
500 PRINT"DISAPPEAR<SAME FOR A TRIPLE!)"
600 PRINT"     WAIT FOR THE COMP. TO MOVE!!!!!"
700 LET G=-1
800 DIM R(50) 
900 LET L=-1
1000 DIM S(10,10)
1100 DATA 1,0,-1,0,0,0,-1,0,0,1,0,0,0,-1,0,-1,15
1200 FOR X=1TO8
1300 FOR Y=1TO8
1400 READ J
1500 IF J=15 THEN 1800
1600 LET S(X,Y)=J
1700 GOTO 2000
1800 RESTORE
1900 READ S(X,Y)
2000 NEXT Y
2100 NEXT X
2200 REM
2300LETL=-1*L
2400 FOR X=1TO8
2500 FOR Y=1TO8
2600 IF S(X,Y)=0 THEN 3500
2700 IF G>0 THEN 3000
2800 IF S(X,Y)>0 THEN 3500
2900 GOTO 3100
3000 IF S(X,Y)<0 THEN 3500
3100 IF ABS(S(X,Y))<>1 THEN 3300
3200 GOSUB 4300
3300 IF ABS(S(X,Y))<>2 THEN 3500
3400 GOSUB 6500
3500IFX<>8 THEN 3800
3600IFL=1 THEN 3800
3700RETURN
3800NEXT Y
3900NEXT X
4000PRINT
4100GOSUB11400
4200 GOTO 2300
4300 FOR A=-1TO1 STEP 2
4400 LET U=X+A
4500 LET V=Y+G
4600 IF U<1 THEN 6300
4700 IF U>8 THEN 6300
4800 IF V<1 THEN 6300
4900 IF V>8 THEN 6300
5000 IF S(U,V)<>0 THEN 5300
5100 GOSUB 9100
5200 GOTO 6300
5300 IF S(U,V)=G THEN 6300
5400 IF S(U,V)=2*G THEN 6300
5500 LET U=U+A
5600 LET V=V+G
5700 IF U<1 THEN 6300
5800 IF U>8 THEN 6300
5900 IF V<1 THEN 6300
6000 IF V>8 THEN 6300
6100 IF S(U,V)<>0 THEN 6300
6200 GOSUB 9100
6300 NEXT A
6400 RETURN
6500 REM KING MOVES
6600 FOR A=-1TO1 STEP 2
6700 FOR B=-1TO1 STEP 2
6800 LET U=X+A
6900 LET V=Y+B
7000 IF U<1 THEN 8700
7100 IF U>8 THEN 8700
7200 IF V<1 THEN 8700
7300 IF V>8 THEN8700
7400 IF S(U,V)<>0 THEN 7700
7500 GOSUB 9100
7600 GOTO 8700
7700 IF S(U,V)=G THEN 8700
7800 IF S(U,V)=2*G THEN 8700
7900 LET U=U+A
8000 LET V=V+B
8100 IF U<1 THEN 8700
8200 IF U>8 THEN 8700
8300 IF V<1 THEN 8700
8400 IF V>8 THEN 8700
8500 IF S(U,V)<>0 THEN 8700
8600 GOSUB 9100
8700 NEXT B
8800 NEXT A
8900 RETURN
9000 GOTO 14200
9100 REM
9200 LET P=P+1
9300 IF P=K THEN 12300
9400IF V<>(4.5+(3.5*G)) THEN 9600
9500 LET Q=Q+2
9600 IF X<>(4.5-(3.5*G)) THEN 9800
9700LET Q=Q-2
9800 REM
9900 IF U<>1 THEN 10100
10000 LET Q=Q+1
10100 IF U<>8 THEN 10300
10200 LET Q=Q+1
10300 FOR C=-1TO1 STEP 2
10400 IF S(U+C,V+G)<1 THEN10800
10500 LET Q=Q-1
10600 IF S(U-C,V-G)<>0 THEN 10800
10700 LET Q=Q-1
10800 REM THIS WAS THE EVALUATION SECTION
10900 REM
11000 NEXT C
11100 LET R(P)=Q
11200 LETQ=0
11300 RETURN
11400 IF P=0 THEN 18800
11500 FOR J=10TO-10 STEP -1
11600 FOR F=1TOP
11700 IF R(F)=J THEN 12000
11800 NEXT F
11900 NEXT J
12000 LET K=F+P
12100 GOSUB 2300
12200 RETURN
12300 PRINT" I MOVE FROM ("X;Y") TO ("U;V")"
12400 LET F=0
12500 LET P=0
12600 LET K=0
12700 IF V<>(4.5+(3.5*G)) THEN 13000
12800 LET S(U,V)=2*G
12900 GOTO 13100
13000 LET S(U,V)=S(X,Y)
13100 LET S(X,Y)=0
13200 IF ABS(X-U)<>2 THEN 13400
13300 LET S((X+U)/2,(Y+V)/2)=0
13400 PRINT"BOARD";
13500 INPUT D$
13600 IF D$<>"YES" THEN13900
13700 GOSUB 14100
13800 RETURN
13900 GOSUB 15800
14000 RETURN
14100 PRINT
14200 FOR Y=8TO1 STEP -1
14300 FOR X=1TO8
14400 LET I=2*X
14500 IF S(X,Y)<>0 THEN 14700
14600 PRINT TAB(I)".";
14700 IF S(X,Y)<>1 THEN 14900
14800 PRINT TAB(I)"O";
14900 IF S(X,Y)<>-1 THEN 15100
15000 PRINT TAB(I)"X";
15100 IF S(X,Y)<>-2 THEN 15300
15200 PRINT TAB(I)"X";TAB(I)"*";
15300 IF S(X,Y)<>2 THEN 15500
15400 PRINT TAB(I)"O";TAB(I)"*";
15500 NEXT X
15600 PRINT
15700 NEXT Y
15800 PRINT
15900 PRINT" FROM";
16000 INPUT E,H
16100 LET X=E
16200 LET Y=H
16300 IF S(X,Y)<>0 THEN 16700
16400 PRINT "THERE IS NO ONE OCCUPING THAT SPACE"
16500 PRINT
16600 GOTO 15900
16700 PRINT"TO";
16800 INPUT A,B
16900 LET X=A
17000 LET Y=B
17100 IF S(X,Y)<>0 THEN 17500
17200 PRINT"THAT SPACE IS ALREADY OCCUPIED"
17300 PRINT
17400 GOTO 16700
17500 LET S(A$B)=S(E,H)
17600 LET S(A,B)=S(E,H)
17700 LET S(E,H)=0
17800 LET T=(4.5-(3.5*G))
17900 IF ABS(E-A)<>2 THEN 18100
18000 LET S((E+A)/2,(H+B)/2)=0
18100 IF B<>T THEN 18300
18200 LET S(A,B)=-2*G
18300 FOR X=8TO8 
18400 FOR Y=8TO8
18500 RETURN
18600 NEXT Y
18700 NEXT X
18800 PRINT"    VERY GOOD, YOU WIN!"
18900 PRINT
19000 PRINT
19100 PRINT"                       -CHUCK OUT"
19200 END

