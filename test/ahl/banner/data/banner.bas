100 REM PROGRAM WRITTEN BY DANIEL R. VERNON
110 REM SENIOR AT BUTLER SENIOR HIGH SCHOOL
120 REM           BUTLER, PENNSYLVANIA 16001
130 REM DATE: 2/1/73
140 REM COMPUTER SUPERVISION: MR. WILLIAM ELLIS
150 REM COMPUTER TOPICS INSTRUCTION: MR. ALBERT STEWART
160 REM
170 REM THIS PROGRAM DESIGNED TO CREATE POSTERS
180 REM
190 DIMG$(6),H$(6),B$(9),G(8),A(54)
200 PRINT"INPUT HEIGHTH, WIDTH IN INCHES";\INPUTL,R\S=0\A=R*2\C=A
210 PRINT"HOW FAR, IN INCHES FROM THE LEFT HAND SIDE, DO YOU WANT TO PLACE "
220 PRINT"THE LETTERS";\INPUTS\S=12*S
230 PRINT"INPUT MESSAGE HERE"
240 LINPUTB$(1),B$(2),B$(3),B$(4),B$(5),B$(6),B$(7),B$(8),B$(9)
250 FORX=9TO1STEP-1\CHANGEB$(X)TOA\FORY=1TO6\A(X*6-6*Y)=A(Y)\NEXTY\NEXTX
260 FORX=1TO6\READH$(X)\NEXTX\H$=H$(L)\GOSUB 940
270 F=F+1\IFA(F)=0THEN990\G(0)=L\FORX=1TO6\G(X)=A(F)\NEXTX\CHANGEGTOG$
280 FORX=1TO6\G(0)=X\CHANGEGTOG$(X)\NEXTX
290 FORX=1TOA/2\PRINT\NEXTX
300 IFA(F)=46THEN345\IFA(F)=36THEN990\IFA(F)=32THEN630\IFA(F)<48THEN270
309 IFA(F)>57THEN310\ONA(F)-47GOTO500,440,620,625,635,550,615,605,595,585
310 IFA(F)<65THEN270\IFA(F)>79THEN330
320 ONA(F)-64GOTO350,360,370,380,390,400,410,430,440,450,460,470,480,490,500
330 IFA>90THEN270\ONA(F)-79GOTO510,520,540,550,560,570,580,590,600,610,620
340 GOTO270 
345 FORX=1TOA\PRINTTAB(S);G$;G$\NEXTX\GOTO270
350 GOSUB640\GOSUB690\GOSUB640\GOTO270
360 GOSUB640\GOSUB650\A=C*.5\GOSUB640\A=C\GOSUB610\GOTO270
370 GOSUB640\GOSUB700\GOSUB700\GOTO270 
380 GOSUB640\GOSUB700\A=C*.5\GOSUB640\A=C\GOSUB640\GOTO270
390 GOSUB640\GOSUB650\GOSUB650\GOTO270
400 GOSUB640\GOSUB690\GOSUB690\GOTO270
410 GOSUB640\A=C*.75\GOSUB700\A=C*.25\GOSUB650\A=C\GOSUB760
420 A=C*.25\GOSUB710\A=C\GOTO270
430 GOSUB640\GOSUB710\GOSUB640\GOTO270
440 GOSUB640\GOTO270
450 GOSUB750\GOSUB740\GOSUB640\GOTO270
460 GOSUB640\GOSUB860\GOTO270
470 GOSUB640\GOSUB740\GOSUB740\GOTO270
480 GOSUB640\GOSUB890\GOSUB880\GOSUB640\GOTO270
490 GOSUB640\GOSUB890\GOSUB640\GOTO270
500 GOSUB640\GOSUB700\GOSUB640\GOTO270
510 GOSUB640\GOSUB690\GOSUB790\GOTO270
520 GOSUB640\A=C*.75\GOSUB700\A=.25*C\GOSUB650\A=C\GOSUB640
530 A=C*.25\GOSUB710\A=C\GOTO270
540 GOSUB640\GOSUB690\A=C*.5\GOSUB640\GOSUB810\A=C\GOTO270
550 GOSUB770\GOSUB680\GOSUB760\GOTO270
560 GOSUB780\GOSUB640\GOSUB780\GOTO270
570 GOSUB640\GOSUB740\GOSUB640\GOTO270
580 GOSUB890\GOSUB880\GOTO270
585 GOSUB790\GOSUB690\GOSUB640\GOTO270
590 GOSUB640\GOSUB880\GOSUB890\GOSUB640\GOTO270
595 GOSUB640\GOSUB650\GOSUB640\GOTO270
600 GOSUB900\GOTO270
605 GOSUB780\GOSUB780\GOSUB640\GOTO270
610 GOSUB970\GOSUB800\GOSUB960\GOTO270
615 GOSUB640\GOSUB650\GOSUB760\GOTO270
620 GOSUB920\GOTO270
625 GOSUB700\GOSUB650\A=C*.5\GOSUB640\A=C\GOSUB810\GOTO270
630 GOSUB940\GOTO270
635 GOSUB790\GOSUB710\GOSUB640\GOTO270
640 FORY=1TOA\PRINTTAB(S)I\FORX=1TO10\PRINTG$;\NEXTX\PRINT\NEXTY\RETURN
653 IFA<1THEN660\GOTO670
660 LETA=1
670 FORX=1TOA\PRINTTAB(S);G$;G$;H$;H$;G$;G$;H$;H$;G$;G$\NEXTX\RETURN
680 PRINTTAB(S);
690 FORX=1TOA\PRINTTAB(4*L*S);G$;G$;H$;HS;G$;G$\NEXTX\RETURN
700 FORX=1TOA\PRINTTAB(S);G$;G$;\PRINTTAB(8*L+S);G$;G$\NEXTX\RETURN
710 IFA=1THEN720\GOTO730
720 LETA=1
730 FORX=1TOA\PRINTTAB(4*L*S);G$;G$\NEXTX\RETURN
740 FORX=1TOA\PRINTTAB(S);G$;G$\NEXTX\RETURN
750 FORX=1TOA\PRINTTAB(S);G$;G$;G$;G$\NEXTX\RETURN
760 FORY=1TOA\PRINTTAB(S);G$;G$;G$;G$;G$;G$;HS;H$;G$;G$\NEXTY\RETURN
770 FORX=1TOA\PRINTTAB(S);G$;G$;H$;H$;G$;G$;G$;G$;G$;G$\NEXTX\RETURN
780 FORX=1TOA\PRINTTAB(8*L*S);G$;G$\NEXTX\RETURN
790 FORX=1TOA\PRINTTAB(4*L*8);G$;G$;G$;G$;G$;G$\NEXTX\RETURN
800 FORX=1TOA\PRINTTAB(S);G$;G$;G$;G$;G$;G$\NEXTX\RETURN
810 FORX=1TOC/2\PRINTTAB(S);\FORY=1TO2\FORZ=1TO(5*L)-X\PRINTG$(1);\NEXTZ
820 IFX>3THEN950\V=X
830 PRINTH$(2*V);\NEXTY\PRINT\NEXTX\RETURN
840 FORX=1TOC/2\PRINTTAB(S);H$(X);\FORY=1TO10*L-(2*X)\PRINTG$(1);\NEXTY\PRINT
850 NEXTX\RETURN
860 FOR X=4*LTO7*LSTEP14*L/(C*6)\PRINTTAB(X*S);G$;G$;G$;
870 PRINTTAB(7*L-X*S);G$;G$;G$\NEXT X\RETURN
880 FORX=0TO6*LSTEP6*L/C\PRINTTAB(X+S);G$;G$;G$;G$\NEXTX\RETURN
890 FORX=6*LTO0STEP-6*L/C\PRINTTAB(X+S);G$;G$;G$;G$\NEXTX\RETURN
900 FORX=0TO7*LSTEP(14*L)/(C*6)\PRINTTAB(X+S);G$;G$;G$;
910 PRINTTAB(7*L-X*S);G$;G$;G$\NEXT X\RETURN
920 FORX=0TO7*LSTEP(7*L)/(C*3)\PRINTTAB(S);G$;G$;TAB(X*S);G$;G$;G$;
930 PRINTTAB(8*L*5);G$;G$\NEXTX\RETURN
940 FORX=1TOA*3\PRINT\NEXTX\RETURN
950 FORW=1TOX-3\PRINT" ";\NEXTW\V=3\GOTO830
960 FORX=4*LTO7*LSTEPL*4/C\PRINTTAB(X*3);G$;G$;G$\NEXTX\RETURN
970 FOR X=7*LTO4*LSTEP-4*L/C\PRINTTAB(X*S);G$;G$;G$\NEXTX\RETURN
980 DATA" ","  ","   ","    ","     ","      ",""
990 FORX=1TOC*3\PRINT\NEXTX
1000 END 

