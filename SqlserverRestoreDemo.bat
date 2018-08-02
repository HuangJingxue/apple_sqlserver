@echo off
rem SetLocal
rem SetLocal EnableDelayedExpansion
rem Check 'delayed environment variable expansion'
if NOT "%OS%"=="!OS!" (
	SetLocal EnableDelayedExpansion
	set FlagLocal=1
)

rem Debug setting
if Defined DbgLvl set DebugLevel=%DbgLvl%
if defined DebugLevel (
	echo DebugLevel=%DebugLevel%
) else (
	set DebugLevel=0
)
set DbgChk=if !DebugLevel!

%DbgChk% LSS 1 (
	set "NoOut=> nul"
	set "NoErr=2> nul"
	set "NoAll=> nul 2>&1"
)

rem Defined by user

set strdate=%date:~0,4%%date:~5,2%%date:~8,2%

rem credential for sqlserver
set sqlhost=localhost
set sqluser=sqlbackup
set sqlpasswd=Zhuyun#123
set sqldb=test

set sqllocalpath=%USERPROFILE%
set sqllocalname1=test!strdate!.bak
set sqllocalname2=test!strdate!_diff.bak
rem set sqlbackdest='%sqllocalpath%\%sqllocalname%'

set sqlsql="restore database [!sqldb!] from disk='%sqllocalpath%\%sqllocalname1%' with replace,norecovery;restore database [!sqldb!] from disk='%sqllocalpath%\%sqllocalname2%' with replace;"

rem remote server
set rmthost=3b2a74ad44-ame62.cn-shanghai.nas.aliyuncs.com
set rmtsharename=myshare
set rmtpath=sql
rem set rmtuser=guest
rem set rmtpasswd=guest123

%DbgChk% GEQ 5 echo This is debug info.
rem here is main

rem transfer bak file
net use \\%rmthost%\%rmtsharename%

rem Get backup files
robocopy \\%rmthost%\%rmtsharename%\%rmtpath% %sqllocalpath% %sqllocalname1% %sqllocalname2% /mov /np

rem backup sqlserver's database
sqlcmd -S %sqlhost% -U %sqluser% -P %sqlpasswd% -d %sqldb% -Q %sqlsql%

if Defined FlagLocal (
	EndLocal
)
