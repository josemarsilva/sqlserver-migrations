@ECHO OFF
REM ---------------------------------------------------------------------------
REM filename  : sqlserver-migrations
REM repository: https://github.com/josemarsilva/sqlserver-migrations
SET RELEASE=v.2020.05.14.1050
REM ---------------------------------------------------------------------------
REM 

REM ---------------------------------------------------------------------------
REM 
REM ---------------------------------------------------------------------------
REM Initialize ...
SET STATUS_CODE=0
SET STATUS_MSG= 

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
REM Starting ...
SET ARG_1=%1
SET ARG_2=%2
SET ARG_3=%3
ECHO.
ECHO sqlserver-migrations - %RELEASE% - SQLServer Database management tool for scripts upgrades and downgrades

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
REM Switch command Of ...
IF "%1" == "" (
	CALL :CommandHelp
) ELSE (
	IF "%1" == "-h" (
		CALL :CommandHelp
	) ELSE (
		IF "%1" == "list" (
			CALL :CommandList
		) ELSE (
			IF "%1" == "upgrade" (
				CALL :CommandUpgrade
			) ELSE (
				IF "%1" == "downgrade" (
					CALL :CommandDowngrade
				) ELSE (
					IF "%1" == "setup" (
						CALL :CommandSetup
					) ELSE (
						IF "%1" == "install" (
							CALL :CommandInstall
						) ELSE (
							SET STATUS_CODE=1
							CALL :CommandError
						)
					)
				)
			)
		)
	)
)

REM others ...
GOTO EndOfBatScript


REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandHelp

ECHO usage: sqlserver-migrations [ -h ] [ list ] [ upgrade ] [ downgrade ] [ setup ^<key^> ^<value^> ]
ECHO.
ECHO        -h        Help
ECHO        list      List upgrade and downgrade scripts
ECHO                  --upgrade   List only upgrade scripts
ECHO                  --downgrade List only downgrade scripts
ECHO                  --setup     List only setup configuration values
ECHO        upgrade   Upgrade script's executions prefixed by "sqlserver-migrations-upgrade-"
ECHO        downgrade Downgrade script's executions prefixed by "sqlserver-migrations-downgrade-"
ECHO        setup     Setup current installation and configuration key/value
ECHO                  --key   ^<key^>
ECHO                  --value ^<value^>
ECHO        install   Initialize setup configuration repository
ECHO.

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandList

ECHO.
ECHO Command List
ECHO.
CALL :GetConfig

EXIT /B


REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandUpgrade

ECHO.
ECHO Command Upgrade
ECHO.

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandDowngrade

ECHO.
ECHO Command Downgrade
ECHO.

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandSetup

ECHO.
ECHO Command Setup
ECHO.
CALL :GetConfig
REM Configuration file exists ?
IF "%STATUS_CODE%" == "0" (
	REM Yes! Exists
	SET STATUS_CODE=0
	SET STATUS_MSG=NULL
) ELSE (
	REM No! Does not exists
	SET STATUS_CODE=1
	SET STATUS_MSG=ERROR: sqlserver-migrations not installed yet! Use argument 'install'
)

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandInstall

CALL :GetConfig
REM Configuration file exists ?
IF NOT "%STATUS_CODE%" == "0" (
	REM No! Does not exists yet, let's create it ...
	SET STATUS_CODE=0
	SET STATUS_MSG=NULL
	IF NOT EXIST "%CONFIG_REPOSITORY_PATH%" (
		MD %CONFIG_REPOSITORY_PATH%
	)
 	ECHO # %CONFIG_REPOSITORY_PATH% was automatically created by sqlserver-migrations.bat > %CONFIG_REPOSITORY_PATH%\%CONFIG_FILE%
 	ECHO SQLCMD_PATH= >> %CONFIG_REPOSITORY_PATH%\%CONFIG_FILE%
 	ECHO SERVERNAME=  >> %CONFIG_REPOSITORY_PATH%\%CONFIG_FILE%
 	ECHO LOGIN=       >> %CONFIG_REPOSITORY_PATH%\%CONFIG_FILE%
 	ECHO PASSWORD=    >> %CONFIG_REPOSITORY_PATH%\%CONFIG_FILE%
) ELSE (
 	REM Yes! Exists ...
	SET STATUS_CODE=1
	SET STATUS_MSG=ERROR: sqlserver-migrations already installed. Use argument 'setup'
)

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:CommandError

SET STATUS_CODE=1
SET STATUS_MSG=ERROR: Command '%ARG_1%' is unrecognized! Use argument '-h' for help

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:GetConfig

REM ECHO GetConfig()
SET CONFIG_REPOSITORY_PATH=.sqlserver-migrations
SET CONFIG_FILE=config.txt
IF NOT EXIST "%CONFIG_REPOSITORY_PATH%\%CONFIG_FILE%" (
	SET STATUS_CODE=1
	SET STATUS_MSG=ERROR: sqlserver-migrations not installed yet. Use argument 'install'
)

EXIT /B

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
:EndOfBatScript

IF NOT "%STATUS_CODE%" == "0" (
	ECHO.
	ECHO STATUS_CODE: %STATUS_CODE% %STATUS_MSG%
	ECHO.
)

REM ---------------------------------------------------------------------------
REM
REM ---------------------------------------------------------------------------
