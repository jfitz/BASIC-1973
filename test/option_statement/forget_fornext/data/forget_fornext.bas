10 REM TEST OPTION FORGET_FORNEXT
11 OPTION REQUIRE_INITIALIZED TRUE
20 PRINT "OPTION FORGET_FORNEXT FALSE"
21 OPTION FORGET_FORNEXT FALSE
22 FOR I = 1 TO 3
23 PRINT I
24 NEXT I
25 PRINT "I IS NOW";I
26 FORGET I
30 PRINT "OPTION FORGET_FORNEXT TRUE"
31 OPTION FORGET_FORNEXT TRUE
32 FOR I = 1 TO 3
33 PRINT I
34 NEXT I
35 PRINT "I IS NOW";I
99 END