TDIMA~(15),Bn6, 
2DEFFNA(X)"INT(10*RND(X), 
TDl F f Nl ( X) ■ X • 1 00 * I N f ( X / 1 ) 

4PRINT"WELC0ME TO THE HAUDEN CASINO. WE EACH HAVE $200* 
5PRINT"! WILL OPEN THE BETTING TEP~ORE~TH£ "DRAWir YOTTOPfN~AFTE^ 
^PRINT"WHEN YOU FOLD, BET 0) TO CHECK, BET ,5» 
7PRINT»ENOUGH TALK — LET'S GET DOWN TO BUSINESS" 
SPRINT 
9LET0M 
10LETC"200 

i2LETP*0 

ISRANDOM 

UPRINT 

i5TFC&lt;"STHEN367 

16FRINT "THF ANTE IS S5. I WILL DEAL" 

17PRINT 

t8IF8»5THEN20 

f9GOSUB383 

2_0LETP»P*10 

2lLETS«S-5 

22LETC»C»S 

23FQRZ*ITO10 

24G0SUB174 

2SNEXTZ 

26PRINT"Y0UR HANDl" 

27LETN-1 

28G08UB185 

29LETN»6 

30LETI-2 

31G0SUB217 

32PRINT 

33IFI«&gt;6THEN47 

34IFFNA(0)&lt;»7 THEN37 

35LETX*ill00 

36G0T042 

37IFFNA(0)&lt;«7THEN40 

38LETXM1110 

39G0T042 

40iffna ( ) &gt;■ 1 t he n 4 5 
4iletx"THi; 

42LETI-7 
43LETZ-23 
44G0T058 
45LETZ«1 
46G0T051 
47IFU&gt;»13THEN54 
48IFFNAC0)&gt;«2THEN50 
49G0T042 
50LETZ»0 
51LETK»0 

52PRI_NT"I CHECK" 
53G0T062 
54IFU&lt;»i6THEN57 
5SLETZ-2 

56IFFNA(0)&gt;«1THEN58 
57LETZ»35 
S8LETV"Z*FNA(0) 
59G0SUB348 

60PRINT»I»LL OPEN WITH "V 
61LETMV 
62GOSUB305 
63G0SUB65 
64G0T082 
65IFI03THEN76 
66PRINT 

67PRINT"I WIN" 
68LETC«C*P 

69PRINT M N0W I HAVE $»C«AND YOU HAVE $»S 
70PRINT«DO YOU WISH J"Q CONTINUE"! 
TTlNPUTHi 
72IFH$«»YES"THEN12 
73iFHS»«NO«THEN410 
74PRINT»'AN3WER YES OR NO, IDIOT" 
75GOTO70 
76IFKMTHEN81 
77PRINT 

78PRINT"Y0U WIN" 
79LEtS«S+P 
80GOTO69 
SlRETURN 
82PRINT 

8 3 P R I NT ,r N"OW W E WA W -• • HOW MANY CARDS SO YOU *ANT«f 
84INPUTT 
85IFT«0THEN98 
86LETZ«10 
87IFT«4THEN90 

88PRIN T"Y0U CAN'T DRAW MORE THAN THRE P CARDS" 
S9G0f0ff4 

90PRINT"WHAT ARE THEIR NUMBERS" 
9 IFOR Q"iTOT 
92INPUTU 
93G0SUB173 
94NEXTQ _ 
95PRINT" YOUR NE W ""HANOI " 
96LETN»i 
97G0SUB165 
98LETZ"10+T 
99FORU-6TO10 

