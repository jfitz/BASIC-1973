100 RANDOMIZE 
110 DIM W(25, 103), V(25,103)
120 PRINT "WHAT ARE YOUR WIDTH AND LENGTH?"
121 INPUT H, V
122 PRINT
130 IF H<>1 THEN 150
131 IF V<>1 THEN 150
132 PRINT "MEANINGLESS DIMENSIONS, TRY AGAIN"
140 PRINT
141 GO TO 120
150 PRINT
151 PRINT
160 LET Q=0
161 LET Z=0
162 LET X=INT(RND(0)*H+1)
163 FOR I=1 TO H
170 IF I=X THEN 173
171 PRINT ":--";
172 GO TO 180
173 PRINT ":  ";
180 NEXT I
190 PRINT ":"
191 LET C=1
192 LET W(X, 1)=C
193 LET C = C + 1
200 LET R=X
201 LET S=1
202 GO TO 260
210 IF R<>H THEN 240
211 IF S<>V THEN 230
220 LET R=1
221 LET S=1
222 GO TO 250
230 LET R=1
231 LET S=S+1
232 GO TO 250
240 LET R=R+1
250 IF W(R,S)=0 THEN 210
260 IF R-1=0 THEN 530
261 IF W(R-1,S)<>0 THEN 530
270 IF S-1=0 THEN 390
280 IF W(R,S-1)<>0 THEN 390
290 IF R=H THEN 330 
300 IF W(R+1, S)<>0 THEN 320
310 LET X=INT(RND(0)*3+1)
320 IF X=1 THEN 790
321 IF X=2 THEN 820
323 IF X=3 THEN 860
330 IF S<>V THEN 340
331 IF Z=1 THEN 370
332 LET Q=1
333 GO TO 350
340 IF W(R, S+1)<>0 THEN 370
350 LET X=INT(RND(0)*3+1)
360 IF X=1 THEN 790
361 IF X=2 THEN 820
362 IF X=3 THEN 910
370 LET X=INT(RND(0)*2+1)
380 IF X=1 THEN 790
381 IF X=2 THEN 820
390 IF R=H THEN 470
400 IF W(R+1,S)<>0 THEN 470
401 IF S<>V THEN 420
410 IF Z=1 THEN 450
411 LET Q=1
412 GO TO 430
420 IF W(R, S+1)<>0 THEN 450
430 LET X=INT(RND(0)*2+1)
440 IF X=1 THEN 790
441 IF X=2 THEN 860
442 IF X=3 THEN 910
450 LET X=INT(RND(0)*2+1)
460 IF X=1 THEN 790
461 IF X=2 THEN 860
470 IF S<>V THEN 490
480 IF Z=1 THEN 520
481 LET Q=1
482 GO TO 500
490 IF W(R, S+1)<>0 THEN 520
500 LET X=INT(RND(0)*2+1)
510 IF X=1 THEN 790
511 IF X=2 THEN 910
520 GO TO 790
530 IF S-1=0 THEN 670
540 IF W(R, S-1)<>0 THEN 670
541 IF R=H THEN 610
542 IF W(R+1,S)<>0 THEN 610
550 IF S<>V THEN 560
551 IF Z=1 THEN 590
552 LET Q=1
553 GO TO 570
560 IF W(R, S+1)<>0 THEN 590
570 LET X=INT(RND(0)*3+1)
580 IF X=1 THEN 820
581 IF X=2 THEN 860
582 IF X=3 THEN 910
590 LET X=INT(RND(0)*2+1)
600 IF X=1 THEN 820
601 IF X=2 THEN 860
610 IF S<>V THEN 630
620 IF Z=1 THEN 660
621 LET Q=1
622 GO TO 640
630 IF W(R, S+1)<>0 THEN 660
640 LET X=INT(RND(0)*2+1)
650 IF X=1 THEN 820
651 IF X=2 THEN 910
660 GO TO 820
670 IF R=H THEN 740
680 IF W(R+1,S)<>0 THEN 740
681 IF S<>V THEN 700
690 IF Z=1 THEN 730
691 LET Q=1
692 GO TO 830
700 IF W(R,S+1)<>0 THEN 730
710 LET X=INT(RND(0)*2+1)
720 IF X=1 THEN 860
721 IF X=2 THEN 910
730 GO TO 860
740 IF S<>V THEN 760
750 IF Z=1 THEN 780
751 LET Q=1
752 GO TO 770
760 IF W(R, S+1)<>O THEN 780
770 GO TO 910
780 GO TO 1000
790 LET W(R-1, S)=C
800 LET C=C+1
801 LET V(R-1, S)=2
802 LET R=R-1
810 IF C=H*V+1 THEN 1010
811 LET Q=0
812 GO TO 260
820 LET W(R,S-1)=C
830 LET C=C+1
840 LET V(R,S-1)=1
841 LET S=S-1
842 IF C=H*V+1 THEN 1010
850 LET Q=0
851 GO TO 260
860 LET W(R+1,S)=C
870 LET C=C+1
871 IF V(R,S)=0 THEN 880
872 LET V(R,S)=3
873 GO TO 890
880 LET V(R,S)=2
890 LET R=R+1
900 IF C=H*V+1 THEN 1010
902 GO TO 530
910 IF Q=1 THEN 960
920 LET W(R,S+1)=C
921 LET C=C+1
922 IF V(R,S)=0 THEN 940
930 LET V(R,S)=3
931 GO TO 950
940 LET V(R,S)=1
950 LET S=S+1
951 IF C=H*V+1 THEN 1010
952 GO TO 260
960 LET Z=1
970 IF V(R,S)=0 THEN 980
971 LET V(R,S)=3
972 LET Q=0
973 GO TO 1000
980 LET V(R,S)=1
981 LET Q=0
982 LET R=1
990 LET S=1
991 GO TO 250
1000 GO TO 210
1010 FOR J=1 TO V
1011  PRINT"!";
1012  FOR I=1 TO H
1013   IF V(I,J)<2 THEN 1030
1020   PRINT"   ";
1021   GO TO 1040
1030   PRINT"  !";
1040  NEXT I 
1041  PRINT
1042  FOR I=1 TO H
1045   IF V(I,J)=0 THEN 1060
1050   IF V(I,J)=2 THEN 1060
1051   PRINT":  ";
1052   GO TO 1070 
1060   PRINT ":--";
1070  NEXT I
1071  PRINT":"
1072 NEXT J
1073 END

