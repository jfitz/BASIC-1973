2 PRINT "I, YOUR FRIENDLY EDUSYSTEM COMPUTER, WILL DETERMINE"
3 PRINT "THE CORRECT CHANGE FOR ITEMS COSTING UP TO $100."
4 PRINT\PRINT
10 PRINT "COST OF ITEM";\INPUT A\PRINT "AMOUNT OF PAYMENT";\INPUT P
20 C=P-A\M=C\IF C<>0 THEN 90\PRINT "CORRECT AMOUNT, THANK YOU"
30 GO TO 10
90 IF C>0 THEN 120 \PRINT "SORRY, YOU HAVE SHORT CHANGED ME $";A-P
100 GO TO 10
120 PRINT "YOUR CHANGE, $";C\D=INT(C/10)\IF D=0 THEN 155
150 PRINT D;"TEN DOLLAR BILL(S)"
155 C=M-(D*10)\E=INT(C/5)\IF E=0 THEN 185
180 PRINT E;"FIVE DOLLAR BILL(S)"
185 C=M-(D*10+E*5)\F=INT(C)\IF F=0 THEN 215
210 PRINT F;"ONE DOLLAR BILL(S)"
215 C=M-(D*10+E*5+F)\C=C*100\N=C\G=INT(C/50)\IF G=0 THEN 255
250 PRINT G;"ONE-HALF DOLLAR(S)"
255 C=N-(G*50)\H=INT(C/25)\IF H=0 THEN 285
280 PRINT H;"QUARTER(S)"
285 C=N-(G*50+H*25)\I=INT(C/10)\IF I=0 THEN 315
310 PRINT I;"DIME(S)"
315 C=N-(G*50+H*25+I*10)\J=INT(C/5)\IF J=0 THEN 345
340 PRINT J;"NICKEL(S)"
345 C=N-(G*50+H*25+I*10+J*5)\K=INT(C+.5)\IF K=0 THEN 380
370 PRINT K;"PENNY(S)"
380 PRINT "THANK YOU,COME AGAIN"\PRINT \PRINT \GO TO 10
999 END

