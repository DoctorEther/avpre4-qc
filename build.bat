@echo off

C:\fteqcc\fteqcc64.exe -O1 -std=qccx src\progs.src

del /q "%USERPROFILE%\Desktop\bddb4\id1\progs.dat"
move "progs.dat" "%USERPROFILE%\Desktop\bddb4\id1\"

pause
