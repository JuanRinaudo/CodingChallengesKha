@echo off
::Go up a folder, so khamake is called from the right directory
::cd ..\

echo ___________________________________
echo khamake builder
echo type q to quit.
echo ___________________________________

::Target input.
:platform_input
set target=windows

::Options input.
set options=

start /b /wait %opt% node Kha\make %target% %options%

echo ___________________________________
PAUSE