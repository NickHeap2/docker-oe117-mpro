DEFINE VARIABLE counter AS INTEGER NO-UNDO.
DEFINE VARIABLE trap AS HANDLE NO-UNDO.

SERVER_WAIT_LOOP:
DO WHILE TRUE:
  IF counter >= 10 THEN DO:
    trap:label = "".
    LEAVE SERVER_WAIT_LOOP.
  END.
  ELSE DO:
    MESSAGE "Nothing to do...".
    counter = counter + 1.
    PROCESS EVENTS.
    PAUSE 1.
  END.
END.
QUIT.