10 REM THIS PROGRAM COMPUTES INVERSE HYPERBOLIC FUNCTIONS
20 PRINT "SINH - 1 (1)"
30 PRINT "COSH - 1 (2)"
40 PRINT "TANH - 1 (3)"
50 PRINT "CSCH - 1 (4)"
60 PRINT "SECH - 1 (5)"
70 PRINT "COTH - 1 (6)"
80 PRINT "TYPE A NUMBER 1 TO 6 FOR FUNCTION DESIRED"
90 INPUT C
100 ON C GOTO 110,150,190,230,280,330
110 GOSUB 440
120 GOSUB 470
130 PRINT "SINH - 1";X;" = ";Z
140 GOTO 370
150 GOSUB 440
160 GOSUB 490
170 PRINT "COSH - 1";X;" = ";Z
180 GOTO 370
190 GOSUB 440
200 GOSUB 510
210 PRINT "TANH - 1";X;" = ";Z
220 GOTO 370
230 GOSUB 530
240 GOSUB 470
250 LET X = A
260 PRINT "CSCH - 1";X;" = ";Z
270 GOTO 370
280 GOSUB 530
290 GOSUB 490
300 LET X = A
310 PRINT "SECH - 1";X;" = ";Z
320 GOTO 370
330 GOSUB 530
340 GOSUB 510
350 LET X = A
360 PRINT "COTH - 1";X;" = ";Z
370 PRINT
380 PRINT "TYPE 1 TO CONTINUE, 0 TO STOP"
390 INPUT L
400 IF L = 1 THEN 420
410 STOP
420 PRINT
430 GOTO 80
440 PRINT "X = ";
450 INPUT X
460 RETURN
470 LET Z = LOG(X + SQR((X^2) + 1))
480 RETURN
490 LET Z = LOG(X + SQR((X^2) - 1))
500 RETURN
510 LET Z = (LOG((1 + X)/(1 - X)))/2
520 RETURN
530 PRINT "X = ";
540 INPUT X
550 LET A = X
560 LET X = 1/X
570 RETURN
580 END
