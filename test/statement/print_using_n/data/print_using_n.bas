10 REM TEST PRINT USING
20 N = 27 : N2 = 36 : N3 = 102
22 A$ = "HELLO, WORLD!"
24 B$ = "AB"
26 F = 3.14159
28 L = 1234567.89
30 PRINT USING "NUMBER  [###]",N
32 PRINT USING "MULTIPLE NUMBER [###] [###] [###]", N, N2, N3
40 PRINT USING "CHAR [!]", A$
50 PRINT USING "STRING [&]", A$
60 PRINT USING "PADDED [\     \]", B$
80 PRINT USING "FLOAT [###.#####]", F
90 PRINT USING "FLOAT [#.#####]", F
100 PRINT USING "FLOAT [###.##]", F
110 PRINT USING "FLOAT [#####.#####]", L
120 PRINT USING "FLOAT [##########.#]", L
130 PRINT USING "FLOAT [*****#.####]", F
140 PRINT USING "FLOAT [*****#.####]", L
150 PRINT USING "FLOAT [$****#.####]", F
160 PRINT USING "FLOAT [$****#.####]", L
999 END
