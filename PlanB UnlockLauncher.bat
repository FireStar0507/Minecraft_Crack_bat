@echo off
cd /d "%~dp0"
::启动说明
title MFWL
echo [36m****** MINECRAFT FOR WINDOWS PLAN B UNLOCK LAUNCHER
echo 该脚本将自动解锁、打开 Minecraft for Windows（UWP）
echo 请确保您已经安装了 Minecraft for Windows（可以是试用版）
echo 请不要在游戏运行过程中关闭本脚本，游戏关闭后本脚本将自动取消解锁并退出
echo 最好确保系统不是精简优化版且系统版本大于等于 Windows10 1909（19H2/KB5004926/18362.446）
echo 相关方法原理来自网络，本脚本由 jiecs_23 制作
::检测环境
echo.
echo [0m当前运行路径：%CD%
echo [0m检查管理员权限...
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul && goto uacOK
echo [31m### 未获取到管理员权限
echo [36m### 请授予管理员权限（UAC）[0m
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:uacOK
echo [0m检查 Minecraft for Windows 状态...
tasklist|find "Minecraft.Windows.exe" || goto mcOK
echo [36m******错误！Minecraft for Windows10 正在运行，不能同时运行多个实例
echo 【1】强制关闭 Minecraft for Windows10 并继续
echo 【2】跳过检测状态并继续
choice /c 12 /n /m "你想要执行的操作："
if ERRORLEVEL 2 goto Unlock
if ERRORLEVEL 1 (
	echo [0m
	taskkill /im Minecraft.Windows.exe /f
	goto Unlock
)
:mcOK

::解锁
:Unlock
echo.
echo [0m### 开始解锁 Minecraft for Windows
echo 添加注册表项...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%SystemRoot%\System32\ClipSVC.dlla" /f
echo 停止 ClipSVC 服务...
net	stop ClipSVC
if %errorlevel%==2 (echo [31m### ClipSVC 服务停止失败（level2 可能是因为 Minecraft for Windows 本就已解锁）) else if ERRORLEVEL 1 (echo [31m### ClipSVC 服务停止失败（level%errorlevel%）)
echo [32m### 成功！Minecraft for Windows10 已解锁[0m
::启动Minecraft
echo ### 尝试启动 Minecraft for Windows
start Minecraft:
timeout /nobreak /t 3
tasklist|find "Minecraft.Windows.exe" 
if not ERRORLEVEL 1 (
	echo [32m### Minecraft for Windows10 已成功开始运行[0m
	goto Scan
)
echo [36m******错误！Minecraft for Windows10 应当启动，但因未知原因未启动
echo 请确保您已经安装了 Minecraft for Windows（可以是试用版）
echo 【1】重新尝试启动 Minecraft for Windows10 并不再检测其状态
echo 【2】跳过检测状态并继续
choice /c 12 /n /m "你想要执行的操作："
if ERRORLEVEL 2 goto Scan
if ERRORLEVEL 1 (
	call Minecraft.lnk
	timeout /nobreak /t 3
	echo [0m
	goto Scan
)

::循环检测 Minecraft 是否关闭并结束 RuntimeBroker.exe 进程
:Scan
tasklist|find "Minecraft.Windows.exe" >nul || goto Off
for /f "tokens=3" %%i in ('tasklist /nh /apps /fi "IMAGENAME eq RuntimeBroker.exe"^|find "Microsoft.MinecraftUWP"') do @taskkill /pid %%i /f
goto Scan

:Off
echo ### Minecraft for Windows10 已退出
echo ### 正在取消解锁 Minecraft for Windows（恢复原样）
echo 添加注册表项...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%SystemRoot%\System32\ClipSVC.dll" /f
echo 启动 ClipSVC 服务...
net	start ClipSVC
if %errorlevel%==2 (echo [31m### ClipSVC 服务启动失败（level2 可能是因为 Minecraft for Windows 本就未解锁）) else if ERRORLEVEL 1 (echo [31m### ClipSVC 服务启动失败（level%serviceError%）)
echo [32m### 成功！Minecraft for Windows 已取消解锁（恢复原样）[0m
exit