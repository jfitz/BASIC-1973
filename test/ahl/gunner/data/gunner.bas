10 REM *** MODIFIED AND CONVERTED TO RSTS/E BV DAVID AHL, DIGITAL 

90 RANDOMIZE 

10© PRINT "THIS COMPUTER DEMONSTRATION SIMULATES THE" 

110 PRINVRESULTS OF FIRING A FIELD ARTILLERY' WEAPON. " 

120 PRINT 

130 PR I NT "VOU ARE THE OFFICER-IN-CHARGE, GIVING ORDERS TO THE GUN" 

140 PR I NT "CREW, TELLING THEM THE DEGREES OF ELEVATION VOU ESTIMATE" 

150 PRINT"WILL PLACE THE PROJECTILE ON TARGET. A HIT WITHIN LQQ VARDS" 

160 PRINT "OF THE TARGET WILL DESTROV IT. TAKE MORE THAN 5 SHOTS," 

170 PRINT "AND THE ENEMV WILL DESTROV VOU! "SPRINT 

180 PR I NT "MAX I MUM RANGE OF VOUR GUN IS 46509 VARDS. " 

1:35 2=0 

190 PRINT 

1.95 S1=0 

200 LET T=43000^30000*RND&lt;:X&gt; 

210 LET S=0 

220 GO TO 270 

230 PRINT-MINIMUM ELEVATION OF GUN IS ONE DEGREE. " 

240 GO TO 290 

250 PR I NT "MAX I MUM ELEVATION OF GUN IS 89 DEGREES. " 

260 GO TO 399 

270 PR I NT "OVER TARGET BV"; ABS&lt;E&gt;; "VARDS. " 

280 GO TO 290 

290 PRINT "SHORT OF TARGET BV"; ABS&lt;E&gt;; "VARDS. " 

200 GO TO 290 

210 GO TO 220 

220 PRINT"***TARGET DESTROVED*** "; S; "ROUNDS OF AMMUNITION EXPENDED" 

222 GOSUB 600 

225 S1=S1+S 

220 IF 2=4 THEN 49© 

240 2=2+1 

245 PRINT 

250 PRINT"THE FORWARD OBSERVER HAS SIGHTED MORE ENEMV ACTIVITV. " 

260 GO TO 200 

270 PRINT" DISTANCE TO THE TARGET IS"; INT&lt;:T&gt;; "VARDS " 

280 PRINT 

290 PRINT 

400 PR I NT "ELEVATION: "; 

410 INPUT B 

420 IF BI&gt;89 THEN 250 

430 IF B&lt;1 THEN 226 

440 LET S=S+1 

442 IF S&lt;6 THEN 450 

444 PRINTSPRINT "BOOM ! ! ! VOU HAVE JUST BEEN DESTROVED "; 

445 GOSUB 600 

446 PRINT "BV THE ENEMV"\PRINTSPRINT\G0T0 495 

450 LET B2=2*B/57. 2SLET I=46500*SIN&lt;.B2&gt;\LET X=T-I\LET E=INTOO 
460 IF ABS&lt;E)&lt;100 THEN 210 
470 IF E&gt;100 THEN 290 
480 IF E&lt;-100 THEN 270 

490 PRINT\PRINT\PRINT "TOTAL ROUNDS EXPENDED WERE"; SI 
. 491 IF Sl&gt;15 THEN 495SPRINT "NICE SHOOTING ! ! "SGOSUB 60OSGOTO 500 
495 PRINT "BETTER GO BACK TO FORT SILL FOR REFRESHER TRAINING! " 
500 PRINTSPRINT "THANK VOU FOR PLAVING!" 

505 PRINTSPRINT "TRV AGAIN "\PRINT\GOTO 180 

600 FOR N=l TO 10SPRINT CHR*&lt;!7&gt;; \NEXT N 
610 RETURN 
999 END 
