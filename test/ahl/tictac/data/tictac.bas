180 PRINT"YQU HAVE THE OPPORTUNITY OF TRYING TO BEAT THE COMPUTER" 

130 PRINT«AT TIC-TAC-TOE, ENTER YOUR MOVES AS FOLLOWS*" 

140 PRINT 

150 DIM CCll) 

160 DIM D(U) 

170 FOR K*t TO 11 

180 REAO COO, 

190 NEXT K 

200 PRINT H 

210 PRINT 

220 PRW'ROWS ARE HORIZONTAL (ACROSS) , f .COLUMNS ARE VERTICALCUP ♦ DOWN)" 

230 DIM B(9) 

240 DIM A(3,3) 

250 PRINT 

260 PRINT "NEW GAME STARTED NOW H 

270 FOR Jul TO 3 
260 FOR III TO 3 
290 LET A(I,J)*0 

300 NEXT I 

301 LET I»I-1 

310 NEXT J 

311 LET 4«J»1 
320 LET Zi 

330 PRINT "YOUR MOVE", 

340 INPUT R,C 

350 PRINT 

360 IF R»3 THEN 620 

370 IF C&gt;3 THEN 620 

380 IF A(R,C) &lt;&gt; THEN 620 

390 LET A(R ( C)»-1 

400 GOSUB 1660 

410 IF Z »1 THEN 2070 

420 REM MACHINE MOVE,,, 

430 GOSUB 1100 

440 REM TEST FOR GAME WIN... 

450 GOSUB 1660 

460 IF Z»0 THEN 650 

470 REM PRINT GAME BOARD.. 

480 GO TO 490 

490 PRINT 

500 FOR Kit TO J 

510 LET B«A(K,U 

520 LET D»A(K,2) 

530 LET F*A(K,3) 

540 GOSUB 840 

550 IF K&gt;2 THEN 570 

560 PRINT "***************" 

570 NEXT K 

571 LET KsK-1 
580 PRINT 

590 IF Z «&gt;0 THEN 2070 

600 GO TO 330 

610 STOP 

620 PRINT »«* — ILLEGAL MOVE — TRY AGAIN -» — » 

630 PRINT 

640 GO TO 330 

650LET T2*0 

660 FOR J«l TO 3 

670 FOR 1*1 TO 3 

680 IF A(I,J)&lt;&gt;0 THEN 700 

690 LET T2*T2*1 

700 NEXT I 

701 LET 1*1-1 

710 NEXT J 

711 LET J*J-1 

720 IF T2&gt;0 THEN 750 

730 GOSUB 1340 

740 GO TO 480 

750 IF T2M THEN 480 

760 FOR J»l TO 8 

770 IF B(J5«-2 THEN 800 

780 NEXT J 

781 LET J»J-1 
790 GO TO 730 
800 GOSUB 2000 
810 GO TO 480 

820 REM PRINT TIC*TAC»TQE BOARD ROW 

830 REM 

840 IF B&lt;*0 THEN 910 

850 PRINT " * "7 

660 IF D«&gt;0 THEN 940 

870 PRINT « * »t 

880 IF F&lt;»0 THEN 970 

890 PRINT « " 

900 GO TO 1070 

910 IF B&gt;0 THEN 1000 

920 PRINT "YOU * "7 

930 GO TO 860 

940 IF 0*0 THEN 1020 

950 PRINT "YOU * "I 

960 GO TO 680 

970 IF F&gt;0 THEN 1040 

980 PRINT "YOU" 

990 GO TO 900 

1000 PR I NT "POP * "7 

1010 GO TO 860 

1020 PRINT "PDP * "J 

1030 GO TO 880 

1040 PRINT "POP" 

1050 GO TQ900 

1060 REM PRINT LEGENDS., 

1070 PRINT ».■*•*" 

1080 RETURN 

1090 REM PROGRAM TO MAKE MOVE FOR THE MACHINE,,,, 

1100 LET M«INTC3,33*RNDCM)) 

1110 LET N»INTC3,33333*RND(N)) 

1120 IF M»0 THEN 1100 

1130 IF M»3 THEN 1100 

1140 IF N«0 THEN 1110 

1150 IF N»3 THEN 1110 

1160 LET CC2)*M 

1170 LET D(2)*N 



219 



1180 LET CC3)*N 




1190 LET DC3)*M 




1200 FOR I«l TO 8 




1210 IF B(I)»1 THEN 1370 




1220 NEXT I 




1221 LET X*I-l 




1230 FOR 1*1 TO 8 




