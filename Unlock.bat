@echo off
setlocal DisableDelayedExpansion
cd /d "%~dp0"
::启动说明
title MFWL
echo [36m****** MINECRAFT FOR WINDOWS UNLOCK
echo 该脚本可以自动选择方案并解锁 Minecraft for Windows（UWP）
echo 请确保您已经安装了 Minecraft for Windows（可以是试用版）
echo 最好确保系统不是精简优化版且系统版本大于等于 Windows10 1909（19H2/KB5004926/18362.446）
echo 解锁时用方案 A 取消解锁也必须用方案 A；解锁时用方案 B 取消解锁也必须用方案 B。方案 A 和 B 只需使用一个，不可同时使用。否则会导致系统文件损坏！
echo 相关方法原理来自网络，本脚本由 jiecs_23 制作，由 FireStar0507 转载
::检测环境
echo.
echo [0m当前运行路径：%CD%
echo [0m检查管理员权限...
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if not ERRORLEVEL 1 goto uacOK
echo [31m### 未获取到管理员权限
echo [36m### 请授予管理员权限（UAC）[0m
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:uacOK
echo [0m检查 Minecraft for Windows 状态...
tasklist|find "Minecraft.Windows.exe" || goto mcOK
echo [36m******错误！Minecraft for Windows10 正在运行，不能在其运行中操作
echo 【1】强制关闭 Minecraft for Windows10 并继续
echo 【2】跳过检测状态并继续
echo 【3】帮助信息与相关链接
choice /c 123 /n /m "你想要执行的操作："
if ERRORLEVEL 3 goto Help
if ERRORLEVEL 2 goto Started
if ERRORLEVEL 1 (
	echo [0m
	taskkill /im Minecraft.Windows.exe /f
	timeout /nobreak /t 3
	goto Started
)
:mcOK

::获取用户操作
:Started
echo.
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v "ServiceDll"') do (
	if not %%i==C:\WINDOWS\System32\ClipSVC.dll (echo [36m### 处于方案 B 的已解锁状态[0m)
)
if %PROCESSOR_ARCHITECTURE:~-2%==64 (set n=0) else (set n=1)
for  /f %%i in ('certutil -hashfile %windir%\System32\Windows.ApplicationModel.Store.dll') do (
	if %%i==a54a840771c33f2bf220a7af36d6a2747d6a7955 set /a n+=1
)
for  /f %%i in ('certutil -hashfile %windir%\SysWOW64\Windows.ApplicationModel.Store.dll') do (
	if %%i==1dc4ec7631f20d54dd8c1951df492719234f6f27 set /a n+=1
)
if %n% LSS 2 echo [36m### 处于方案 A 的已解锁状态
echo [36m******执行操作
echo 【1】选择方案解锁 Minecraft for Windows
echo 【2】选择方案取消解锁 Minecraft for Windows（恢复原样）
echo 【3】帮助信息与相关链接
choice /c 123 /n /m "你想要执行的操作："
if ERRORLEVEL 3 goto Help
if ERRORLEVEL 2 goto analyticsOff
if ERRORLEVEL 1 goto analyticsOn


::分析适合的解锁方案
:analyticsOn
echo [0m### 开始分析适合的解锁方案
for /f "tokens=4-7 delims=[.] " %%i in ('ver') do @(if %%i==Version (set ver=%%j.%%k.%%l) else (set ver=%%i.%%j.%%k))
echo 当前系统版本：%ver%
echo [36m### 解锁时用方案 A 取消解锁也必须用方案 A；解锁时用方案 B 取消解锁也必须用方案 B。方案 A 和 B 只需使用一个，不可同时使用。否则会导致系统文件损坏！
echo ### 使用方案 A 请最好确保您的系统版本大于等于 Windows10 1909（19H2/KB5004926/18362.446）
echo ### 使用方案 A 操作时需要暂时关闭全部 Xbox、Microsoft Store 相关部分进程，请注意不要丢失个人数据
echo ### 使用方案 B 请最好确保您的系统不是精简优化版，否则可能会导致系统蓝屏等故障
echo ### 使用方案 B 会导致 Microsoft Store 无法下载应用，请参考帮助信息与相关链接
echo ### 使用方案 B 启动 Minecraft 需要手动结束 RuntimeBroker.exe 进程，或使用 PlanB Launcher.bat 启动
echo ### 可以使用 PlanB UnlockLauncher.bat 启动 Minecraft，自动使用方案 B 解锁并处理相关问题
if %ver% GEQ 10.0.18362.446 (
	echo ### 当前系统环境建议使用方案 A
) else (
	echo ### 系统版本低于 Windows10 1909（19H2/KB5004926/18362.446）
	echo ### 当前系统环境建议使用方案 B
)
echo 【a】使用方案 A 解锁（替换 DLL）
echo 【b】使用方案 B 解锁（禁用服务）
choice /c ab /n /m "你想要执行的操作："
if ERRORLEVEL 2 (
	echo [0m### 开始解锁 Minecraft for Windows（方案B）
	goto bOn
)
if ERRORLEVEL 1 (
	echo [0m### 开始解锁 Minecraft for Windows（方案A）
	goto aOn
)

::解锁方案A - 替换 DLL
:aOn
set bit=%PROCESSOR_ARCHITECTURE:~-2%
echo 当前系统架构：x%bit%
if %bit%==64 (
	echo 开始处理 System32 DLL
	echo 记录文件 DACL 状态...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /save %windir%\System32\Windows.ApplicationModel.Store.dll.temp
	echo 夺取文件所有者...
	takeown /a /f %windir%\System32\Windows.ApplicationModel.Store.dll
	echo 获取文件权限...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /c /grant Administrators:F
	echo 备份原 DLL...
	rename %windir%\System32\Windows.ApplicationModel.Store.dll Windows.ApplicationModel.Store.dll.backup
	echo 替换新 DLL...
	copy /y .\aRes\x64\System32\Windows.ApplicationModel.Store.dll %windir%\System32\Windows.ApplicationModel.Store.dll
	echo 恢复文件 DACL 状态...
	icacls %windir%\System32 /restore %windir%\System32\Windows.ApplicationModel.Store.dll.temp && del /f %windir%\System32\Windows.ApplicationModel.Store.dll.temp
	echo 开始处理 SysWOW64 DLL
	echo 记录文件 DACL 状态...
	icacls %windir%\SysWOW64\Windows.ApplicationModel.Store.dll /save %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.temp
	echo 夺取文件所有者...
	takeown /a /f %windir%\SysWOW64\Windows.ApplicationModel.Store.dll
	echo 获取文件权限...
	icacls %windir%\SysWOW64\Windows.ApplicationModel.Store.dll /c /grant Administrators:F
	echo 备份原 DLL...
	rename %windir%\SysWOW64\Windows.ApplicationModel.Store.dll Windows.ApplicationModel.Store.dll.backup
	echo 替换新 DLL...
	copy /y .\aRes\x64\SysWOW64\Windows.ApplicationModel.Store.dll %windir%\SysWOW64\Windows.ApplicationModel.Store.dll
	echo 恢复文件 DACL 状态...
	icacls %windir%\SysWOW64 /restore %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.temp && del /f %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.temp
) else (
	echo 开始处理 System32 DLL
	echo 记录文件 DACL 状态...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /save %windir%\System32\Windows.ApplicationModel.Store.dll.temp
	echo 夺取文件所有者...
	takeown /a /f %windir%\System32\Windows.ApplicationModel.Store.dll
	echo 获取文件权限...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /c /grant Administrators:F
	echo 备份原 DLL...
	rename %windir%\System32\Windows.ApplicationModel.Store.dll Windows.ApplicationModel.Store.dll.backup
	echo 替换新 DLL...
	copy /y .\aRes\x86\System32\Windows.ApplicationModel.Store.dll %windir%\System32\Windows.ApplicationModel.Store.dll
	echo 恢复文件 DACL 状态...
	icacls %windir%\System32 /restore %windir%\System32\Windows.ApplicationModel.Store.dll.temp && del /f %windir%\System32\Windows.ApplicationModel.Store.dll.temp
)
echo [32m### Minecraft for Windows10 已解锁
goto Started

::解锁方案B - 添加注册表并停止服务
:bOn
echo [0m添加注册表项...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%SystemRoot%\System32\ClipSVC.dlla" /f
echo 停止 ClipSVC 服务...
net	stop ClipSVC
if %errorlevel%==2 (echo [31m### ClipSVC 服务停止失败（level2 可能是因为 Minecraft for Windows 本就已解锁）) else if ERRORLEVEL 1 (echo [31m### ClipSVC 服务停止失败（level%errorlevel%）)
echo [32m### Minecraft for Windows10 已解锁
goto Started


::分析适合的取消解锁方案
:analyticsOff
echo [0m### 开始分析适合的取消解锁方案
set score=0
for /f "tokens=4-7 delims=[.] " %%i in ('ver') do @(if %%i==Version (set ver=%%j.%%k.%%l) else (set ver=%%i.%%j.%%k))
echo 当前系统版本：%ver%
if %ver% GEQ 10.0.18362.446 (set /a score+=1) else (set /a score-=1)
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v "ServiceDll"') do (
	if %%i==C:\WINDOWS\System32\ClipSVC.dll (set /a score+=1) else (set /a score-=1)
)
if %PROCESSOR_ARCHITECTURE:~-2%==64 (set n=0) else (set n=1)
for  /f %%i in ('certutil -hashfile %windir%\System32\Windows.ApplicationModel.Store.dll') do (
	if %%i==a54a840771c33f2bf220a7af36d6a2747d6a7955 set /a n+=1
)
for  /f %%i in ('certutil -hashfile %windir%\SysWOW64\Windows.ApplicationModel.Store.dll') do (
	if %%i==641a078702f914c5a8f1df2ae2a323b7 set /a n+=1
)
if %n% LSS 2 (
	set /a score+=1
) else (
	set /a score-=1
)
echo.
echo [36m### 解锁时用方案 A 取消解锁也必须用方案 A；解锁时用方案 B 取消解锁也必须用方案 B。否则会导致系统文件损坏！
echo ### 使用方案 A 操作时需要暂时关闭全部 Xbox、Microsoft Store 相关部分进程，请注意不要丢失个人数据
if %score% GTR 0 (echo ### 当前系统环境建议使用方案 A（特征分%score%）) else (echo ### 当前系统环境建议使用方案 B（特征分%score%）)
echo 【a】使用方案 A 取消解锁（替换 DLL）
echo 【b】使用方案 B 取消解锁（禁用服务）
choice /c ab /n /m "你想要执行的操作："
if ERRORLEVEL 2 (
	echo [0m### 开始取消解锁 Minecraft for Windows（方案B）
	goto bOff
)
if ERRORLEVEL 1 (
	echo [0m### 开始取消解锁 Minecraft for Windows（方案A）
	goto aOff
)

::取消解锁方案A - 恢复备份的 DLL
:aOff
set bit=%PROCESSOR_ARCHITECTURE:~-2%
echo [0m当前系统架构：x%bit%
if %bit%==64 (
	echo 开始处理 System32 DLL
	echo 记录文件 DACL 状态...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /save %windir%\System32\Windows.ApplicationModel.Store.dll.temp
	echo 夺取文件所有者...
	takeown /a /f %windir%\System32\Windows.ApplicationModel.Store.dll
	echo 获取文件权限...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /grant Administrators:F
	if exist %windir%\System32\Windows.ApplicationModel.Store.dll.backup (
		echo 删除替换的 DLL...
		del /f %windir%\System32\Windows.ApplicationModel.Store.dll
		echo 恢复备份 DLL...
		rename %windir%\System32\Windows.ApplicationModel.Store.dll.backup Windows.ApplicationModel.Store.dll
	) else (
		echo [31m### System32 DLL 备份不存在[0m
	)
	echo 恢复文件 DACL 状态...
	icacls %windir%\System32 /restore %windir%\System32\Windows.ApplicationModel.Store.dll.temp && del /f %windir%\System32\Windows.ApplicationModel.Store.dll.temp
	echo 开始处理 SysWOW64 DLL
	echo 记录文件 DACL 状态...
	icacls %windir%\SysWOW64\Windows.ApplicationModel.Store.dll /save %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.temp
	echo 夺取文件所有者...
	takeown /a /f %windir%\SysWOW64\Windows.ApplicationModel.Store.dll
	echo 获取文件权限...
	icacls %windir%\SysWOW64\Windows.ApplicationModel.Store.dll /grant Administrators:F
	if exist %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.backup (
		echo 删除替换的 DLL...
		del /f %windir%\SysWOW64\Windows.ApplicationModel.Store.dll
		echo 恢复备份 DLL...
		rename %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.backup Windows.ApplicationModel.Store.dll
	) else (
		echo [31m### SysWOW64 DLL 备份不存在[0m
	)
	echo 恢复文件 DACL 状态...
	icacls %windir%\SysWOW64 /restore %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.temp && del /f %windir%\SysWOW64\Windows.ApplicationModel.Store.dll.temp
) else (
	echo 开始处理 System32 DLL
	echo 记录文件 DACL 状态...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /save %windir%\System32\Windows.ApplicationModel.Store.dll.temp
	echo 夺取文件所有者...
	takeown /a /f %windir%\System32\Windows.ApplicationModel.Store.dll
	echo 获取文件权限...
	icacls %windir%\System32\Windows.ApplicationModel.Store.dll /grant Administrators:F
	if exist %windir%\System32\Windows.ApplicationModel.Store.dll.backup (
		echo 删除替换的 DLL...
		del /f %windir%\System32\Windows.ApplicationModel.Store.dll
		echo 恢复备份 DLL...
		rename %windir%\System32\Windows.ApplicationModel.Store.dll.backup Windows.ApplicationModel.Store.dll
	)
	echo 恢复文件 DACL 状态...
	icacls %windir%\System32 /restore %windir%\System32\Windows.ApplicationModel.Store.dll.temp && del /f %windir%\System32\Windows.ApplicationModel.Store.dll.temp
)
echo [32m### Minecraft for Windows 已取消解锁（恢复原样）
goto Started

::取消解锁方案B - 添加注册表并启动服务
:bOff
echo 添加注册表项...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%SystemRoot%\System32\ClipSVC.dll" /f
echo 启动 ClipSVC 服务...
net	start ClipSVC
if %errorlevel%==2 (echo [31m### ClipSVC 服务启动失败（level2 可能是因为 Minecraft for Windows 本就未解锁）) else if ERRORLEVEL 1 (echo [31m### ClipSVC 服务启动失败（level%serviceError%）)
echo [32m### Minecraft for Windows 已取消解锁（恢复原样）
goto Started

:Help
echo.
echo [36m******帮助信息与相关链接
echo bat 脚本制作：杰出兽 jiecs_23 Jiecs
echo 帮助信息与相关链接：https://www.jiecs.top/archives/764
echo 【1】返回主页面
echo 【2】用浏览器打开帮助文档链接
choice /c 12 /n /m "你想要执行的操作："
if ERRORLEVEL 2 start https://www.jiecs.top/archives/764
goto Started
