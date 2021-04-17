.OPTION ALLOW_ASCII FALSE
.OPTION ALLOW_HASH_CONSTANT FALSE
.OPTION ALLOW_PI FALSE
.OPTION APOSTROPHE_COMMENT FALSE
.OPTION ASC_ALLOW_ALL FALSE
.OPTION BACK_TAB FALSE
.OPTION BACKSLASH_SEPARATOR TRUE
.OPTION BANG_COMMENT FALSE
.OPTION BASE 0
.OPTION BRACKETS FALSE
.OPTION CACHE_CONST_EXPR TRUE
.OPTION CHR_ALLOW_ALL FALSE
.OPTION COLON_FILE FALSE
.OPTION COLON_SEPARATOR TRUE
.OPTION CRLF_ON_LINE_INPUT FALSE
.OPTION DEFAULT_PROMPT "? "
.OPTION DETECT_INFINITE_LOOP TRUE
.OPTION ECHO TRUE
.OPTION EXTEND_IF FALSE
.OPTION FIELD_SEP "COMMA"
.OPTION FORGET_FORNEXT FALSE
.OPTION FORNEXT_ONE_BEYOND FALSE
.OPTION HEADING TRUE
.OPTION IGNORE_RND_ARG FALSE
.OPTION IMPLIED_SEMICOLON FALSE
.OPTION INPUT_HIGH_BIT FALSE
.OPTION INT_BITWISE FALSE
.OPTION INT_FLOOR FALSE
.OPTION LOCK_FORNEXT FALSE
.OPTION MATCH_FORNEXT FALSE
.OPTION MAX_LINE_NUM 32767
.OPTION MIN_LINE_NUM 1
.OPTION MIN_MAX_OP FALSE
.OPTION NEWLINE_SPEED 0
.OPTION PRECISION 9
.OPTION PRETTY_MULTILINE FALSE
.OPTION PRINT_SPEED 0
.OPTION PRINT_WIDTH 0
.OPTION PROMPT "READY"
.OPTION PROMPTD "DEBUG"
.OPTION PROMPT_COUNT FALSE
.OPTION PROVENANCE FALSE
.OPTION QMARK_AFTER_PROMPT FALSE
.OPTION RANDOMIZE FALSE
.OPTION REQUIRE_INITIALIZED FALSE
.OPTION RESPECT_RANDOMIZE TRUE
.OPTION SEMICOLON_ZONE_WIDTH 0
.OPTION SINGLE_QUOTE_STRINGS FALSE
.OPTION TIMING FALSE
.OPTION TRACE FALSE
.OPTION WRAP FALSE
.OPTION ZONE_WIDTH 16
100 REMARK THIS PROGRAM CARRIES OUT A SERIES OF KNIGHT'S MOVES
110 REMARK UNTIL NO FURTHER MOVE IS POSSIBLE. IT THEN PRINTS
120 REMARK OUT THE FINAL POSITION AND THE LENGTH OF THE SERIES.
130 
140 REMARK WE READ IN THE INITIAL PLACEMENT OF THE KNIGHT
150 READ I0, J0
160 PRINT "RANK  ";"FILE  ";"LENGTH"
180
182 LET Z0 = 0
190 REMARK WE ZERO THE BOARD AND INITIALIZE
200 FOR I = 1 TO 8
210    FOR J = 1 TO 8
220       LET B(I,J) = 0
230    NEXT J
240 NEXT I
250 LET I = I0
260 LET J = J0
270 LET M = 1
280 LET B(I,J) = -1
290
300 REMARK WE NOW START THE SERIES OF MOVES
310 LET C1 = 9
320 LET C = 0
330 FOR I1 = I - 2 TO I + 2
340    IF I1 = 1 THEN 480
350    IF ABS(I1 - 4.5) > 4 THEN 480
360    LET D1 = 3 - ABS(I1 - I)
370    FOR J1 = J - D1 TO J + D1 STEP 2*D1
380       IF ABS(J1 - 4.5) > 4 THEN 470
390       IF B(I1,J1) < 0 THEN 470
400       LET C = C + 1
410       IF C <> C1 THEN 470
420       LET I = I1
430       LET J = J1
440       LET B(I,J) = -1
450       LET M = M + 1
460       GOTO 310
470    NEXT J1
480 NEXT I1
490 IF C = 0 THEN 600
500 REMARK NOW WE SELECT A RANDOM INTEGER TO SELECT A MOVE
510 LET C1 = INT(RND(Z)*C + 1)
520 GOTO 320
600 REMARK WE HAVE GONE AS FAR AS WE CAN
610 PRINT I; J; M
612 LET Z0 = Z0+1
620 IF Z0 < 40 THEN 200
630 REMARK WE GO FOR ANOTHER TRIAL
880
890 REMARK THE DATA FOR THE STARTING POSITION
900 DATA 1, 1
999 END
