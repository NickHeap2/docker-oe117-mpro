docker run -it --rm^
 -e PROCFG="/usr/dlc/procfg/progress.cfg"^
 -v progress_1172_cfg:/usr/dlc/procfg/^
 -e RUN_IN_FOREGROUND=true^
 --user 0^
 oe117-mpro:0.1

 REM --entrypoint bash^
 