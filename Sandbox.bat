@echo off

echo 检查权限
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

echo 权限检查结果：%errorlevel%

REM --> 如果设置了错误标志，则没有管理员权限。
if '%errorlevel%' NEQ '0' (
echo 正在请求管理员权限...
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

echo 正在运行创建的临时文件 "%temp%\getadmin.vbs"
timeout /T 2
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

echo 使用管理员权限成功启动批处理
echo .
cls
Title Sandbox Setup

pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\*Containers*.mum >sandbox.txt

for /f %%i in ('findstr /i . sandbox.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

del sandbox.txt

Dism /online /enable-feature /featurename:Containers-DisposableClientVM /LimitAccess /ALL

pause