90 RANDOMIZE 

100 IF lot THEN 101 ELSE PRINT "MIDNIGHT DREARY"! 

101 IF I&lt;&gt;2 THEN 102 ELSE PRINT "PIREY EYES"! 

102 IF I&lt;&gt;3 THEN 103 ELSE PRINT "BIRD OR FIEND"! 

103 IF I&lt;&gt;4 THEN 104 ELSE PRINT "THING OF EVIL"! 

104 IF I&lt;&gt;5 THEN 210 ELSE PRINT "PHOPHET"! 

105 GOTO 210 

110 IF I&lt;&gt;1 THEN HI ELSE PRINT "BEGUILING ME"! 

111 IF I&lt;&gt;2 THEN 112 ELSE PRINT "THRILLED ME"! 

112 IF I&lt;&gt;3 THEN 113 ELSE PRINT "STILL SITTING. ., »\GOTO 212 

113 IF I&lt;&gt;4 THEN 114 ELSE PRINT "BURNED. "\GOTO 212 

114 IF I&lt;&gt;5 THEN 210 ELSE PRINT "NEVER FLITTING"! 

115 GOTO 210 

120 IF I&lt;&gt;1 THEN 121 ELSE IF U-0 THEN 210 ELSE PRINT 

121 IF I&lt;&gt;2 THEN 122 ELSE PRINT "AND MY SOUL"! 

122 IF I&lt;&gt;3 THEN 123 ELSE PRINT "DARKNESS THERE"! 

123 IF I&lt;&gt;4 THEN 124 ELSE PRINT "SHALL BE LIFTED"! 

124 IF I&lt;&gt;5 THEN 210 ELSE PRINT "QUOTH THE RAVEN"! 

125 GOTO 210 

130 IF I&lt;&gt;1 THEN 131 ELSE PRINT "NOTHING MORE"! 

131 IF I&lt;&gt;2 THEN 132 ELSE PRINT 

132 IF I&lt;&gt;3 THEN 133 ELSE PRINT 



SIGN OF PARTING"! 



133 IF I&lt;&gt;4 THEN 134 ELSE PRINT 



"YET AGAIN"! 
"SLOWLY CREEPING"! 
.NEVERMORE"! 



134 IF I&lt;&gt;5 THEN 210 ELSE PRINT "EVERMORE."! 

210 IF Us0 THEN 212 ELSE IF RND&gt;,19 THEN 212 ELSE PRINT ","|\U"2 

212 IF RND&gt;.65 THEN 214 ELSE PRINT " " ! VU«U+1\G0T0 215 

214 PRINT\U«0 

215 I«INT(5*RND*1) 
220 J«J+1\K»K+1 

230 IF U&gt;0 THEN 240 ELSE IF INTCJ/2)&lt;&gt;J/2 THEN 240 ELSE PRINT " 

240 ON J GOTO 100,110,120,130,250 

250 J*0\PRINT\IF K&gt;20 THEN 270 ELSE GOTO 215 

270 PRlNT\Us0VK«0VGOTO 110 

999 END 
