10 PRINT "BOOMERANG PUZZLE FROM ARITHMETICS OF NICOMACHUS — A.D.90!"
20 PRINT
30 PRINT "PLEASE THINK OF A NUMBER BETWEEN 1 AND 100."
40 PRINT "YOUR NUMBER DIVIDED BY 3 HAS A REMAINDER OF";
45 INPUT A
50 PRINT "YOUR NUMBER DIVIDED BY 5 HAS A REMAINDER OF";
55 INPUT B
60 PRINT "YOUR NUMBER DIVIDED BY 7 HAS A REMAINDER OF";
65 INPUT C
70 PRINT
80 PRINT "LET ME THINK A MOMENT...."
90 SLEEP(5)
100 D=70*A+21*B+15*C
110 IF D<=105 THEN 140
120 D=D-105
130 GOTO 110
140 PRINT
150 PRINT "YOUR NUMBER WAS"D", RIGHT";
160 INPUT A$
165 PRINT
170 IF A$="YES" THEN 220
180 IF A$="NO" THEN 240
190 PRINT "EH? I DON'T UNDERSTAND '"A$"' TRY 'YES' OR 'NO'"
200 GOTO 150
220 PRINT "HOW ABOUT THAT!!"
230 GOTO 250
240 PRINT "I FEAR YOUR ARITHMETIC IS IN ERROR."
250 PRINT
268 PRINT "LET'S TRY ANOTHER."
270 GOTO 20
999 END

