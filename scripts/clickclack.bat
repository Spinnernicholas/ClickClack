:: ClickClack Script Framework .bat Entry Point
@echo off

set "core[version]=0.1.0"

if "%1"=="" (
    set "core[config_file]=clickclack.ini"
) else (
    set "core[config_file]=%~1"
)

:: clickclack.ini spec
:: Step 0: Ignore Comments
::  empty lines are ignored
::  lines starting with "#" or ";" are comments, and are ignored
:: Step 1: File Header (first 2 lines)
set rules[1.1]=rule 1.1: line 1 must have "v=0.1.0"
set rules[1.2]=rule 1.2: line 2 must start with "title="
:: Step 2: Valid Config Lines (every line after line 2, excluding comments)
set rules[2.1]=rule 2.1: lines must be in the format "key=value", value can be empty
set "rules[2.2]=rule 2.2: key must start with a letter"
set "rules[2.3]=rule 2.3: key must be alphanumeric, and can contain underscores"
:: Step 3: Parse Config Line (every line, including 1 and 2, excluding comments)
::  key is everything before the first "="
::  value is everything after the first "="

:: Syntax Error Template
:: "Config Error - Line $(line number): $(rule violated)"

:: register config var: set "core[config_vars]==%core[config_vars]=% %%a"
:: save config var: set "config[%%a]=%%b"


:: Load clickclack.ini
set "core[config_vars]="
set "line_number=0"

echo Loading Config File: %core[config_file]%

for /f "delims=" %%l in (%core[config_file]%) do (
    set /a line_number+=1
    set "line=%%l"

    echo "%%l"
    echo "%line%"
    set "ch0=%line:~0,1%"
)

echo Config Variables:
:: for each config var, print it config[var] value
for /f %%a in (%core[config_vars]%) do (
    echo  - "%%a": "%config[%%a]%"
)

exit /b

:: x-----------x
:: | Functions |
:: x-----------x

:: regex_match <string> <regex>
::  string: string to match
::  regex: regex to match against
::  returns: true if arg1 matches arg2, false otherwise
::  example: call :regex_match "hello" "h.*o" && echo "hello matches h.*o" || echo "hello does not match h.*o"
:regex_match
    echo %~1 | findstr /r /c:"%~2" >nul
    set /a "result=1-%errorlevel%"
    exit /b


    for /f "tokens=1,2 delims==" %%a in ("%line%") do (
        set "key=%%a"
        set "value=%%b"
    )

    call :regex_match "%line%" "^[#;]"
    if not %result% equ 1 (
        if %line_number% equ 1 (
            if not "%line%"=="v=%core[version]%" (
            echo Config Err: %rules[1.1]%
            echo %core[config_file]%^(%line_number%^): %line%
                exit /b 1
            )
        ) else if %line_number% equ 2 (
            if not "%line:~0,6%"=="title=" (
            echo Config Err: %rules[1.2]%
            echo %core[config_file]%^(%line_number%^): %line%
                exit /b 1
            )
        )

        call :regex_match "%ch0%" "^[a-zA-Z]"
        if not %result% equ 1 (
            echo Config Err: %rules[2.2]%
            echo %core[config_file]%^(%line_number%^): %line%
            exit /b 1
        )
        call :regex_match "%line%" "=.*$"
        if not %result% equ 1 (
            echo Config Err: %rules[2.3]%
            echo %core[config_file]%^(%line_number%^): %line%
            exit /b 1
        )
        call :regex_match "%line%" "^[a-zA-Z0-9_]*="
        if not %result% equ 1 (
            echo Config Err: %rules[2.1]%
            echo %core[config_file]%^(%line_number%^): %line%
            exit /b 1
        )

        set "config[%%a]=%%b"
        set "core[config_vars]==%core[config_vars]=% %%a"
    )