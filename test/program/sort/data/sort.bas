10 REM THIS PROGRAM IS A NAIVE SORT.
100 LET N = 100
102 OPTION MAX_DIM N
110 PRINT "NAIVE SORT"
112 PRINT N;" VALUES"
114 PRINT
120 DIM Z(100)
122 ARR Z = RND1(N, 100)
130 PRINT "ORIGINAL ARRAY:"
132 ARR PRINT Z
134 PRINT
140 ARR Z = SORT1(Z)
150 PRINT "SORTED ARRAY:"
152 ARR PRINT Z
154 PRINT
999 END