100IFINTCX/10A(U-6))&lt;&gt;10*INT(X/10A(u-5nTHEN102 
I01GOSUBT73 
102NEXTU 
T03PRINT 

104PRINT"! AM TAKING»Z»i0-T"CARD«| 
t05lFZ»ll*TTHENl09 
106PRINT' 'S" 
107PRINT" 
108GOTOH0 
109PPINT 
110LETN«6 
111LETV»I 
112LETI«1 

IULETBpu 
TiSjJETM-D 
il6IFV&lt;»7THEN119 
ii7LETZ»28 
U8G0T0133 
lT9lTr&lt;&gt;6THlNf22 
120LETZM 
121G0T0133 
122IFU&gt;»13THEN127 



l23LETZi2 

124IFFNA( 0)&lt;»6THEN126 
l25LETZif9 
126G0T0133 
1 27 1 FU&gt;" 16 THEN 132 
128LETZ«19 

12 9 IF F N A ( ) 08THEN131 
130LETZM1 
131G0T0133 
132LETZ"2 
133LETM0 
13_4GOSUB305 
i36IFT&lt;&gt;.5THEN146 
136IFV»7THEN140 
137IFIO6THEN140 
_1_38PRINT"I«LL CHECK" 
139G0T0146 
140LETV«Z*FNA(0) 
141G0SUB348 
142PR INT"I'LL BET"V 



143LETK»V 
J44GOSUB306 
14SG0SUB65 
J_46PRINT 

147PRINT«N0W WE COMPARE HANDS" 
148LETJf HS 
149LETK$«I$ 
JJ50PRINT«MY HANDl" 
151LETNB6 
J52G0SUBJ85 
153LETN»i 
154G03UB21 7 
1S5PRINT 

156PRINT"Y0U HAVE «&gt; 
157LETK«D 
158G0SUB369 
169LETH$»J$ 
160LET I$«KS 
161LETK«M 

162PRINT»AND I HAVE «| 
163G0SUB369 
164IFB»UTHEN67 
165IFU&gt;BTHEN78 
166IF HS»" A FLU3»THEN170 
" 167PR"INT"THE HAND IS" DRA WN« 
168PRINT"ALL $"P« REMAIN IN THE POT" 
169G0T014 

170IFFNB(M)&gt;FNB(D)THEN67 
171IFFNB(0)&gt;FNB(M)THEN78 
172 G0T0 167 
173LETZPZ+1 

174LETA(Z)«INTC1000*RND(0)) 
175IFINT(A(Z)/100)&gt;3THEN174 
176IFACZ)-100*INT(A{Z)/100)&gt;12THEN174 
177FORK»1TOZ-1 
178I FA(Z)»A(K)THEN174 
"T79NEXTK" 
180IFZ&lt;»10THEN184 
181LETN«A(U) 
182LETA(U)«A(Z) 
183LETACZ)*N 
184RETURN 
TMF0RZ«NT0~N*4 
186PRINTZ"— «&gt; 
187G0SUB195 
188PRINT" OF"; 
189GOSUB207 

190IFZ/2&lt;&gt;lNT(Z/2)THENi92 
T^IPRINT "'" 
192NEXTZ 
193PRINT 
194RETURN 
195LETK»FNBCA(Z)) 
196IFK09THEN196 
197PRINT"JACK«I 
198IFKO10THEN200 
199PRINT«QUEEN«J 
200IFK&lt;»liTHEN202 
201PRINT«KING«| 
20 2IFKQ 12THEN204 
T0TPPI¥T""TC : E " I 
204IFK&gt;»9THEN206 
205PRINTK+2I 
206RETURN 

207LETK»INT(A(Z)/100) 
208IFKQ0THE N21 
209PRINT T ' CLUBS", 
210IFKO1THEN212 
211PRINT" DIAMONDS", 
212IFK02THEN214 
213PRINT" HEARTS", 
214IFK Q3THEN216 
215PRINT« SPADTS", 
216RETURN 
217LETU-0 
2i8F0RZ"NT0N*4 
219LETB(Z)»FNBCA(Z)) 

220IFZ»N*4THEN223 _ 

221IFINT(ATZT/ 100) &lt;&gt;TnT(X(I* i ) /T00") THE N223 

222LETU"U+1 

223NEXTZ 

224IFU&lt;&gt;4THEN231 

225LETX»11111 

226LET D ■ AJJY 5 

227LETH$««A FLUS" 

228LETI$«»H IN" 

229LETU"15 

230RETURN 

231F0RZ"NT0N*3 

232F0RK«Z*iT0N*4 

2T31TBTn «~iBTKl THFN239 

234LETX*A(Z) 

235LrTA(z)«A(K) 

236LEtB(Z)»B(K) 



237lETA(K)bX 

238LETB(K)tA(K)-100*lNT(A(K)/100&gt; 

239NEXTI 

240NEXTZ 

241LETX»0 

242F0RZ*NT0N*3 

2 43 IF B (I) * &gt; B ( Z * 1 7 T H E N 2 4 7 

244LETXiX» lU10A(Z»N) 

246LETD«A(Z) 
J46G08UB276 

247NEXTZ 

248IFXO0THEN262 
"249lFB(N)*3&lt;&gt;B(N*3)THEN252 

2 50LETX«111 1 

2^1LETU«10" 

2S2IFB(N4.1)4-3«&gt;B(N*4)THEN262 
~283IFUO10THEN260 

254LETUiil4 

2SSLETH$»»8TRAIG» 

2|6J-ETIS«^HT^ 

287LETX*11111 
JS8LETD«A(N*4) 

289RETURN 

260LETU-10 

261LETX-11U0 

262IFU&gt;«10THEN269 

263LETD»A(N*4) 

264LETHS»«SCHMAL" 

265LETI$»"TZ, " 

266UTU»9 

267LETX* 11000 

268G0T0274 

269IFU«&gt;10THEN272 
^2701FIilTHEN274 

271G0T027S 

272IFU&gt;12THEN275 

273IFFNB(D)»6THEN275 

274LETIP6 

275RETURN 

276IFU&gt;*11THEN281 

277LETU«U 

278LETH$-"A PAIR" 

279LETI$«« OF » 

280RETU RN 

281IFU&lt;MfTHEN291 

282IFB(Z)&lt;&gt;BCZ-1)THEN287 

283LETHS»"THREE" 

284LETI$»" » 

28SLETU-13. 

286RETURN 

287LETH$«"TW0 P"« 

288LETI$»»AIR, « 

289LETU»12 

290RETURN 

291IFU012THEN296 

292LETU*16 

293LETHSi"FULL H« 

294LETI$«"0USE, » 

295RETURN 

296IFB(Z)«&gt;BCZ»1)THEN301 

297LETU«17 

298LETH$»"F0UR« 

T99LETI«inn~" 

300RETURN 

301LETUH6 

302LETH$«"FULL H" 

303LETI$»«OUSE, » 

304RETU RN 

305LETGP0 

306PRINT«WHAT IS YOUR 8ET«I 

307INPUTT 

308IFT«INT(T)«0THEN314 

309IFKO0THEN312 

3^0IFG&lt;»0THEN312 

1 ITITT ■ ,~5T"H EN 341 

312PRINT«N0 SMALL CHANGE, PLEASE" 

313GOTO306 

314IFS«G-T&gt;*0THEN317 

31SG08UB383 

3166OTO306 
"3TriTT«&gt;0THEN320 

318LETI"3 

319G0T0338 

320IFG*T&gt;«KTHEN323 

321PRINT«IF YOU CAN'T SEE MY BET, THEN FOLD" 

322GOTO306 

323LETG*G*T " 

324IFG*KTHEN338 

32BIFZ01THEN342 

326IFG&gt;5THEN330 

327IFZ&gt;"2THEN335 

328LETV-5 

329G0T0342 

330IFZi»lTHEN332 

33ilFT&lt;825THEN335 

332LETI»4 

333PRINT«I FOLD" 

334RETURN 

335IFZ»2THEN343 

336PRINT M I'LL SEE YOU" 

337LETK«G 

338LETS»S«G 

"339LETC*C»K 

340LETP «P*G*K 

341RETURN 

342IFG&gt;3*ZTHEN33S 

343LETV«G-»K*FNAC0) 

