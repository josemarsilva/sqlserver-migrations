# #############################################################################
# filename:    sqlserver-migrations.ps1
# description: PowerShell script SQLServer Migrations Tools for upgrades and downgrades
# args[i]:
#              $args[0] Command
#              $args[1] Argument #1
#              $args[2] Argument #2
#              $args[3] Argument #3
# source-code: https://github.com/josemarsilva/sqlserver-migrations
# references :
# #############################################################################
#

# #############################################################################
# initializing ...
# #############################################################################
$release = "v.2020.05.22.1958"
$argCmd = $args[0]
$argCmdArg1 = $args[1]
$argCmdArg2 = $args[2]
$argCmdArg3 = $args[3]
if ($argCmd -eq $null) { $argCmd = "" }
if ($argCmdArg1 -eq $null) { $argCmdArg1 = "" }
if ($argCmdArg2 -eq $null) { $argCmdArg2 = "" }
if ($argCmdArg3 -eq $null) { $argCmdArg3 = "" }
$configRepositoryPath = ".sqlserver-migrations"
$configKeyValueCsvFile = "config-key-value.csv"
$historyFile = "history.csv"

Write-Host( "sqlserver-migrations - $release - SQLServer Database Management Tool for upgrades and downgrades scripts" )

# #############################################################################
# loading configuration (key,value) from (.csv) file sub-folder ...
# #############################################################################
$sqlcmdPath      = ""
$servername      = ""
$protocol        = ""
$port            = ""
$login           = ""
$password        = ""
$database        = ""
$prefixUpgrade   = ""
$prefixDowngrade = ""
# check configuration sub-folder and file ...
if ( Test-path ($configRepositoryPath + "\" + $configKeyValueCsvFile) ) {
    # Import-Csv
    $objConfigKeyValue = Import-Csv ($configRepositoryPath + "\" + $configKeyValueCsvFile) -Delimiter ";"
    # loading (key,values) ...
    $sqlcmdPath      = ( $objConfigKeyValue | Where-Object key -eq "sqlcmd-path"       | Select-Object value )[0].value
    $servername      = ( $objConfigKeyValue | Where-Object key -eq "servername"        | Select-Object value )[0].value
    $protocol        = ( $objConfigKeyValue | Where-Object key -eq "protocol"          | Select-Object value )[0].value
    $port            = ( $objConfigKeyValue | Where-Object key -eq "port"              | Select-Object value )[0].value
    $login           = ( $objConfigKeyValue | Where-Object key -eq "login"             | Select-Object value )[0].value
    $password        = ( $objConfigKeyValue | Where-Object key -eq "password"          | Select-Object value )[0].value
    $database        = ( $objConfigKeyValue | Where-Object key -eq "database"          | Select-Object value )[0].value
    $prefixUpgrade   = ( $objConfigKeyValue | Where-Object key -eq "prefix-upgrade"    | Select-Object value )[0].value
    $prefixDowngrade = ( $objConfigKeyValue | Where-Object key -eq "prefix-downgrade"  | Select-Object value )[0].value
}
# get history of upgrade and downgrade ...
if ( Test-path ($configRepositoryPath + "\" + $historyFile) ) {
    # Import-Csv
    $objHistory = Import-Csv ($configRepositoryPath + "\" + $historyFile) -Delimiter ";"
}

# #############################################################################
# Function Command-Help()
# #############################################################################
Function Command-Help
{
    Write-Host( "usage: sqlserver-migrations ( [ -h | help ] | [ -l | list ] | [ -u | upgrade ] | [ -d | downgrade ] | [ -s | setup ] | [ -i | install ] ) [ --cmd-args ] [ cmd-params ]" )
    Write-Host( "" )
    Write-Host( "       -h help      Show usefull command line help" )
    Write-Host( "       -l list      List command arguments and parameters" )
    Write-Host( "                    --upgrade   List upgrade scripts to be done" )
    Write-Host( "                    --downgrade List downgrade scripts to be done" )
    Write-Host( "                    --history   List downgrade and upgrade already done" )
    Write-Host( "                    --setup     List setup configuration values" )
    Write-Host( "       -u upgrade   Upgrade script's executions" )
    Write-Host( "       -d downgrade Downgrade script's executions" )
    Write-Host( "       -s setup     Setup current installation key/values with arguments and parameters" )
    Write-Host( "                    <key>     Key to setup" )
    Write-Host( "                    <value>   Value to setup" )
    Write-Host( "       -i install   Initialize setup configuration repository" )
    Write-Host( "" )
}

# #############################################################################
# Function Check-Config()
# #############################################################################
Function Check-Config
{
    # check configuration sub-folder and file ...
    if ( -Not (Test-path ($configRepositoryPath + "\" + $configKeyValueCsvFile) -PathType Leaf) ) {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations NOT installed yet!" )
		Write-Host( "       File '" + ($configRepositoryPath + "\" + $configKeyValueCsvFile) + "' is not present." )
		Write-Host( "       Try 'sqlserver-migrations install'!" )
        Write-Host( "" )
        exit 1 # error
    }
    # check history sub-folder and file ...
    if ( -Not (Test-path ($configRepositoryPath + "\" + $historyFile) -PathType Leaf) ) {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations NOT installed yet!" )
		Write-Host( "       File '" + ($configRepositoryPath + "\" + $historyFile) + "' is not present." )
		Write-Host( "       Try 'sqlserver-migrations install'!" )
        Write-Host( "" )
        exit 1 # error
    }
    # check configuration prefixUpgrade ...
    if ($servername -eq "") {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations setup configuration key value 'servername' can *NOT* be empty!" )
		Write-Host( "       Try 'sqlserver-migrations list --setup' " )
		Write-Host( "       Try 'sqlserver-migrations setup servername <put-value-here>' " )
        Write-Host( "" )
        exit 1 # error
    } elseif  ($login -eq "") {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations setup configuration key value 'login' can *NOT* be empty!" )
		Write-Host( "       Try 'sqlserver-migrations list --setup' " )
		Write-Host( "       Try 'sqlserver-migrations setup login <put-value-here>' " )
        Write-Host( "" )
        exit 1 # error
    } elseif  ($password -eq "") {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations setup configuration key value 'password' can *NOT* be empty!" )
		Write-Host( "       Try 'sqlserver-migrations list --setup' " )
		Write-Host( "       Try 'sqlserver-migrations setup password <put-value-here>' " )
        Write-Host( "" )
        exit 1 # error
    } elseif  ($database -eq "") {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations setup configuration key value 'database' can *NOT* be empty!" )
		Write-Host( "       Try 'sqlserver-migrations list --setup' " )
		Write-Host( "       Try 'sqlserver-migrations setup database <put-value-here>' " )
        Write-Host( "" )
        exit 1 # error
    } elseif  ($prefixUpgrade -eq "") {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations setup configuration key value 'prefix-upgrade' can *NOT* be empty!" )
		Write-Host( "       Try 'sqlserver-migrations list --setup' " )
		Write-Host( "       Try 'sqlserver-migrations setup prefix-upgrade <put-value-here>' " )
        Write-Host( "" )
        exit 1 # error
    } elseif ($prefixDowngrade -eq "") {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations setup configuration key value 'prefix-downgrade' can *NOT* be empty!" )
		Write-Host( "       Try 'sqlserver-migrations list --setup' " )
		Write-Host( "       Try 'sqlserver-migrations setup prefix-downgrade <put-value-here>' " )
        Write-Host( "" )
        exit 1 # error
    }
}

# #############################################################################
# Function Command-List()
# #############################################################################
Function Command-List
{
    # check command arguments ...
    if ($argCmdArg1.ToLower() -eq "--upgrade") {
        # check config ...
        Check-Config
        # List Command-Upgrade
        Command-Upgrade $True
    } elseif ($argCmdArg1.ToLower() -eq "--downgrade") {
        # check config ...
        # List Command-Downgrade
        Command-Downgrade $True
    } elseif ($argCmdArg1.ToLower() -eq "--history") {
        # check config ...
        Check-Config
        # Import-Csv history
		Write-Host( "" )
		Write-Host( "ScriptFilename                                     DateTime             Obs" )
		Write-Host( "-------------------------------------------------- -------------------- ------------------------" )
        $objHistory | ForEach-Object {
    		Write-Host( ($_.ScriptFilename +      "                                                  ").substring(0,49) + "  " + ($_.DateTime + "                    ").substring(0,20) + " " + $_.Obs  )
        }
    } elseif ($argCmdArg1.ToLower() -eq "--setup") {
        # Import-Csv config-key-valye
		Write-Host( "" )
		Write-Host( "key                  value                                              obs" )
		Write-Host( "-------------------- -------------------------------------------------- ------------------------" )
        $objConfigKeyValue | ForEach-Object {
    		Write-Host( ($_.key + "                    ").substring(0,19) + "  " + ($_.value + "                                                  ").substring(0,49) + " " + $_.obs  )
        }
    } else {
        Write-Host( "" )
        Write-Host( "ERROR: Command argument is missing or invalid!" )
		Write-Host( "       Try 'sqlserver-migrations list ' ( '--upgrade' | '--downgrade' | '--history' |  '--setup' )" )
        Write-Host( "" )
        exit 1 # error
    }
}

# #############################################################################
# Function Execute-Script()
# #############################################################################
Function Execute-Script ( $scriptName, $bList )
{
    # Extract filename, filetype and logfilename from $scriptName
    $scriptFileType = ""
    $scriptLogFilename = $scriptName + ".log"
    if ($scriptName.Length -gt 4) {
        $scriptFileType = $scriptName.Substring( $scriptName.Length - 4, 4 )
        $scriptLogFilename = $scriptName.Substring( 0, $scriptName.Length - 4 ) + ".log"
    }

    # Script Command Line  ...
    $scriptCmd = ""
    if ( $scriptFileType.ToLower() -eq ".sql" ) {
        $scriptCmd = $sqlcmdPath + "SQLCMD -S " + $protocol + $servername + " -d " + $database + " -U " + $login + " -P " + $password + " -e " + " -i " + $scriptName + " -o " + $scriptLogFilename
    } elseif ( $scriptFileType.ToLower() -eq ".bat" ) {
        $scriptCmd = $scriptName + " > " + $scriptLogFilename
    } else {
        $scriptCmd = "ECHO ERROR NOT implemented " + $scriptName
    }
    Write-Host ( $scriptCmd )
    if ( -not $bList ) {
        cmd.exe /c ( $scriptCmd )
        Get-Content -Path $scriptLogFilename
        Add-Content ($configRepositoryPath + "\" + $historyFile) ( $scriptName + ";" + (Get-Date).ToString() + ";" )

    }

}

# #############################################################################
# Function Command-Upgrade( $bList )
# #############################################################################
Function Command-Upgrade( $bList )
{
    Check-Config
    Write-Host( "" )
    Get-ChildItem -Path . -Filter ($prefixUpgrade + "*")  | Where-Object { $_.Name -Like '*.sql' -or $_.Name -Like '*.bat' } | Sort-Object -Property Name | ForEach-Object {
        # Iterator
        $name = $_.Name
        $count = $objHistory | Where-Object {$_.ScriptFilename -eq $name }
        if ( $count -eq $null ) {
            Execute-Script $_.Name $bList
        }
    }
}

# #############################################################################
# Function Command-Downgrade()
# #############################################################################
Function Command-Downgrade( $bList )
{
    Check-Config
    Write-Host( "" )
    Get-ChildItem -Path . -Filter ($prefixDowngrade + "*")  | Where-Object { $_.Name -Like '*.sql' -or $_.Name -Like '*.bat' } | Sort-Object -Property Name | ForEach-Object {
        # Iterator
        $name = $_.Name
        $count = $objHistory | Where-Object {$_.ScriptFilename -eq $name }
        if ( $count -eq $null ) {
            Execute-Script $_.Name $bList
        }
    }
}

# #############################################################################
# Function Command-Setup()
# #############################################################################
Function Command-Setup
{
    # check command arguments ...
    if ($argCmdArg1.ToLower() -ne "") {
        # check configuration sub-folder and file ...
        if ( -Not (Test-path ($configRepositoryPath + "\" + $configKeyValueCsvFile) -PathType Leaf) ) {
            Write-Host( "" )
            Write-Host( "ERROR: sqlserver-migrations NOT installed yet!" )
			Write-Host( "       Try 'sqlserver-migrations install'" )
            Write-Host( "" )
            exit 1 # error
        }
        # get correspondent key/value ...
        if ( $argCmdArg1.ToLower() -eq "sqlcmd-path" ) {
            $sqlcmdPath      = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "servername" ) {
            $servername      = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "protocol" ) {
            $protocol        = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "port" ) {
            $port            = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "login" ) {
            $login           = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "password" ) {
            $password        = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "database" ) {
            $database        = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "prefix-upgrade" ) {
            $prefixUpgrade   = $argCmdArg2
        } elseif ( $argCmdArg1.ToLower() -eq "prefix-downgrade" ) {
            $prefixDowngrade = $argCmdArg2
        } else {
            Write-Host( "" )
            Write-Host( "ERROR: Command argument is missing or invalid!" )
			Write-Host( "       Try 'sqlserver-migrations setup ' ( sqlcmd-path | servername | protocol | port | login | password | database | prefix-upgrade | prefix-downgrade )" )
            Write-Host( "" )
            exit 1 # error
        }
        # write back configuration ...
        ( "key"              + ";" + "value"          + ";" + "obs" ) | Out-File         ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "sqlcmd-Path"      + ";" + $sqlcmdPath      + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "servername"       + ";" + $servername      + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "protocol"         + ";" + $protocol        + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "port"             + ";" + $port            + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "login"            + ";" + $login           + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "password"         + ";" + $password        + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "database"         + ";" + $database        + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "prefix-upgrade"   + ";" + $prefixUpgrade   + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        ( "prefix-downgrade" + ";" + $prefixDowngrade + ";" + ""    ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
        # done
        Write-Host( "" )
        Write-Host( "SUCCESS: sqlserver-migrations (key/value) setup!" )
		Write-Host( "         Try 'sqlserver-migrations list setup for more !' " )
        Write-Host( "" )

    } else {
        Write-Host( "" )
        Write-Host( "ERROR: Command argument is missing or invalid!" )
		Write-Host( "       Try sqlserver-migrations setup <key> [ <value> ]" )
        Write-Host( "" )
        exit 1 # error
    }
}

# #############################################################################
# Function Command-Install()
# #############################################################################
Function Command-Install
{
    # check configuration sub-folder and file ($configRepositoryPath + "\" + $configKeyValueCsvFile) ...
    if ( Test-path ($configRepositoryPath + "\" + $configKeyValueCsvFile) -PathType Leaf ) {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations IS ALREADY installed!" )
		Write-Host( "       File '" + ($configRepositoryPath + "\" + $configKeyValueCsvFile) + "' is present! " )
		Write-Host( "       Try 'sqlserver-migrations list --setup' !" )
        Write-Host( "" )
        exit 1 # error
    }
    # check configuration sub-folder and file ($configRepositoryPath + "\" + $historyFile) ...
    if ( Test-path ($configRepositoryPath + "\" + $historyFile) -PathType Leaf ) {
        Write-Host( "" )
        Write-Host( "ERROR: sqlserver-migrations IS ALREADY installed!" )
		Write-Host( "       File '" + ($configRepositoryPath + "\" + $historyFile) + "' is present! " )
		Write-Host( "       Try 'sqlserver-migrations list --setup' !" )
        Write-Host( "" )
        exit 1 # error
    }
    # create installation sub-folder ...
    if ( -Not (Test-Path -Path $configRepositoryPath) ) {
        New-Item -ItemType Directory -Force -Path $configRepositoryPath | Out-Null
    }
    # create installation file ($configRepositoryPath + "\" + $configKeyValueCsvFile) ...
    ( "key"              + ";" + "value"       + ";" + "obs") | Out-File         ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "sqlcmd-path"      + ";" + ""            + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "servername"       + ";" + "localhost"   + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "protocol"         + ";" + ""            + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "port"             + ";" + ""            + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "login"            + ";" + "user"        + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "password"         + ";" + "password123" + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "database"         + ";" + "master"      + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "prefix-upgrade"   + ";" + "upgrade-"    + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    ( "prefix-downgrade" + ";" + "downgrade-"  + ";" + ""   ) | Out-File -Append ($configRepositoryPath + "\" + $configKeyValueCsvFile)
    # create installation file ($configRepositoryPath + "\" + $historyFile) ...
    ( "ScriptFilename"              + ";" + "DateTime"       + ";" + "obs" + "\n" ) | Out-File         ($configRepositoryPath + "\" + $historyFile)
    Write-Host( "" )
    Write-Host( "SUCCESS: sqlserver-migrations installed!" )
	Write-Host( "         File '.sqlserver-migrations\config-key-value.csv' created." )
	Write-Host( "         File '.sqlserver-migrations\history.csv' created." )
    Write-Host( "" )
}

# #############################################################################
# main() ...
# #############################################################################

if ($argCmd.ToLower() -eq "-h" -or $argCmd.ToLower() -eq "help") {
    Command-Help
} elseif ($argCmd.ToLower() -eq "-l" -or $argCmd.ToLower() -eq "list") {
    Command-List
} elseif ($argCmd.ToLower() -eq "-u" -or $argCmd.ToLower() -eq "upgrade") {
    Command-Upgrade $False
} elseif ($argCmd.ToLower() -eq "-d" -or $argCmd.ToLower() -eq "downgrade") {
    Command-Downgrade $False
} elseif ($argCmd.ToLower() -eq "-s" -or $argCmd.ToLower() -eq "setup") {
    Command-Setup
} elseif ($argCmd.ToLower() -eq "-i" -or $argCmd.ToLower() -eq "install") {
    Command-Install
} else {
    Write-Host( "" )
    Write-Host( "ERROR: Command argument is missing!" )
	Write-Host( "       Try help 'sqlserver-migrations -h' ")
    Write-Host( "" )
    exit 1 # error
}
# exit success ...
exit 0
