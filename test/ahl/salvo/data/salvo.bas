1000 REM *** SALVO BY LARRY SIEGEL 

1010 REM *** LAST REVISION 6/9/73 

1020 REM *** CHECKED OUT ON RSTS/E BY DAVE AHL, DIGITAL 

1030 REM *** 

1040DIMA(10,10),BC10,10),CC7),D&lt;7),E(12),F(12),6ci2),HCi2),KC10,10) 

1050LETZ8«0 

1060FORM1TO12 

1070LET£(wD»-l 

1080LEtH(W)«-l 

109&amp;NEXTN 

1100FQRX«1TO10 

1110FORY«lTQ10 

1120L£TB(x#Y)«0 

1130NEXTY 

1140NEXTX 

1150FORXalTO12 

li60LETF(X)*0 

1170LETG(X)«0 

1180NEXTX 

1190FORX*1TO10 

120BFORY»1TO10 

1210LETA(X#Y)*0 

1220NEXTY 

1230NEXTX 

t240FORK«4TOlSTEP-l 

1250LETU6=0 

1260GO3UB2913 

1270DEFFNA(Kj»t&amp;-K)*3*2*lNT(K/4)+SGN(K-l)*.i 

1260DtFFMBCKJ*K*INT(K/4)-3GN(K-l) 

1290IFV+V2+V*V2s0THEn1260 

1300IFY+V*FN8CK)&gt;10THEN1260 

1310IFY+v*FmB(K)&lt;1TmEn1260 

1320lFX*V2*KNd(K)&gt;10THEMia6a 

1330IF X + v2*j-^8(K)&lt;lTHEfvl260 

1340LETU6«U6+1 

1350lPU6&gt;25THEMi90 

1360FORZ»«TOFNB(K) 

137WLETF(Z*FnA(k))«X*v2*2 

l380LETG(Z+FNA(K))«Y+V*Z 

1390NfcXTZ 

1400LETU8«FNA(K) 

1410FORz2sy8TOu8 + t i N3(K) 

1420FORZ3*lTOu8-! 

1430 USQ»(CF(Z3)-F(Z2))a2+(GCZ3)-GCZ2))a2)&lt;3,S9TMEN 1260 

1440NEXTZ3 

1450NEXTZ2 

1460FOHZ«0TOFNB(K) 

1470LETA(F(Z*U8) f G(Z+U8))«.8+3GN(K-1)*(K-1,5) 

1480NEXTZ 

1490NEXTK 

1500PRlNT»EMt»* COORDINATES FOR..." 

1510PRlN7'»8ATTLESHlP» 

1520FORXS1TO5 

1530InPUTY,Z 

