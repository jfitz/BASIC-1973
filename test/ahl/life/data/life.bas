1 REM LIFE CLARK BAKER 3/72 C.O.G. 

2 PRINT CHr$(31X)&gt;CHr$(29X)JCHrJC31X)|WENTER YOUR PATTERN!" 

3 XlX,YlX«i! X2X"24Xt Y2X"70X 
10 DIM AX(24X,70X),B$(24X) 

20 OPEN "KBi" AS FILE 1 

30 ON ERROR 60 TO 80 

40 CX«1 

50 INPUT LINE #1,B$(CX)IBSCCX)«LEFT(B$(CX)#LEN(B$(CX))»2X) 

60 CX"CX*1 

70 GO TO 60 

80 LX"0X 

90 FOR X%«1 TO CX*i 

100 IF LEN(B$(XX))&gt;LX THEN L%"LEN(B$(XX)) 

110 NEXT XX 

120 XlX"llX-Cx/2X 

130 YlX"33X«'LX/2X 

140 FOR XX«1 TO CX 

150 FOR YX»t TO LENCBS(XX)) 

160 IF MlDtBS(XX)#YX#l)«&gt;« '• THEN a*&lt;X1X*XX, YiX*YX)"l I PX»PX*1 

170 NEXT YX 

180 NEXT XX 

200 PRINT CHR$(29X)|CHR$(30%) I 

210 PRINT »GENE^RATION|' , |GX,«POPULATIONi«lPX&gt;eHR$(30X)llIF I9X THEN PRINT , "INVALID J "J 

215 X3%"24 x :Y3x«70xtX4x,Y4x«llPx«0X 

220 GX*GX+1% 

225 PRINT CHRS(13X)fCHRS(10X)ICHRS(30X)y FOR XX"1 To XlX'l 

230 FOR XX-X1X TO X2X 

240 PRINT 

250 FOR YX«YlX TO Y2X 

253 IF AX(XX#YX)«2X THEN AX(XX,YX)«0X|GO TO 270 

256 IF AX(XX,YX)«3X THEN AX (XX, YX) "i IGO TO 261 

260 IF AX(XX,YX)&lt;&gt;1 THEN 270 

261 PRINT TA8&lt;YX)»"# H I 

262 IF Xx&lt;X3x THEN X3x«X% 
264 IF X**X4X THEN x4X»x« 
266 IF YX&lt;Y3X t^EN y3X«YX 
268 IF YX&gt;Y4X THE N Y4X«YX 
270 NEXT YX 

280 PRINT CHRS(30X)I 

290 NEXT XX 

2g5 PRINT CHRSC30X) FOR XX«X2X*1 TO 24X 

298 PRINT CHRSC29X)! 

299 XlX«X3X|X2X«X4%lYiX«Y3X'lY2X«Y4% 
301 IF Xl X &lt;3x THEN X 1 X «3x 1 19%-- 1 % 
303 IF x2X&gt;22X THEN X 2X«22X \ I9x«-lX 
305 IF Y1X&lt;3X THEN YlX"3X* I9X--1X 
307 IF Y2X&gt;68X THEN Y2X"68X : I9X«-1X 
309 PX*0X . 

500 FOR XX.X1X-1 TO X2X*1 

510 FOR YX*Y1X«1 TO Y2X+1 

520 CX«0X 

530 FOR IX-XX-lX TO XX+1% 

540 FOR JX»YX»1X TO YX+1X 

550 IF AX(IX,JX)«1X OR AX(IX,JX)»2X THEN CX«CX+1X 

560 NEXT JX 

570 NEXT Ix 

580 IF AX(XX»Y%)"0X THEN 610 

590 IF CX&lt;3% OR CX&gt;4X THEN AX(XX,YX)"2X ELSE PX«PX+1 

600 GO TO 620 

610 IF CX*3X THEN AX(XX, YX) «3XIPX*PX+1 

620 NEXT YX 

630 NEXT XX 

635 XlX«XlX-liYtX»YlX-liX2X«X2X+llY2X«Y2X+l 

640 GO TO 210 

650 END 

