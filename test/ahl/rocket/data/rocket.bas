2 PRINT "THIS IS A COMPUTER SIMULATION OF AN APOLLO LUNAR" 

3 PRINT "LANDING CAPSULE, "SFRINTSPRINT 

4 PRINT "THE QN-BOARD COMPUTER HAS FAILED (IT WASN'T MADE BV" 

5 PRINT "DIGITAL) SO VOU HAVE TO LAND THE CAPSULE MANUALLY" 

6 PRINTSPRINT "SET BURN RATE OF RETRO ROCKETS TO ANY VALUE BETWEEN" 

7 PRINT "8 (FREE FALL) AND 200 (MAXIMUM BURN) POUNDS PER SECOND" 

8 PRINT "SET NEW BURN RATE EVERV 10 SECONDS. "SPRINT 

9 PRINT "CAPSULE WEIGHT 32,500 LBS; FUEL WEIGHT 16, 500 LBS" 
IB PRINTSPRINTSPRINT "GOOD LUCK ! ! ! " 

11 L = 

13 PRINTSPRINT "SEC", "MI + FT", "MPH", "LB FUEL".. "BURN RATE"SPRINT 

15 A*120SV=1SM=33000SN*16500SG*1E~3S2*1. 8 

21 PRINT L, INT(A); INT(5288*(A~INT(A))),3688*V,M~N,SINPUT KST«18 

31 IF M-N&lt;. 001 THEN 41SIF T&lt;. 001 THEN 21SS=TSIF M&gt;~N+S*K THEN 35 

32 5*&lt;M-N)/K 

35 GOSUB 91SIF I&lt;*0 THEN 71SIF V&lt;=0 THEN 38SIF J&lt;0 THEN SI 

38 GOSUB 61\G0TQ 31 

41 PRINT "FUEL OUT RT"L"SEC"S5=(~V+SQR( V*V+2*A*G) )/GSV-V+G*SSL*L+S 

51 W=3600*VSPRINT"ON MOON AT"L"SEC •&lt;• IMPACT VELOCITY" W "MPH" 

32 IF MM, 2 THEN 53SPRINT "PERFECT LANDING! (LUCKY) "SGOTO 95 

53 IF W&gt;10 THEN 56SPRINT "GOOD LANDING (COULD BE BETTER) "SGOTO 95 

56 IF W&gt;60 THEN 58 SPRINT "CRAFT DAMAGE YOU'RE STRANDED HERE UNTIL" 

57 PRINT "A RESCUE PARTY ARRIVES, HOPE VOU HAVE ENOUGH OXYGEN ! "SGOTO 95 

58 PRINT "SORRY, BUT THERE WERE NO SURVIVORS. ., VOU BLEW IT!" 

59 PRINT "IN FACT, YOU BLASTED A NEW LUNAR CRATER "W*. £777 "FT DEEP" 
68 GOTO 95 

61 L=?L + S\T=T»SSM'*M-S*KSA*ISV=.JSRETURN 

71 IF S&lt;5E-3 THEN 51SD=V+SQR(V*V+2*A*(G~2*K/M) )SS»2*A/D 

73 GOSUB 91SG0SUB 61SQ0T0 71 

81 W=&lt;l-M*G/&lt;2*K))/2SS*M*V/(2*K*(W+SGR(W*W+V/2&gt;&gt;&gt;+. 85SG0SUB 91 

83 IF I&lt;*0 THEN 71SG0SUB 61SIF J&gt;0 THEN 31SIF V&gt;0 THEN 81SG0T0 31 

91 G«S*K/MSJ=V+G*S+2*(-e-G*Q/2r.ij-:&lt;/2^G-4/4-G-5/5) 

94 I=A-G*S*S/2-V*S+Z*S*(e/2+Q^2/6+C!- , -3/12+i5*-4/20+i&gt;!-5/30)SRETURN 

95 PRINTSPRINTSPRINTSPRINT "TRV AGAIN??"SGOT0 6 
99 END 

