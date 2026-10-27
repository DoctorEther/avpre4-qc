@echo off
REM PUT YOUR BDDPRE4 MOD FOLDER HERE (INSTEAD OF '.')
set "progs_path=."

C:\Quake\fteqcc\fteqcc64.exe src\progs.src

if exist "progs.dat" move /Y "progs.dat" "%progs_path%" >nul

pause
