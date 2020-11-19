@echo off
@chcp 65001 >NUL 2>NUL
setlocal
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
IF NOT %VERSION% == 10.0 (
    echo This script supports only Windows 10.
    pause
    exit
)
call :setESC

cls
echo.
echo.
echo.          Spotify 한글적용 시스템
echo.               %ESC%[107;36mby Pindang2%ESC%[0m
echo.
echo.
echo ============================================
echo %ESC%[107;36m#^>%ESC%[0m           Spotify를 찾는 중..

timeout 3 >NUL

IF exist "%appdata%\Spotify\prefs" ( 
    echo %ESC%[107;36m#^>%ESC%[0m%ESC%[92m Spotify 설정 파일을 찾았습니다. 
) else (
    cls
    echo ============================================
    echo.
    echo %ESC%[107;91m!^>%ESC%[0m Spotify 설정 파일을 찾을 수 없습니다. Windows에 Spotify를 설치하셨는지 확인해주세요.
    echo %ESC%[107;91m!^>%ESC%[0m Microsoft Store에서 설치하신 프로그램은 지원하지 않습니다.
    echo %ESC%[107;91m!^>%ESC%[0m%ESC%[96m spotify.com/us/download%ESC%[0m에서 받으신 공식 프로그램만 지원합니다.
    echo %ESC%[107;91m!^>%ESC%[0m Spotify 프로그램을 설치하셨다면, 프로그램 내 로그인을 필수로 진행해주세요.
    echo.
    echo ============================================
    echo.
    pause
    exit
)

timeout 2 >NUL

echo %ESC%[107;36m#^>%ESC%[0m Spotify 프로그램을 종료하는 중..
taskkill /f /im spotify.exe >NUL 2>NUL

cd %appdata%\Spotify

echo.
echo %ESC%[107;36m#^>%ESC%[0m 설정 파일을 읽는 중입니다.

powershell -Command "(gc prefs | Select-String '\"ko\"').length" > tmpa
set /p tmpa= < tmpa

IF %tmpa% == 1 ( 
    echo %ESC%[107;36m#^>%ESC%[0m language="ko"
    echo %ESC%[107;91m!^>%ESC%[0m 애플리케이션이 이미 한글입니다. 프로그램을 종료합니다.
    echo.
    echo ============================================
    echo.
    pause
    exit
) else (
    powershell -Command "(gc prefs | Select-String 'language').length" > tmpa
    set /p tmpa= < tmpa
)

IF %tmpa% == 0 (
    echo %ESC%[107;36m#^>%ESC%[0m%ESC%[91m language not exist
    echo %ESC%[107;36m#^>%ESC%[0m language="ko" 추가하는 중..
    echo language="ko" >> prefs
    echo %ESC%[107;36m#^>%ESC%[0m 설정 완료
    echo.
    timeout 3 >NUL
    echo ============================================
    echo.
    echo %ESC%[107;36m#^>%ESC%[0m 설정을 마쳤습니다. Spotify 프로그램을 실행해주세요.
    echo %ESC%[107;36m#^>%ESC%[0m Spotify 설치 또는 업데이트 프로그램이 1회 실행될 수 있습니다. 그래도 한글은 정상 적용됩니다.
    echo %ESC%[107;36m#^>%ESC%[0m 프로그램을 종료합니다. 감사합니다.
    echo.
    echo ============================================
    echo.
    pause
    del tmpa >NUL
    del tmpb >NUL
    exit
)


powershell -Command "(gc prefs | Select-String 'language') -replace \"\`n\",\", \" -replace \"\`r\",\", \"" > tmpa
set /p tmpa= < tmpa
echo %ESC%[107;36m#^>%ESC%[0m%ESC%[92m %tmpa%%ESC%[0m을 발견했습니다.
echo %ESC%[107;36m#^>%ESC%[0m%ESC%[92m %tmpa%%ESC%[0m가 문법에 맞는지 확인하는 중..
powershell -Command "([regex]::Matches((gc tmpa), \"`\"\" )).count" > tmpb
set /p tmpb= < tmpb

if NOT %tmpb:~2,1% == 2 (
    echo %ESC%[107;91m!^>%ESC%[0m%ESC%[93m 문법 검사를 통과하지 못했습니다.%ESC%[0m
    echo.
    echo ============================================
    echo.
    echo %ESC%[107;91m!^>%ESC%[0m 기존에 존재하던 설정 파일에 형식 또는 기본 설정이 잘못되어 있어 본 프로그램이 실행되지 않습니다.
    echo %ESC%[107;91m!^>%ESC%[0m%ESC%[95m 혹시 설정 파일을 임의로 수정하셨나요?%ESC%[0m 그랬을 경우에는 제대로 작성이 되지 않을 수 있습니다.
    echo %ESC%[107;91m!^>%ESC%[0m Spotify를 재 설치하시거나, 직접 설정 파일을 열고 language 항목 라인을 language="ko"로 바꿔주세요.
    echo %ESC%[107;91m!^>%ESC%[0m 프로그램을 종료합니다. 감사합니다.
    echo.
    echo ============================================
    echo.
    pause
    del tmpa >NUL
    del tmpb >NUL
    exit
)


echo %ESC%[107;36m#^>%ESC%[0m%ESC%[96m %tmpa%가 문법 검사를 통과했습니다.%ESC%[0m 다만, language="en"같은 형식이 아니라면 설정이 끝나고도 프로그램에 변화가 없을 것입니다.
echo %ESC%[107;36m#^>%ESC%[0m 파일 수정 스크립트를 만드는 중..
copy prefs prefsconfirm >NUL
echo @echo off > handle.bat
echo set /p tmpp= ^< tmpa >> handle.bat
echo powershell -Command "(gc prefs) -replace 'language=\"%%tmpp:~10,2%%\"', 'language=\"ko\"' | Out-File -encoding UTF8 prefs" >> handle.bat
echo del handle.bat  >> handle.bat
echo exit >> handle.bat
echo %ESC%[107;36m#^>%ESC%[0m%ESC%[93m 설정을 수정하는 중: %tmpa%를 language="ko"로%ESC%[0m
cmd /c "handle" >NUL 2>NUL
echo.
echo %ESC%[107;36m#^>%ESC%[0m 설정 완료
echo.
timeout 3 >NUL
echo %ESC%[107;36m#^>%ESC%[0m 성공 여부 확인하는 중..
fc prefs prefsconfirm | find /i "FC:" > tmpb
set /p tmpb= < tmpb
del prefsconfirm
if "%tmpb%" == "FC: no differences encountered" (
    echo %ESC%[107;36m#^>%ESC%[0m%ESC%[91m 실패%ESC%[0m
    timeout 3 >NUL
    echo ============================================
    echo.
    echo %ESC%[107;91m!^>%ESC%[0m Spotify 설정 파일을 수정하지 못했습니다. 문법 검사를 통과했으나, 형식 또는 기본 설정이 잘못되어 있습니다.
    echo %ESC%[107;91m!^>%ESC%[0m%ESC%[95m 혹시 설정 파일을 임의로 수정하셨나요?%ESC%[0m 그랬을 경우에는 제대로 작성이 되지 않을 수 있습니다.
    echo %ESC%[107;91m!^>%ESC%[0m Spotify를 재 설치하시거나, 직접 설정 파일을 열고 language 항목 라인을 language="ko"로 바꿔주세요.
    echo %ESC%[107;91m!^>%ESC%[0m 프로그램을 종료합니다. 감사합니다.
    echo.
    echo ============================================
    echo.
    pause
    del tmpa >NUL
    del tmpb >NUL
    del prefsconfirm >NUL
    exit
)
echo %ESC%[107;36m#^>%ESC%[0m%ESC%[96m 성공%ESC%[0m
timeout 3 >NUL
echo ============================================
echo.
echo %ESC%[107;36m#^>%ESC%[0m%ESC%[96m 설정을 마쳤습니다. Spotify 프로그램을 실행해주세요.%ESC%[0m
echo %ESC%[107;36m#^>%ESC%[0m Spotify 설치 또는 업데이트 프로그램이 1회 실행될 수 있습니다. 그래도 한글은 정상 적용됩니다.
echo %ESC%[107;36m#^>%ESC%[0m 프로그램을 종료합니다. 감사합니다.
echo.
echo ============================================
echo.
pause
del tmpa >NUL
del tmpb >NUL
del prefsconfirm >NUL
exit

:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)