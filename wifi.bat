<!-- : Begin batch script
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
TITLE WiFi Sharing Menu: Fools Edition
COLOR 17
ECHO.

	REM WiFi Sharing Menu for Windows
	REM Requires Administrator permissions
	REM Only tested on Windows 7 & 10(English version)
	REM This tool can create, start and stop a virtual WiFi access point.
	REM The virtual WLAN AP can be used with any mobile device, etc.
	REM Your WIFI adapter must support Ad-Hoc mode(Intel MyWiFi), most support it.
	REM "Microsoft Virtual WiFi Miniport Adapter" will show in Network Connections
	REM ^(Run ncpa.cpl in a run/command prompt)

	NET FILE >NUL 2>&1
	IF NOT "%ERRORLEVEL%" == "0" (
		ECHO Administrator permission is required^!
		ECHO Please click [Yes] on the UAC dialog.
		TIMEOUT 5
		cscript //nologo "%~f0?.wsf" //job:Admin
		GOTO :EXIT
	)

	IF "%~1" == "" GOTO :MENU
	CALL :%~1 2>NUL
	IF "%ERRORLEVEL%" == "1" (
		ECHO Syntax: %~nx0 [Option]
		ECHO    [create, start, stop, view ,password ,help]
		ECHO.

		ECHO Copyright (C) 2013 Kingron <kingron@163.com>
		ECHO Edits Sub-Licensed by Fooly Cooly
		ECHO Licensed with MIT https://opensource.org/licenses/MIT
		ECHO Sub-Licensed with GPL v3 https://www.gnu.org/licenses/gpl-3.0.txt
		ECHO.
	)
	PAUSE
	GOTO :EXIT

	:MENU
	REM Show WiFi Sharing Menu
	CLS
	ECHO   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ECHO   ^|      WiFi Sharing Menu     ^|
	ECHO   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ECHO   ^|  1. Create virtual WLAN    ^|
	ECHO   ^|  2. Start virtual WLAN     ^|
	ECHO   ^|  3. Stop virtual WLAN      ^|
	ECHO   ^|  4. View WLAN connections  ^|
	ECHO   ^|  5. Change WLAN password   ^|
	ECHO   ^|  6. Share Connection(ICS)  ^|
	ECHO   ^|  7. Exit                   ^|
	ECHO   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	ECHO.

	REM If calling a label fails ERRORLEVEL is set to 1 and the below message appears
	IF "%ERRORLEVEL%" == "1" ECHO Error: Invalid command, please try again.

	REM Clear the value from last selection
	CALL SET SLC=
	
	REM Prompt user for input
	SET /p SLC=Select a number and press ^<ENTER^>:
	
	REM Call user chosen label, pause and reshow menu
	CALL :%SLC% 2>NUL
	IF "%SLC%" == "7" GOTO :EXIT
	PAUSE
	GOTO :MENU

	:1
	:CREATE
		ECHO.
		ECHO NOTE:
		ECHO The "create virtual WLAN" command only run once if success, you needn't run it
		ECHO again unless you want to change the SSID or password!
		ECHO.

		REM if you want to use this for other language, you should change below tags.
		REM CP 936 = Chinese, 437 = English
		ECHO Check your WIFI adapter...
		SET supported=0
		NETSH wlan show drive | find "支持的承载网络" | find "是"
		IF %errorlevel%==0 set supported=1
		NETSH wlan show drive | find "Hosted network supported" | find "Yes"
		IF %errorlevel%==0 set supported=1
		IF %supported% equ 1 (
			ECHO Congratulation! You WIFI adapter support Ad-Hoc mode.
			ECHO Please follow step to finish the setup.
		) ELSE (
			ECHO Oops! You WIFI adapter can't support Ad-Hoc mode^(hostednetwork^).
			EXIT /b 1
		)
		IF "%_name%"=="" SET _name=wlan
		SET /p _name=Please input the virtual AP name(default: %_name%):
		SET /p _password=Please input the password^(required, length: 8~63^):
		NETSH wlan set hostednetwork mode=allow ssid=%_name% key=%_password%
		IF "%errorlevel%"=="0" ECHO Setup the WLAN success.
		NETSH wlan start hostednetwork
		IF "%errorlevel%"=="0" (
			ECHO Startup WLAN success, enjoy it!
			ECHO Please goto control panel, network connections, share the internet connection
			ECHO to virtual WIFI adapter.
		) ELSE ECHO Error: Started WLAN failure.
		GOTO :EOF

	:2
	:START
		REM Start WiFi AP and check if it errored
		NETSH wlan start hostednetwork
		IF "%ERRORLEVEL%"=="0" (
			ECHO WLAN startup success, enjoy it!
		) ELSE ECHO Error: Starting WLAN failed.
		GOTO :EOF

	:3
	:STOP
		REM Stop WiFi Access Point
		NETSH wlan stop hostednetwork
		GOTO :EOF

	:4
	:VIEW
		REM Show WiFi Access Points
		NETSH wlan show hostednetwork
		GOTO :EOF

	:5
	:PASSWORD
		SET /p _password=Please input the password^(required, length: 8~63^):
		NETSH wlan set hostednetwork key=%_password% > nul
		IF NOT "%ERRORLEVEL%" == "0" (
			ECHO Error: Changing WLAN password failed.
			ECHO Please check input and try again.
		) ELSE ECHO Change WLAN password success!
		GOTO :EOF

	:6
	:SHARE
		REM Runs the internal vbscript to share connections
		cscript //nologo "%~f0?.wsf" //job:Share
		GOTO :EOF

