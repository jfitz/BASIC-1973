2 REM TEST RENUMBER COMMAND
4 GOTO 80
6 GOSUB 50
8 REM ON K GOTO 80,82
10 REM ON G GOSUB 50,52
12 REM GOTO N OF 80,82
14 IF A < B THEN 70
16 REM IF B = 7 THEN 72 ELSE 74
50 REM GOSUB TARGET 1
52 RETURN
60 REM GOSUB TARGET 2
62 RETURN
70 REM IF THEN TARGET
72 REM IF THEN TARGET
74 REM IF ELSE TARGET
80 REM GOTO TARGET 1
82 REM GOTO TARGET 2
99 END

