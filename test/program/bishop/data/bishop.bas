10 REM Drunken bishop
 
GET SOME DATA

BUILD 8x8 BOARD OF ZEROS

POSITION AT CENTER (ISH)

FOR EACH TWO BITS (DIBBLE?)

  IF 0x AND NOT ROW 1 MOVE UP

  IF 1x AND NOT ROW 8 MOVE DOWN

  IF x0 AND NOT COL 8 MOVE RIGHT

  IF x1 AND NOT COL 1 MOVE LEFT

  ADD 1 TO BOARD VALUE

PRINT BOARD
