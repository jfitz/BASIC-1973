10 G = 6
20 N = 100
30 REM-TRAP
40 REM-STEVE ULLMRN, 8-1-72 
50 PRINT "WANT INSTRUCTIONS (1 FOR YES)"
60 INPUT Z
70 IF Z<>1 THEN 180
80 PRINT "I AM THINKING OF A NUMBER BETWEEN 1 AND";N
90 PRINT "TRY TO GUESS MY NUMBER. ON EACH GUESS,"
100 PRINT "YOU ARE TO ENTER 2 NUMBERS, TRYING TO TRAP"
110 PRINT "MY NUMBER BETWEEN THE TWO NUMBERS. I WILL"
120 PRINT "TELL YOU IF YOU HAVE TRAPPED MY NUMBER, IF MY"
130 PRINT "NUMBER IS LARGER THAN YOUR TWO NUMBERS, OR IF"
140 PRINT "MY NUMBER IS SMALLER THAN YOUR TWO NUMBERS."
150 PRINT "IF YOU WANT TO GUESS ONE SINGLE NUMBER, TYPE"
160 PRINT "YOUR GUESS FOR BOTH YOUR TRAP NUMBERS."
170 PRINT "YOU GET";G;"GUESSES TO GET MY NUMBER."
180 X=INT(N*RND(0))+1
190 FOR Q=1 TO G
200 PRINT
210 PRINT "GUESS #";Q;
220 INPUT A,B
230 IF A<>B THEN 240
235 IF X=A THEN 400
240 IF A<=B THEN 260
250 GOSUB 360
260 IF X<A THEN 300
270 IF X<=B THEN 320
280 PRINT "MY NUMBER IS LARGER THAN YOUR TRAP NUMBERS."
290 GOTO 330 
300 PRINT "MY NUMBER IS SMALLER THEN YOUR TRAP NUMBERS."
310 GOTO 330 
320 PRINT "YOU HAVE TRAPPED MY NUMBER."
330 NEXT Q
340 PRINT "SORRY, THAT'S";Q;"GUESSES. NUMBER WAS";X
350 GOTO 410 
360 R=A
370 A=B
380 B=R
390 RETURN 
400 PRINT "YOU GOT IT!!!"
410 PRINT
420 PRINT "TRY AGAIN."
430 PRINT
440 GOTO 180
450 END
