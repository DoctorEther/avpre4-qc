@echo off

C:\fteqcc\fteqcc64.exe -O1 -std=qccx src\progs.src

del /q "C:\Users\%USERNAME%\Desktop\bddb4\id1\progs.dat"
move "progs.dat" "C:\Users\%USERNAME%\Desktop\bddb4\id1\"

pause
