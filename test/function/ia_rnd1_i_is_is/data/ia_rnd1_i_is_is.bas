10 REM ARRAY FUNCTION RND1%()
15 DIM D%(3)
20 ARR A% = RND1%(5%, 10%)
30 ARR B% = RND1%(3%, 2%)
40 ARR C% = RND1%(4%, 5%)
45 ARR D% = RND1%
50 PRINT "ARRAY A"
60 ARR PRINT A%
70 PRINT "ARRAY B"
80 ARR PRINT B%
90 PRINT "ARRAY C"
100 ARR PRINT C%
110 PRINT "ARRAY D"
120 ARR PRINT D%
200 OPTION BASE 1
220 ARR A% = RND1%(5%, 10%)
230 ARR B% = RND1%(3%, 2%)
240 ARR C% = RND1%(4%, 5%)
245 ARR D% = RND1%()
250 PRINT "ARRAY A"
260 ARR PRINT A%
270 PRINT "ARRAY B"
280 ARR PRINT B%
290 PRINT "ARRAY C"
300 ARR PRINT C%
310 PRINT "ARRAY D"
320 ARR PRINT D%
999 END
