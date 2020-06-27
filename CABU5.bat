@echo off
rem What this bat does.
rem Create folder named "/default path/disk name - id" for the images using the %defaultPath% variable
rem Create a subfolder "/default path/disk name - id/stream" for the preservation stream files
rem Create the stream files in the stream subfolder
rem Create CT Raw (ipf) and Disk File (adf) in "/default path/disk name - id" folder

rem Set common strings
set usage="cabu <id> <disk name> <optional:number of disks>  NOTE: id and disk name are required"
set defaultPath=save
set /A diskNumber = 1

rem Check for parameters
if "%~1"=="" echo Usage: %usage% & goto end
if "%~2"=="" echo Usage: %usage% & goto end
if "%~3" == "" (set /A diskCount = 1) else (set /A diskCount = %3)

rem Create the directory first, the -p flag for dtc was not getting the job done. Capturing the log file was causing a directory not found issue.

mkdir "./%defaultPath%/%~2 - %1"

rem Simple loop pattern with goto's and labels since for doesn't use variable. . .
set loopcount=%diskCount%
:loop

echo Enter disk %diskNumber% of %diskCount%
pause
echo Creating image of disk %diskNumber% of %diskCount%

dtc -p -f"%defaultPath%/%~2 - %1/stream disk - %diskNumber% of %diskCount%/%~2 " -i0a -f"%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% of %diskCount%.adf" -i5 -f"%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% of %diskCount%.ipf" -i2 1> "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" 2>&1

rem Create individual logs for OK, Bad sector reads, and Read operation failed
find "AmigaDOS: OK" "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" > "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Ok.log"
find "Bad sector found" "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" > "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Bad sector found.log"
find "Read operation failed" "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" > "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Read operation failed.log"

rem Create a log summary
echo AmigaDos: OK > "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Summary.log"
find /C "AmigaDOS: OK" "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" >> "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Summary.log"
echo Bad Sector Found >> "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Summary.log"
find /C "Bad sector found" "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" >> "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Summary.log"
echo Read operation failed >> "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Summary.log"
find /C "Read operation failed" "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber%.log" >> "./%defaultPath%/%~2 - %1/%~2 - disk %diskNumber% - Summary.log"
				 
set /A loopcount=loopcount-1

set /A diskNumber = %diskNumber% + 1

if %loopcount%==0 goto exitloop
goto loop
:exitloop


:end
echo Done!

