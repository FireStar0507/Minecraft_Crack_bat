@echo off
cd /d "%~dp0"
::����˵��
title MFWL
echo [36m****** MINECRAFT FOR WINDOWS PLAN B UNLOCK LAUNCHER
echo �ýű����Զ��������� Minecraft for Windows��UWP��
echo ��ȷ�����Ѿ���װ�� Minecraft for Windows�����������ð棩
echo �벻Ҫ����Ϸ���й����йرձ��ű�����Ϸ�رպ󱾽ű����Զ�ȡ���������˳�
echo ���ȷ��ϵͳ���Ǿ����Ż�����ϵͳ�汾���ڵ��� Windows10 1909��19H2/KB5004926/18362.446��
echo ��ط���ԭ���������磬���ű��� jiecs_23 ����
::��⻷��
echo.
echo [0m��ǰ����·����%CD%
echo [0m������ԱȨ��...
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul && goto uacOK
echo [31m### δ��ȡ������ԱȨ��
echo [36m### ���������ԱȨ�ޣ�UAC��[0m
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:uacOK
echo [0m��� Minecraft for Windows ״̬...
tasklist|find "Minecraft.Windows.exe" || goto mcOK
echo [36m******����Minecraft for Windows10 �������У�����ͬʱ���ж��ʵ��
echo ��1��ǿ�ƹر� Minecraft for Windows10 ������
echo ��2���������״̬������
choice /c 12 /n /m "����Ҫִ�еĲ�����"
if ERRORLEVEL 2 goto Unlock
if ERRORLEVEL 1 (
	echo [0m
	taskkill /im Minecraft.Windows.exe /f
	goto Unlock
)
:mcOK

::����
:Unlock
echo.
echo [0m### ��ʼ���� Minecraft for Windows
echo ����ע�����...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%SystemRoot%\System32\ClipSVC.dlla" /f
echo ֹͣ ClipSVC ����...
net	stop ClipSVC
if %errorlevel%==2 (echo [31m### ClipSVC ����ֹͣʧ�ܣ�level2 ��������Ϊ Minecraft for Windows �����ѽ�����) else if ERRORLEVEL 1 (echo [31m### ClipSVC ����ֹͣʧ�ܣ�level%errorlevel%��)
echo [32m### �ɹ���Minecraft for Windows10 �ѽ���[0m
::����Minecraft
echo ### �������� Minecraft for Windows
start Minecraft:
timeout /nobreak /t 3
tasklist|find "Minecraft.Windows.exe" 
if not ERRORLEVEL 1 (
	echo [32m### Minecraft for Windows10 �ѳɹ���ʼ����[0m
	goto Scan
)
echo [36m******����Minecraft for Windows10 Ӧ������������δ֪ԭ��δ����
echo ��ȷ�����Ѿ���װ�� Minecraft for Windows�����������ð棩
echo ��1�����³������� Minecraft for Windows10 �����ټ����״̬
echo ��2���������״̬������
choice /c 12 /n /m "����Ҫִ�еĲ�����"
if ERRORLEVEL 2 goto Scan
if ERRORLEVEL 1 (
	call Minecraft.lnk
	timeout /nobreak /t 3
	echo [0m
	goto Scan
)

::ѭ����� Minecraft �Ƿ�رղ����� RuntimeBroker.exe ����
:Scan
tasklist|find "Minecraft.Windows.exe" >nul || goto Off
for /f "tokens=3" %%i in ('tasklist /nh /apps /fi "IMAGENAME eq RuntimeBroker.exe"^|find "Microsoft.MinecraftUWP"') do @taskkill /pid %%i /f
goto Scan

:Off
echo ### Minecraft for Windows10 ���˳�
echo ### ����ȡ������ Minecraft for Windows���ָ�ԭ����
echo ����ע�����...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v ServiceDll /t REG_EXPAND_SZ /d "%SystemRoot%\System32\ClipSVC.dll" /f
echo ���� ClipSVC ����...
net	start ClipSVC
if %errorlevel%==2 (echo [31m### ClipSVC ��������ʧ�ܣ�level2 ��������Ϊ Minecraft for Windows ����δ������) else if ERRORLEVEL 1 (echo [31m### ClipSVC ��������ʧ�ܣ�level%serviceError%��)
echo [32m### �ɹ���Minecraft for Windows ��ȡ���������ָ�ԭ����[0m
exit