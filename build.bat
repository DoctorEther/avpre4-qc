@echo off

set "progs_path=%USERPROFILE%\Desktop\bddb4\bddpre4"

C:\Quake\fteqcc\fteqcc64.exe -O1 src\progs.src

if exist "progs.dat" move /Y "progs.dat" "%progs_path%" >nul

pause
