10 REM PROJECT SIMULATOR
12 REM
14 REM A PROJECT CONSISTS OF A NUMBER OF SEQUENTIAL TEAMS
16 REM EACH TEAM PERFORMS A RANDOM QUANTITY OF WORK ON ITEMS
18 REM THE PROJECT STARTS WITH SOME NUMBER OF ITEMS
20 REM THE SIMULATION RUNS FOR A SPECIFIED NUMBER OF WEEKS

100 REM THE NUMBER OF TEAMS
102 READ N
110 REM THE CAPACITY OF EACH TEAM
112 MAT READ C(N)
114 DIM E(N)
120 REM THE BACKLOG FOR EACH TEAM (AND COMPLETED WORK)
122 DIM B(N+1)
130 REM THE ACCOMPLISHMENTS OF EACH TEAM IN ONE WEEK
132 DIM A(N)
140 REM THE NUMBER OF WEEKS TO RUN
142 READ W9
150 REM THE INITIAL AMOUNT OF WORK (BACKLOG)
152 READ B(1)

200 REM THE SIMLUATION
204 LET W = 1

210 REM EACH WEEK SEES WORK BY EACH TEAM, PUSHING COMPLETED ITEMS
212 REM TO THE NEXT TEAM
220 FOR I = 1 TO N
230 REM CALCULATE TEAM EFFECTIVENESS
232 LET E(I)=RND(0)+0.5
240 REM CALCULATE WORK DONE BY THIS TEAM
242 LET P = INT(C(I)*E(I))
250 REM REMOVE ITEMS FROM BACKLOG AND PUSH TO NEXT TEAM
252 IF P <= B(I) THEN 260
254 LET P = B(I)
260 LET B(I) = B(I)-P
262 LET B(I+1) = B(I+1)+P
270 LET A(I) = P
280 NEXT I
290 GOSUB 500
292 LET W = W+1
294 IF W <= W9 THEN 210

300 STOP

500 REM PRINT WEEK SUMMARY
510 PRINT "WEEK ";W
512 GOSUB 600
514 GOSUB 700
516 GOSUB 800
590 RETURN

600 REM PRINT WEEK EFFECTIVENESS
610 PRINT " EFFECTIVE";
620 FOR I = 1 TO N
630 PRINT E(I);
640 NEXT I
645 PRINT
650 RETURN

700 REM PRINT WEEK ACCOMPLISHMENTS
710 PRINT " DONE    ";
720 FOR I = 1 TO N
730 PRINT A(I);
740 NEXT I
745 PRINT
750 RETURN

800 REM PRINT WEEK STATUS
810 PRINT " BACKLOGS";
820 FOR I = 1 TO N
830 PRINT B(I);
840 NEXT I
842 PRINT
845 PRINT "COMPLETED:";B(N+1)
850 RETURN

900 DATA 5
910 DATA 4, 4, 4, 4, 4
920 DATA 5
930 DATA 100
999 END

