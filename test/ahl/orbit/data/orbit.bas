5 RANDOMIZE
10 PRINT "SOMEWHERE ABOVE YOUR PLANET IS A ROMULAN SHIP."
15 PRINT
20 PRINT "THIS SHlP IS IN A CONSTANT POLAR ORBIT. IT'S"
25 PRINT "DISTANCE FROM THE CENTER OF YOUR PLANET IS FROM"
30 PRINT "10,000 TO 30,000 MILES AND AT IT'S PRESENT VELOCITY CAN"
31 PRINT "CIRCLE YOUR PLANET ONCE EVERY 12 TO 36 HOURS."
35 PRINT
40 PRINT "UNFORTUNATELY THEY ARE USING A CLOAKING DEVICE SO"
45 PRINT "YOU ARE UNABLE TO SEE THEM, BUT WITH A SPECIAL"
50 PRINT "INSTRUMENT YOU CAN TELL HOW NEAR THEIR SHIP YOUR"
55 PRINT "PHOTON BOMB EXPLODED. YOU HAVE SEVEN HOURS UNTIL THEY"
60 PRINT "HAVE BUILT UP SUFFICIENT POWER IN ORDER TO ESCAPE"
65 PRINT "YOUR PLANET'S GRAVITY."
70 PRINT
75 PRINT "YOUR PLANET HAS ENOUGH POWER TO FIRE ONE BOMB AN HOUR."
80 PRINT
85 PRINT "AT THE BEGINNING OF EACH HOUR YOU WILL BE ASKED TO GIVE AN"
90 PRINT "ANGLE (BETWEEN AND 360) AND A DISTANCE IN UNITS OF"
95 PRINT "100 MILES (BETWEEN 100 AND 300), AFTERWHICH YOUR BOMB'S"
100 PRINT "DISTANCE FROM THE ENEMY SHIP WILL BE GIVEN."
105 PRINT
110 PRINT "AN EXPLOSION WITHIN 5,000 MILES OF THE ROMULAN SHIP"
111 PRINT "WILL DESTROY IT."
114 PRINT
115 PRINT "BELOW IS A DIAGRAM TO HELP YOU VISUALIZE YOUR FLIGHT"
116 PRINT
117 PRINT
168 PRINT "                           90"
169 PRINT "                           '"
170 PRINT "                     0000000000000"
171 PRINT "                  0000000000000000000"
172 PRINT "                000000           000000"
173 PRINT "              00000                 00000"
174 PRINT "             00000    XXXXXXXXXXX    00000"
175 PRINT "            0000    XXXXXXXXXXXXXXX    0000"
176 PRINT "           0000    XXXXXXXXXXXXXXXXX    0000"
177 PRINT "          0000    XXXXXXXXXXXXXXXXXXX    0000"
178 PRINT "         0000    XXXXXXXXXXXXXXXXXXXXX    0000"
179 PRINT "180 <== 00000    XXXXXXXXXXXXXXXXXXXXX    00000 ==> 0"
180 PRINT "         0000    XXXXXXXXXXXXXXXXXXXXX    0000"
181 PRINT "          0000    XXXXXXXXXXXXXXXXXXX    0000"
182 PRINT "           0000    XXXXXXXXXXXXXXXXX    0000"
183 PRINT "            0000    XXXXXXXXXXXXXXX    0000"
184 PRINT "             00000    XXXXXXXXXXX    00000"
185 PRINT "              00000                 00000"
186 PRINT "                000000           000000"
187 PRINT "                  0000000000000000000"
188 PRINT "                     0000000000000"
189 PRINT "                           '"
190 PRINT "                          270"
191 PRINT
192 PRINT
195 PRINT "X - YOUR PLANET"
196 PRINT "O - THE ORBIT OF THE ROMULAN SHIP"
197 PRINT
198 PRINT "ON THE ABOVE DIAGRAM, THE ROMULAN SHIP IS CIRCLING"
199 PRINT "COUNTERCLOCKWISE AROUND YOUR PLANET. DON'T FORGET"
200 PRINT "WITHOUT SUFFICENT POWER THE ROMULAN SHIPS ALTITUDE"
201 PRINT "AND  ORBITAL RATE WILL REMAIN CONSTANT"
203 PRINT
204 PRINT "GOOD LUCK. THE FEDERATION IS COUNTING ON YOU."
270 LET A=INT(RND*360)
280 LET D=INT(RND*200) +100
290 LET R=INT(RND*20) +10
300 LET H=0
310 IF H=7 GOTO 490
320 LET H=H+1
325 PRINT
326 PRINT
330 PRINT "HOUR";H;", AT WHAT ANGLE DO YOU WISH TO SEND"
335 PRINT "YOUR PHOTON BOMB?"
340 INPUT A1
350 PRINT "HOW FAR OUT DO YOU WISH TO DETONATE IT?"
360 INPUT D1
365 PRINT
366 PRINT
370 LET A=A+R
380 IF A<360 GOTO 400
390 LET A=A-360
400 LET T=ABS(A-A1)
410 IF T<180 GOTO 430
420 LET T=360-T
430 LET C=SQR(D*D+D1*D1-2*D*D1*COS(T*3.14159/180))
440 PRINT "YOUR PHOTON BOMB EXPLODED";C;"*10^2 MILES FROM THE"
445 PRINT "THE ROMULAN SHIP"
450 IF C<50 GOTO 470
460 GOTO 310
470 PRINT "YOU HAVE SUCCESSFULLY COMPLETED YOUR MISSION."
480 GOTO 500
490 PRINT "YOU HAVE ALLOWED THE ROMULANS TO ESCAPE."
500 PRINT "ANOTHER ROMULAN SHIP HAS GONE INTO ORBIT."
510 PRINT "DO YOU WISH TO TRY TO DESTROY IT?"
520 INPUT C$
530 IF C$="YES" GOTO 270
540 PRINT "PLEASE LOGOUT"
999 END