1 DIM V(10),U(10),T(10),M(8),O(8),H(8),B(8),P(6)
2 RANDOMIZE \ PRINT "HORSE RACE"
3 PRINT "EXAMPLE OF BET: 1,2,200,0 ."
5 PRINT \ PRINT"         SEVENTH = 1 MILE, 3 YR. OLDS       POST 2:35"
6 PRINT 
7 FOR I=1 TO 8
8 B(I)=I \ GOSUB 210
9 READ O(I) \ PRINT O(I)":1"
10 M(I)=(100+50*O(I)) / (O(I)+1)
11 NEXT I
12 PRINT
13 PRINT"ENTER HORSE(1-8);TO WIN, PLACE, SHOW(1,2,3);AND THE WAGER."
14 PRINT "AND 0 FOR NO MORE BETTlNG OR 1 OR MORE BETTING."
15 LET S = 0
16 PRINT
17 LET S = S + 1
18 PRINT"BET NO. ";S;
19 INPUT T(S),U(S),V(S),M
20 LET T(S)=ABS(INT(T(S)))
21 IF T(S)>8 THEN 26
22 IF T(S)<1 THEN 26
23 LET U(S)=ABS(INT(U(S)))
24 IF U(S)>3 THEN 26
25 IF U(S)>0 THEN 28
26 PRINT"HORSE NO. OR WIN-PLACE-SHOW IN ERROR" \ GO TO 18
28 IF V(S)<2 THEN 30
29 IF V(S)<300 THEN 33
30 PRINT"BET MUST BE >$2 AND <$300. BET AGAIN";
31 INPUT V(S) \ GO TO 28
33 IF M = 1 THEN 17
35 PRINT \ PRINT" THEY'RE OFF AND RUNNING -" \ PRINT
36 FOR I=1 TO 8 \ H(I)=0 \ NEXT I
40 FOR K=1 TO 8
42 SLEEP 6
44 FOR J=1 TO 8
46 H(J)=H(J)+RND(0)*M(J)
48 NEXT J
52 FOR I=8 TO 1 STEP -1
54 FOR J=2 TO I
56 ON SGN(H(B(J-1))-H(B(J)))+2 GO TO 60,58,62
58 IF RND(0)>.5 THEN 62
60 Z=B(J-1) \ B(J-1)=B(J) \ B(J)=Z
62 NEXT J
64 NEXT I
68 PRINT \ PRINT "   ";
70 ON K GOTO 72,74,76,78,80,82,84,86
72 PRINT "AS THEY BREAK FROM THE GATE" \ GO TO 88
74 PRINT "AT THE 1/4 MILE POLE" \ GO TO 88
76 PRINT "NEARING THE HALFWAY MARK" \ GO TO 88
78 PRINT "MIDWAY IN THE RACE" \ GO TO 88
80 PRINT "AT 5/8 OF A MILE" \ GO TO 88
82 PRINT "ROUNDING THE TURN" \ GO TO 88
84 PRINT "COMING DOWN THE STRETCH" \ GO TO 88
86 PRINT " FINISH"
88 REM
90 GO SUB 200
92 NEXT K
96 PRINT \ PRINT \ PRINT "$2 MUTUELS PAID:"
98 PRINT " STRAIGHT PLACE SHOW"
100 K=0
102 FOR I=1 TO 3
104 GO SUB 215
106 FOR J=1 TO 3
108 L=2*I+J-3 \ P(L)=1.5+.1*INT(.1*INT((4*O(B(I))/(J*(J+1))+RND(0))*100+5))
110 PRINT TAB(3+10*J); \ B=-16
112 FOR M=3 TO -1 STEP -1
114 P=INT(P(L)/(10^M))
116 P=P-10*INT(P/10)
117 IF P=0 THEN 118 \ B=0
118 PRINT CHR$(48+P+B);
138 IF M<>0 THEN 139 \ PRINT ".";
139 NEXT M
140 PRINT "0";
142 NEXT J
144 PRINT
146 NEXT I
150 PRINT \ Q=0
152 FOR J=1 TO S
154 PRINT "BET NO. "; J
156 P=0
158 FOR I=1 TO 6 \ H(B(I))=I \ NEXT I
160 IF U(J)<H(T(J)) THEN 166
162 P= .01*INT((V(J)*50)*P(U(J)*H(T(J))*2-3))
164 PRINT "YOU COLLECT" P "ON "; \ GO TO 172
166 IF H(T(J))>3 THEN 168 \ PRINT "NEXT TIME, BUY A SHOW"; \ GO TO 170
168 PRINT "TEAR UP YOUR";
170 PRINT " TICKET ON ";
172 I=0 \ B(0)=T(J) \ GOSUB 215 \ PRINT
174 Q=Q+P-V(J)
176 NEXT J
178 IF Q<0 THEN 182
180 PRINT "YOUR TOTAL WINNINGS AMOUNT TO $" Q \ STOP
182 PRINT "YOUR TOTAL LOSSES AMOUNT TO $" ABS(Q) \ STOP
200 PRINT "POS.  HORSE   LENGTHS BEHIND"
205 FOR I=1 TO 8
210 PRINT I;
215 ON B(I) GOTO 220,222,224,226,228,230,232,234
220 PRINT "MAN O'WAR  "; \ GO TO 240
222 PRINT "CITATION   "; \ GO TO 240
224 PRINT "WHIRLAWAY  "; \ GO TO 240
226 PRINT "ASSAULT    "; \ GO TO 240
228 PRINT "SEABISCUIT "; \ GO TO 240
230 PRINT "GALLANT FOX"; \ GO TO 240
232 PRINT "STYMIE     "; \ GO TO 240
234 PRINT "COALTOWN   ";
240 IF K=0 THEN 260
245 IF I>1 THEN 250 \ PRINT \ GO TO 255
250 PRINT .1*INT(H(B(1))-H(B(I)))
255 NEXT I
260 RETURN
301 DATA 3,4,5,8,9,11,20,30
999 END