:EXIT
REM Clean up of settings
ENDLOCAL
TITLE Command Prompt
COLOR 7
CLS
EXIT /B

----- Begin wsf script --->
<package>
  <job id="Admin">
    <script language="VBScript">
		File = Left(WScript.ScriptName, Len(WScript.ScriptName) -5)
		Set UAC = CreateObject("Shell.Application")
		UAC.ShellExecute "cmd", "/C " & File, "", "runas", 1
	</script>
  </job>
  <job id="Share">
    <script language="VBScript">
		dim pub, prv, idx

		ICSSC_DEFAULT         = 0
		CONNECTION_PUBLIC     = 0
		CONNECTION_PRIVATE    = 1
		CONNECTION_ALL        = 2

		set NetSharingManager = Wscript.CreateObject("HNetCfg.HNetShare.1")

		wscript.echo "No.   Name" & vbCRLF & "------------------------------------------------------------------"
		idx = 0
		set Connections = NetSharingManager.EnumEveryConnection
		for each Item in Connections
			idx = idx + 1
			set Connection = NetSharingManager.INetSharingConfigurationForINetConnection(Item)
			set Props = NetSharingManager.NetConnectionProps(Item)
			szMsg = CStr(idx) & "     " & Props.Name
			wscript.echo szMsg
		next
		wscript.echo "------------------------------------------------------------------"
		wscript.stdout.write "Select public connection(for internet access) No.: "
		pub = cint(wscript.stdin.readline)
		wscript.stdout.write "Select private connection(for share users) No.: "
		prv = cint(wscript.stdin.readline)
		if pub = prv then
		  wscript.echo "Error: Public can't be same as private!"
		  wscript.quit
		end if

		idx = 0
		set Connections = NetSharingManager.EnumEveryConnection
		for each Item in Connections
			idx = idx + 1
			set Connection = NetSharingManager.INetSharingConfigurationForINetConnection(Item)
			set Props = NetSharingManager.NetConnectionProps(Item)
			if idx = prv then Connection.EnableSharing CONNECTION_PRIVATE
			if idx = pub then Connection.EnableSharing CONNECTION_PUBLIC
		next
	</script>
  </job>
</package>