1240 IF BCI)*-1 THEN 1370 




1250 NEXT I 




1251 LET 1*1-1 




1260 IF R*C«0 THEN 1550 




1270 FOR Ml TO 11 




1280 LET I*CCK) 




i290 LET J«D0O 




1300 IF ACIf J)«»0 THEN 1330 




1310 LET ACI,J)*l 




1320 GO TO 1360 




1330 NEXT K 




1331 LET K»K*1 




1340 PRINT " ,,, TIE GAME ,,, « 




1350 LET Z*3 




1360 RETURN 




1370 IF 1*3 THEN 1440 




1380 FOR J«l TO 3 




1390 IF A(I,J)»0 THEN 1420 




1400 NEXT J 




1401 LET J*J-l 




1410 GO TO 1360 




1420 LET ACI,J)*1 




1430 GO TO 1360 




1440 IF I»6 THEN 1510 




1450 FOR J»l TO 3 




1460 IF A(J,I-3)*0 THEN 1490 




1470 NEXT J 




1471 LET J«J«1 




1480 GO TO 1360 




1490 LET ACJ, 1-33*1 




1500 GO TO 1360 




1510 IF I&gt;7 THEN 1550 




1520 FOR J*l TO 3 




1530 IF A(J,J)*0 THEN 1590 




1540 NEXT J 




1541 LET J»J*1 




1550 IF A(l,3)*0 THEN 1610 




1560 IF A(3,l)*0 THEN 1630 




1570 LET A(2,2)*l 




1580 GO TO 1360 




1590 LET A(J,J)*1 




1600 GO TO 1360 




1610 LET A(l,3)*l 




1620 GO TO 1360 




1630 LET AC3,l)*i 




1640 GO TO 1360 




1650 REM PROGRAM TO TEST FOR GAME WINNER..,. 




1660 LET T1*0 




1670 FOR J*l TO 9 




1680 LET BU)*0 




1690 NEXT J 




1691 LET J*J-1 




1700 FOR J*l TO 3 




1710 FOR 1*1 TO 3 




1720 IF A(J,n«&gt;A(J,n THEN 1750 




1730 NEXT I 




1731 LET I«I-1 




1740 LET T1*A(J,I) 




1750 NEXT J 




1751 LET J*JM 




1760 FOR J*l TO 3 




1770 FOR 1*1 TO 3 




1780 IF A(l, J)&lt;»ACI,J) THEN 1810 




1790 NEXT I 




1791 LET I-I-l 




1800 LET T1"ACI,J) 




1810 NEXT J 




1811 LET J*J«1 




1820 IF A(l*l)aA(3,3) THEN 1930 




1830 IF A(3,1)*A(1,3) THEN 1970 




1840 IF T1&lt;&gt;0 THEN 1990 




1850 FOR J*l TO 3 




1860 FOR 1*1 TO 3 




1870 LET B(J)sB(J)*A(J,I) 




1880 LET B(J*3)"BCJ*3)*ACI,J) 




1890 NEXT I 




1891 LET I*IM 




1900 NEXT J 




1901 LET J*J*1 




1910 LET B(7)»AC1,1)*A(2,2)*A(3,3) 




1920 RETURN 




1930 IF A(2,2J»A(3,3J THEN 1950 




1940 GO TO 1830 




1950 LET T1*A(2,2) 




1960 GO TO 1840 




1970 IF A(2,2)*AC1,3) THEN 1950 




I960 GO TO 1840 




1990 IF T1&gt;0 THEN 2030 




2000 PRINT " ,,,YOU WIN THIS TIME,,," 




2010 LET Z«l 




2020 GO TO 1850 




2030 PRINT " ... THE PDP*8 WINS THIS TIME .,,» 




2040 LET Z*2 




2050 GO TO 1850 




2060 REM END OF TEST WINNER PROGRAM,,,,,,, 




2070 PRINT "DO YOU WANT TO PLAY ANOTHER GAME: 


YESC1), 


2080 INPUT XI 




2090 IF XI * 1 THEN 250 




2100 IF XI ■ THEN 2130 




2110 PRINT "I SAID ONE OR ZEROS TRY AGAIN", 




2120 GO TO 2080 




2130 PRINT"IT»S BEEN FUN, COME AGAIN SOMETIME* 




2140 GO TO 2160 




2150 DATA 2,2,0,0,0,0,1,1,3,3,1,3,3,1,1,2,3,2, 


2,3,2,1 


2160 CHAIN "DEMON « 




2170 END 





NOC0)", 

