@echo off
@title WIFI���߹�����

REM ��Ȩ���У�Kingron<kingron@163.com>

set help=0
if "%1"=="/?" set help=1
if "%1"=="help" set help=1
if "%1"=="-help" set help=1
if %help% equ 1 (
  echo WIFI���߹����� v1.2
  echo �÷�
  echo    %~n0 [create ^| start ^| stop ^| view ^| password ^| help]
  exit /b 0
)

net session >nul 2>&1
if not "%errorLevel%" == "0" (
  echo ��������Ҫ����ԱȨ�ޣ����Զ��л�������ԱȨ�ޣ���������û�Ȩ�޿��ƶԻ���
  echo �������ǡ���ť�Լ������У�����������������
  echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
  echo UAC.ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\getadmin.vbs"

  "%temp%\getadmin.vbs"
  exit /b 2
)

if "%1"=="create" goto create
if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="view" goto view
if "%1"=="password" goto password
if "%1"=="share" goto share

:menu
echo WIFI���߹����� v1.2
echo ������������ֹͣ�ʼǱ�������WIFI�ȵ㣬����������
echo ��������ҪWIFI����֧������AP����ʹ�ã�Ŀǰ�󲿷�WIFIоƬ��֧�֡�
echo ���������谲װ�κε����������Ҳ��ռ���κ�ϵͳ��Դ����ȫ��ɫ������
echo.
echo ������������������������
echo �� ���߹�����v1.2   ��
echo �ǩ���������������������
echo �� 1. ��������WIFI    ��
echo �� 2. ��������WIFI    ��
echo �� 3. ֹͣ����WIFI    ��
echo �� 4. �鿴WIFI����    ��
echo �� 5. ����WIFI����    ��
echo �� 6. ����WIFI����    ��
echo �� 7. �˳�            ��
echo ������������������������
echo.
set /p mid=��ѡ�� 1-7 �������Enter������
if "%mid%"=="1" goto create
if "%mid%"=="2" goto start
if "%mid%"=="3" goto stop
if "%mid%"=="4" goto view
if "%mid%"=="5" goto password
if "%mid%"=="6" goto share
if "%mid%"=="7" goto end
echo ����ѡ���������Ч�������ԡ�
goto menu

:create
echo.
echo ע�⣺
echo ��������WIFIֻҪ����һ�ξͿ����ˣ����������С�
echo �����Ҫ���³�ʼ��WIFI�������WIFI��SSID�����룬�ǿ�����������һ�Ρ�
echo.

REM if you want to use this for other language, you should change below tags.
REM CP 936 = Chinese, 437 = English
echo ������������Ƿ�֧������WIFI�ȵ�...
set supported=0
netsh wlan show drive | find "֧�ֵĳ�������" | find "��"
if %errorlevel%==0 set supported=1
netsh wlan show drive | find "Hosted network supported" | find "Yes"
if %errorlevel%==0 set supported=1
if %supported% equ 1 (
  echo ��ϲ�������������֧������WIFI�ȵ�ģʽ��
  echo ����ݺ���ָ���������WIFI�����á�
) else (
  echo ���ź����������������֧������WIFI�ȵ�ģʽ��
  exit /b 1
)

if "%_name%"=="" set _name=wlan
set /p _name=������WIFI�ȵ�����֣�Ĭ��: %_name%����
set /p _password=������WIFI�ȵ�����루���裬���볤��Ϊ 8~63 �ַ�����
netsh wlan set hostednetwork mode=allow ssid=%_name% key=%_password%
if "%errorlevel%"=="0" echo ����WIFI�ɹ���
netsh wlan start hostednetwork
if "%errorlevel%"=="0" (
  echo ����WIFI�ɹ���ʹ����죡
  echo �����Ҫ������ֻ��������������������������в�ѡ����WIFI���ӡ�
) else (
  echo ��������WIFI�ȵ�ʧ�ܡ�
)
goto end

:start
netsh wlan start hostednetwork
if "%errorlevel%"=="0" (
  echo ����WIFI�ɹ���ʹ����죡
) else (
  echo ��������WIFI�ȵ�ʧ�ܡ�
)
goto end

:stop
netsh wlan stop hostednetwork
goto end

:password
set /p _password=������WIFI�ȵ�����루���裬���볤��Ϊ 8~63 �ַ�����
netsh wlan set hostednetwork key=%_password% > nul
if "%errorlevel%"=="0" (
  echo ����WIFI����ɹ���
) else (
  echo ���󣺸�������ʧ�ܡ�
  echo ������������벢���ԣ�����Ϊ 8-63 �ַ���
  goto menu
)
goto end

:view
netsh wlan show hostednetwork
goto end

:share
cscript /nologo %~dp0\share.vbs
goto end

:end
set _name=
set _password=
set mid=
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pause