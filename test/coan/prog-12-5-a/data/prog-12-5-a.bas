8 REM   A IS A COLUMN VECTOR AND B IS A ROW VECTOR
10 DIM A[10,1],B[1,10]
20 MAT READ A
30 DATA 1,2,3,4,5,6,7,8,9,10
40 MAT B=TRN(A)
45 PRINT "TRANSPOSE OF COLUMN VECTOR A"
50 MAT PRINT B;
60 END