344G0SUB348 

348PRINT»I'LL SEE YOU, AND RAISE Y0U'»V 

346LETK»G *V 

347GOTO306" 

348IFC-G-V&gt;"0THEN366 

349IFGO0THEN352 

3B0LETV-C 



173 



351RETURN 

162IFC»G&gt;«0THEN336 

J53XFO/2&lt;»INT(O/2)THEN360 

384PRINT_«W0ULD YOU LIKE, TO BUY BACK YOUR WATCH FOR $50"! 

355INPUTJS 

35SIFJ$i"NO»THEN360 

387LETC"C*50 

358LET0»0/2 

3S9RETURN 

360IFO/3«&gt;INTCO/3)THEN367 _ 

36l~PRINT"WQULD YOU LIKE TO BUY BACK YOUR TIE TACK FOR $50«&gt; 

362INPUTJS 

363"IFJ$«»N0»THEN367 

364LETC«C»B0 

365LET0P0/3 

366RETURN 

367PRINT»I«M BUSTED. CONGRATULATIONS" 

3688T0P 

369PRINTH$»I$| 

370IFH$o»A FL U8*THEN375 

37lLETKtlNT("K/100) 

372COSUB208 

373PRINT 

374RETURN 

37SLEfK»FNB(K) 

376008UB196 

3T7IFH $ » " S C H M A L »• f H I N 379 

378IFH$&lt;&gt;»STRAlG"THEN38i 

379PRINT" HIGH" 

380RETURN 

"38iPRX'NT»8* 

382RETURN 

383PRINf 

384PRINt h Y0U CAN«T BET WHAT YOu HAvEN»T GOT" 

T8SIFO/2»INTCO/2)THEN397 

386PRINT"W0ULD YOU LIKE TO SELL YOUR WATCH"! 

387INPUTJS 

388 lFjS»"N 0_»_T H E N 3 97 

I89~I F F N A ( 01 &gt; ■TTH E N 393 

390PRINT"I'LL GIVE YOU $76 FOR IT" 

391LETS»S*75 

392G0T0395 

393PRINT"THAT«8 A PRETTY CRUMMY WATCH - I'LL GIVE YOU $2S" 

394LETSiS*2S 

395LET0»0*2 

396RETURN 

3"97IFO/3"INTCO/3)THEN409 

398PRINT"WILL YOU PART WITH THAT DIAMOND TIE TACK"! 

399INPUT J$ 

400lFJSi«NO»THEN408 

401IFFNX(0T&gt;"»6THEN405" 

402PRINT"YOU ARE NOW $100 RICHER" 

403LET8«S*100 

404GOTO407 

405PRINT«IT«S PASTE. $25« 

406 LETS tS»26 

407LETO«O^3 

408RETURN 

409PRINT"YOUR WAD IS SHOT, SO LONG, SUCKER" 

410END 