lS40LETb(Y#Z)»J 

l&amp;5BNfc-XfX 

1560PRINT"CRUISER" 

1570FORX«lTO3 

1S80IMPUTY.Z 

1590LET9(y,Z)«2 

1600NEXTX 

1610P«IiMT"DeSTROYtW&lt;A&gt;" 

1620FORX»1TO2 

lb30lNPUTY,Z 

lb40LET6(y,z)»l 

1650NEXTX 

1660PRlNT"DfeSTRCYER&lt;8&gt;» 

1670FORX*1TO2 

1680INPUTY,Z 

1690LET8(Y,Z)*.b 

1700NEXTX 

17i0PRIM"Du YOU *AMT TO START"; 

1720IN.PUTJ5 

173-0IFJ$O"wHE«E ARt YOUR SHIPS?"THEN1890 

174(flPRlNT«eATTLfc3hIP" 

1750FORZ»lTOb 

1760PRINTF(Z)&gt;G(Z) 

1770NEXTZ 

1780PRI.mT"CkhJ.Sc.R" 

1790PRIMF(61?G(6) 

1800PRINTF(7) JG(7) 

1810PKINTK8);G(8) 

1320PRI^T"DESTRGYER&lt;A&gt;" 

1B30P«IMK9)|G(9) 

1840PRlNTF(l0)?b(i0) 

1850PRlNT«Dt"ST«OYER&lt;B&gt;" 

1860PRlMTF(in ?G(li) 

i870PRlNTF(12)|&amp;(12) 

1880GOTO171W 

1890LETC»u 

1900PRlNT» , OQ YOU *AnT TQ SEE MY SHOTS"! 

1910INPUTKS 

1920PRIMT 

l930IFJS&lt;&gt;»YtS"THEN262^ 

1940REM*** ******** ***ST APT 

195MlFj*o»YES"THEMi99^ 

1960LETCaC+l 

1970PR1NT 

1980P«INT"TURN»C 

1990LETASS5 

2000FoR«*,5TO33TEP,5 

2010FORXS1TO10 

2020FORY«1TO10 * 

2030lF8(X # Y)«wTHEN2070 

2040NEXTY 

205MNEXTX 

2060GOTO2-08B 

2070LETA»A+lNT(^+,5) 

2080NEXTW 

2090FORw«lTO7 

2100LETC(:O«0 

2ll0LETO(w).0 

2120LETF(w)s^ 

2130LETG(W)»0 

2140NEXT* 

2150LETP3«P 

2160FORX«1T010 

2170FORYMTO10 



2180IFACX,Y)&gt;10THEN2200 
2190LETP3«P3+1 
2200NEXTY 
2210NEXTX 

2220PRINT»YOU HAVE" A"SHOTS» 
2230IFP3&gt;«ATHEN2260 

2240PRINT»THE NUMBER OF YOUR SHOTS EXCEEDS THE NUMBER OF BLANK SQUARES" 
2250GQTQ2890 
2260IFA&lt;&gt;0THEn2290 
2270PRINT M I HAVE *ON" 
2280STOP 
2290FORW«1TOA 
2300InPUTX,Y 
2310IFX&lt;&gt;INT(X)THEN2376J 
2320lFX&gt;l0ThEN2374 
2330IFX&lt;1THEN2370 
2340IFY&lt;&gt;INT(Y)THEN2370 
2350IFY&gt;10THEN2370 
2360lFY&gt;*iThEN2390 
2370PRINT"ILLEGAL» EMTER AGAIN" 
2380GOTO2300 
2390IFA(X,Y)&gt;10THEN2440 
240BLETC (*.)«* 
2410LETD(*)«Y 
2420NEXTW 
2430GOTO2460 

2440PRlNT"YOu SHOT THERE BEFORE ON TURN" A ( X, Y) «*10 
2450GOTO2300 
2460FORW«1TOA 

2470IFA(C(W),D(^))«3THEN2b40 
248aiFA(C(W)fD(*))»2TriEN256lJ 
2490iFA(Cfw),D(^))«lTHEN2580 
2500IFACC(W),D(iO)*,5THEN2600 
2510LETA(CCw)#D(&lt;«i))»10 + C 
.2520NiEXTw 
2530GOTO262W 

2540PRINT»YOU HIT *Y BATTLESHIP" 
2b50GOTO26i0 

2S60PRlN'T"YOU HIT MY CRUlsER" 
2570GOTO2510 

2b80PRINT H YQU HIT MY DESTROYER&lt;A&gt;» 
2b90GOT'O2bl0 

2600PRINT"YOU HIT MY DESTRQYER&lt;6&gt;" 
2610GOTO2510 
2620LETA»0 

263^IFJ$b«yES ,, ThEN2670 
2640L£TC»C+1 
2650PRINT 
2660PRINT"TUPN"C 
2670LETAS0 

2680FoRW".bTO3 t lSTEp,5 
2690FORXMTui0 
2700F0RY«1TO1'2 
2710IFACX, Y)«WTHEN2750 
2720NEXTY 
2730NEXTX 
2740GOTO2760 
2750LtTA«A+INTCw*,5) 
2760NEXT* 
2770LETP380 
2780FQRXS1TQ10 
2790FORY«ITO10 
2800IFB(X,Y)&gt;l^THEN2820 
2810LETP3*^J+1 
2820NEXTY 
2830NEXTX 

2840PRINT"! HAVF.»'A«SHOTS" 
2850IFPJ&gt;ATHEN2880 

2860PRINT»THE NyMBER OF MY SHOTS EXCEEDS THE NUMBER QF BLANK SQUARES" 
2870G0TQ2270 
2880IFAO0THEN2960 
2890PHIM"YOU HAVE wOn" 
2930STOP 

291BLETX»IMT((RND'(-n*10)*l) 
2920LETY«INT((RNDC-l)*10)*l) 
2930LETV»INTC3*RND(-1)-1) 
2940LETV2»lNTf3*RNO(-l)-l) 
295WKETURN 
2960FORw«iTO12 . 
2970lFH(w)&gt;0THtN380t* 
2980NEXTW 

2990RtM**************RANOQM 
300i3LETw*0 
3010LETR3.0 
3020GOSU82910 
3030RESTORE 
3040LETR2»0 
3050LETR3«R3+i 
306HlFR3&gt;103THEfs3010 
3070lFX&gt;10ThtN3ll^ 
3080IFX&gt;0THE^3120 
3090LETXsl*lsiT C«ND(-l)*2.b) 
3100GOTO3120 

3110LETXsl0-lNT(RNO(-l)*2,5) 
3l20lFY&gt;10THEN3l6a 
3130lFY&gt;0THtN3270 
3140LETY*l+INTCRNO(-l)*2.b) 
3150GQ-TO3270 

