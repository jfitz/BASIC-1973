0 REM "  QUBIC-  "
5 PRINT "DO YOU WANT INSTRUCTIONS";
6 INPUT C$
7 IF C$="NO" THEN 20
8 IF C$="YES" THEN 13
9 PRINT "INCORRECT ANSWER. PLEASE TYPE 'YES' OR 'NO'";
10 GOTO 6
13 PRINT "THE GAME IS TIC-TAC-TOE IN A 4 X 4 X 4 CUBE."
14 PRINT "EACH MOVE IS INDICATED BY A 3 DIGIT NUMBER, WITH EACH"
15 PRINT "DIGIT BETWEEN 1 AND 4 INCLUSIVE. THE DIGITS INDICATE THE"
16 PRINT "LEVEL, COLUMN, AND ROW, RESPECTIVELY, OF THE OCCUPIED PLACE,"
20 DIM X(64),L(76),M(76,4),Y(16)
21 FOR I=1 TO 16
22 READ Y(I)
23 NEXT I
24FOR I=1 TO 76
25FOR J = 1 TO 4
26 READM(I,J)
27 NEXT J 
28 NEXT I
35 FOR I = 1 TO 64
40 LET X (I) =0
50 NEXT I
54 LET Z=1
55 PRINT "DO YOU WANT TO MOVE FIRST";
60 INPUT S$
66 IF S$="NO" THEN 110
67 IF S$="YES" THEN 70
68 PRINT "INCORRECT ANSWER. PLEASE TYPE 'YES' OR 'NO'";
69 GOTO 60
70 PRINT " "
72 PRINT "YOUR MOVE";
80INPUTJ1
85 GOSUB 1800
90 LETK1=INT(J1/100)
95 LET J2=(J1-K1*100)
96 LET K2=INT(J2/10)
97 LET K3= J1 - K1*100 -K2*10
98 LET M=16*K1+4*K2+K3-20
99 IF X(M)=0 THEN 109
100 PRINT "THAT SQUARE IS USED, TRY AGAIN"
101 GOTO 70
109 LET X(M)=1
110 GOSUB 1050
180 FOR J=1 TO 3
190 FOR I=1 TO 76
200 IF J=1 THEN 210
201 IF J=2 THEN 220
203 IF J=3 THEN 235
205 NEXT I
206 NEXTJ
207 GOTO 400
210 IF L(I)<>4 THEN 205
211 PRINT "YOU WIN AS FOLLOWS";
212 FOR J=1 TO 4
213 LET M=M(I,J)
214 GOSUB 1000
216 NEXT J
217 GOTO 500
220 IF L(I)<>15 THEN 205
221 FOR J=1 TO 4
222 LET M=M(I,J)
223 IF X(M)<>0 THEN 227
224 LET X(M)=5
225 PRINT "MACHINE MOVES TO";
226 GOSUB 1000
227 NEXT J
228 PRINT ", AND WINS AS FOLLOWS"
229 FOR J=1 TO 4
230 LET M=M(I,J)
231 GOSUB 1000
233 NEXT J
234 GOTO 500
235 IF L(I)<>3 THEN 205
236 PRINT "NICE TRY MACHINE MOVES TO";
237 FOR J=1 TO 4
238 LET M=M(I,J)
239 IF X(M)<>0 THEN 245
240 LET X(M)=5
241 GOSUB 1000
243 GOTO 70
245 NEXT J
248 GOTO 400
250 FOR I = 1 TO 76
251 LET L(I)=X(M(I,1))+X(M(I,2))+X(M(I,3))+X(M(I,4))
252 LET L = L(I)
255 IF L <2 THEN 290
260 IF L>=3 THEN 290
265 IF L>2 THEN 1600
270 FOR J = 1 TO 4
275 IF X(M(I,J))<>0 THEN 285
280 LET X(M(I,J))=1/8
285 NEXT J
290 NEXT I
295 GOSUB 1050
300 FOR I = 1 TO 76
305 IF L(I)=1/2 THEN 1700
310 IF L(I)=1 + 3/8 THEN 1700
315 NEXT I
320 GOTO 1300
360LET Z = 1
362 IF X(Y(Z))=0 THEN 380
365 LET Z=Z+1
368 IF Z<>17 THEN 362
375 GOTO 1200
380 LET M=Y(Z)
381 LET X(M)=5
385 PRINT "MACHINE MOVES TO";
389 GOSUB 1000
390 GOTO 70
400 LET X=X
410 FOR I=1 TO 76
412 LET L(I)=X(M(I,1))+X(M(I,2))+X(M(I,3))+X(M(I,4))
415 LET L=L(I)
420 IF L<10 THEN 455
425 IF L>=11 THEN 455
430 IF L>10 THEN 1600
435 FOR J=1 TO 4
440 IF X(M(I,J))<>0 THEN 450
445 LET X(M(I,J))=1/8
450 NEXT J
455 NEXT I
470 GOSUB 1050
475 FOR I=1 TO 76
480 IF L(I)=.5 THEN 1700
485 IF L(I)=5+3/8 THEN 1700
490 NEXT I
492 GOSUB 1800
493 GOTO 250
500 PRINT " "
505 PRINT "DO YOU WANT TO TRY ANOTHER GAME";
510 INPUT X$
515 IF X$="YES" THEN 35
516 IF X$="NO" THEN 520
517 PRINT "INCORRECT ANSWER. PLEASE TYPE 'YES' OR 'NO'";
518 GOTO 510
520 STOP
1000 LET K1=INT((M-1)/16)+1
1010 LET J2=M-16*(K1-1)
1030 LET K2=INT((J2-1)/4)+1
1035 LET K3=M-(K1-1)*16-(K2-1)*4
1040 LET M=K1*100+K2*10+K3
1042 PRINT M;
1045 RETURN
1050 FOR S=1 TO 76
1060 LET J1 = M(S,1)
1070 LET J2=M(S,2)
1080 LET J3=M(S,3)
1090 LET J4=M(S,4)
1100 LET L(S)=X(J1)+X(J2)+X(J3)+X(J4)
1110 NEXT S
1120 RETURN
1200 FOR I=1 TO 64
1210 IF X(I)<>0 THEN 1250
1220 LET X(I)=5
1225 LET M=I
1226 PRINT "MACHINE LIKES";
1227 GOSUB 1000
1228 PRINT " "
1230 GOTO 70
1250 NEXT I
1252 PRINT "THE GAME IS A DRAW"
1255 GOTO 500
1300 FOR K=1 TO 18
1305 LET P=0
1310 FOR I=4*K-3 TO 4*K
1315 FOR J=1 TO 4
1320 LET P=P+X(M(I,J))
1325 NEXT J
1330 NEXT I
1345 IF P<4 THEN 1390
1350 IF P<5 THEN 1400
1355 IF P<9 THEN 1390
1360 IF P<10 THEN 1400
1390 NEXT K
1395 GOSUB 1800
1396 GOTO 360
1400 LET S=1/8
1405 FOR I=4*K-3 TO 4*K
1410 GOTO 1703
1415 NEXT I
1420 LET S=0
1425 GOTO 1405
1500 DATA 1,49,52,4,13,61,64,16,22,39,23,38,26,42,27,43
1510DATA 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
1520 DATA 21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38
1521 DATA 39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56
1522 DATA 57,58,59,60,61,62,63,64
1523DATA1,17,33,49,5,21,37,53,9,25,41,57,13,29,45,61
1524 DATA 2,18,34,50,6,22,38,54,10,26,42,58,14,30,46,62
1525DATA 3,19,35,51,7,23,39,55,11,27,43,59,15,31,47,63
1527 DATA 4,20,36,52,8,24,40,56,12,28,44,60,16,32,48,64
1529 DATA 1,5,9,13,17,21,25,29,33,37,41,45,49,53,57,61
1532 DATA 2,6,10,14,18,22,26,30,34,38,42,46,50,54,58,62
1534 DATA 3,7,11,15,19,23,27,31,35,39,43,47,51,55,59,63
1536 DATA4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64
1538 DATA1,6,11,16,17,22,27,32,33,38,43,48,49,54,59,64
1540 DATA 13,10,7,4,29,26,23,20,45,42,39,36,61,58,55,52
1542 DATA1,21,41,61,2,22,42,62,3,23,43,63,4,24,44,64
1544DATA 49,37,25,13,50,38,26,14,51,39,27,15,52,40,28,16
1546DATA 1,18,35,52,5,22,39,56,9,26,43,60,13,30,47,64
1548DATA 49,34,19,4,53,38,23,8,57,42,27,12,61,46,31,16
1550DATA 1,22,43,64,16,27,38,49,4,23,42,61,13,26,39,52
1600 FOR J=1 TO 4
1605 IF X(M(I,J))<>1/8 THEN 1650
1610 LET X(M(I,J))=5
1615 IF L(I)<5 THEN 1625
1620 PRINT "LET'S SEE YOU GET OUT OF THIS! MACHINE MOVES TO";
1622 GOTO 1626
1625 PRINT "YOU FOX. JUST IN THE NICK OF TIME, MACHINE MOVES TO";
1626 LET M=M(I,J)
1630 GOSUB 1000
1640 GOTO 70
1650 NEXT J
1660 PRINT "MACHINE CONCEDES THIS GAME."
1665 GOTO 500
1700 LET S=1/8
1703 IF I-INT(I/4)*4>1 THEN 1715
1705 LET A=1
1710 GOTO 1720
1715 LET A=2
1720 FOR J=A TO 5-A _ STEP 5-2*A
1725 IF X(M(I,J))=S THEN 1750
1730 NEXT J
1735 GOTO 1415
1750 LET X(M(I,J))=5
1755 LET M=M(I,J)
1760 PRINT "MACHINE TAKES";
1770 GOSUB 1000
1780 GOTO 70
1800 FOR I=1 TO 64
1810 IF X(I)<>1/8 THEN 1850
1815 LET X(I)=0
1850 NEXT I
1860 RETURN
2000 END