3160LETY*10-INJT(RNOC-I)*2,b) 
3170GQTO3270 
3180LETF(vOax 
3l90LETG(wl»Y 
3200IFWsATHEN3380 
3210IFR2«6THfcN3030 
3220READX1, Yl 
323tfLETR2«R2+l 

3240OATAl # l,-l,i,lf-3,l,l,0,2 f -l,l 
3250LETX*X+X1 
3260LETY«Y*Y1 
3270IFX&gt;10THEN3210 
3280lFX&lt;lTHEN32i0 
3290IFY&gt;10THEn3210 
3300IFY&lt;1THEN3210 
331«IFB(X,Y)&gt;10ThEN3210 
3320FORQ9»1TOW 
3330IFF(Q9)oxTHEN3350 
3340IFG(Q9)*YTHEN321^ 
3350NEXTQ9 



194 



10 
9 



3360LfcTMW*l 
3370GOTO3180 
3380lFK$o»YES»THtN3420 

3390FORZ5-1TQA 

3400PRINTF(Z5)&gt;6(ZSJ 

3410NEXTZ5 

3420FORW«1TOA 

3430IF8(F(w),G(w5)»3THEN35ia0 
3440IF8CF(W),G(W))»2THEN3S20 
3450lF'e(F(wj,G(W})«iTHEM35tt* 
3460lFB(F(W),G(^))«.bTHEN3540 
3470LETB(F(w),G(w))«10+C 
3480NEXTW 
3490GQTO19S0 

3500PRINT»I HIT YOUR BATTLESHIP" 
3510GOTU3570 

3b20PRINT"I HIT YOUR CRUISER" 
3530GOTO3570 

3540P«INT"I HIT YOUR DESTROYER&lt;B&gt;« 
3550GQTO3570 

3560PRINT''I HIT Y U R DEST«OYER&lt;A&gt;" 
3b70FOR«siTO12 
3580IFE(U)&lt;&gt;-1THEN3730 
3590LETE(Q)»10+C 
360BLtTH(Q)«8cFCW),G(»)J 
3610LETWI3B0 
3620FORM2»1TO12 
3630IFHCH2)&lt;&gt;HCO)THtN36b0 
3640M3*M3+1 
3650NEXTM2 

3560IFM3&lt;&gt;INTCH(Qj4..5) + i*iNT(IWT(H(Q)*.5)/3)THEN3470 
3670FO»M2*iTQl2 
3680IFH(M2)&lt;&gt;H(Q)THEN3710 
3690LETE(M2)*-1 
3700LETM(M2)»-1 
3710NEXTM2 
3720GOTO3470 
3730NEXTQ 

3740PRINT»PROG»AM ABORT:" 
3750FORUB1TO12 
3760PftlNT"E("Q H )« H E(Q&gt; 
3770PRlNT"H( ,, Q ,, )«"H(Q) 
3780NEXTQ 
3790STOP 

3800HEM**************IJSINiGEARRAY 
33i0FORR«lTOl^ 
3820FORSsiTO12 
3830tET*C«,S)»0 
3840NEXTS 
385MEXTR 
3860FORU*1TO12 
3370IFE(U)&lt;i r ^THtN4020 
3880FQRRslTQ10 
3890FORS"! TOl^ 
3900IFBCR,S)&lt;U5THEN3930 
39l0LETK(R,S)B-i0»0iif-10 
3920GQTO4tfi,-K&lt;* 

393.0FOHMisGN(l*R)TOS-G.&gt;i(ia«R) 
3940FORM«sGN(l*s) TOSGn(IM-S) 
3950IP N + M + N*Hav)THEN39«0 
3960IFB(R + ,i,3 + N)&lt;&gt;E(U)THEn3980 
3970LETn(K,S)«K(R,S)*E(u)-2*IimT(h('.J)*.5J 
3980NEXTN 
3990NEXTM 
4000NEXTS 
4010NEXTR 
4023NEXTU 
4030F-'ORR*1TOA 
4040LETFfR)»R 
■4050|.ETG(R') 8 R 
4060NEXTR 
4070FORH«1TO10 
4080FORS«1TO10 
4090LETQ9sl 
4100FORM«1TOA 

4il0lFK(Fc-M),G(M))-&gt;»K(F(a9i#GC-O9))THEN4l3a 
4120LETQ9*M 
4130NEXTM 

4131 IF R&gt;ATHEM140 

4132 IF R»S ThEm 4210 
4i40IFKCR,S)&lt;KCF(Q9)fG(O9))THEN4210 
4150FQRMS1TOA 
4160IFF(H)&lt;&gt;RTHEN4190 
4170IFG(M).STHEN4210 

4180NEXTM 

4190LETF(Q9)«R 

4200LETGCQ9)»S 

4210NEXTS 

4220NEXTR 

4230GOTO3380 

4240END 

