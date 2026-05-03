@echo off
setlocal enabledelayedexpansion

:reload
if not exist "data" mkdir "data"
if not exist "events" mkdir "events"
if not exist "data/url.dat" (echo https://tu-url-aqui.com > "data/url.dat")
if not exist "data/dir.dat" (echo DownloadedMusic > "data/dir.dat")
if not exist "data/wait.dat" (echo 30 > "data/wait.dat")
for /f "usebackq tokens=*" %%a in ("data/url.dat") do set "url=%%a"
for /f "usebackq tokens=*" %%a in ("data/dir.dat") do set "dir=%%a"
for /f "usebackq tokens=*" %%a in ("data/wait.dat") do set "wait=%%a"

:main
title AutoDJPlaylist - Menu
cls
echo ===========================================
echo ============   AutoDJ Playlist   ==========
echo ===========================================
echo Configuracion Actual
echo URL:  %url%
echo DIR:  %dir%
echo WAIT: %wait%seg
echo ===========================================
echo 1. Start now
echo 2. Config
echo 3. Exit
echo ===========================================
set /p opt="Inserta tu opcion: "

if "%opt%"=="1" goto start
if "%opt%"=="2" goto cfg
if "%opt%"=="3" goto exit_confirm
cls
echo Opcion Invalida
pause
goto main

:exit_confirm
title AutoDJPlaylist - Exit
set /p sureexit="Escribe "yes" si estas seguro/a: "
if /i "%sureexit%"=="yes" exit
goto main

:start
cls
python --version >nul 2>&1
if %errorlevel% neq 0 (
    title AutoDJPlaylist - ERROR
    echo [ERROR] Python no esta instalado o no esta en el PATH.
    echo En la carpeta Tutorial Instalar Python podras ver como instalarlo.
    echo En caso de tenerlo instalarlo debes ponerlo en PATH, busca un tutorial.
    pause >nul
    cls
    exit
)
if not exist "%dir%" mkdir "%dir%"
del /f /q "events\stop.now" 2>nul
cls
echo ===========================================
echo Configuracion Actual
echo URL:  %url%
echo DIR:  %dir%
echo WAIT: %wait%segs
echo ===========================================
title AutoDJPlaylist - Activo
python main.py
exit

:cfg
title AutoDJPlaylist - Configuracion
cls
echo ===========================================
echo ============   Configuracion   ============
echo ===========================================
echo 1. URL
echo 2. DIR
echo 3. WAIT
echo 4. Volver
set /p opt="Inserta tu opcion: "
if "%opt%"=="1" goto URL
if "%opt%"=="2" goto DIR
if "%opt%"=="3" goto WAIT
if "%opt%"=="4" goto main
cls
echo Opcion Invalida
pause
goto cfg

:URL
cls
echo ===========================================
echo URL ACTUAL: %url%
echo La playlist debe de ser de YouTube
echo ESCRIBE 0 PARA CANCELAR
echo ===========================================
set "user_url="
set /p "user_url=Introduce la URL de YouTube: "
if "%user_url%"=="0" goto main
if "%user_url%"=="" goto URL
echo "%user_url%" | findstr /i "list=" >nul
if %errorlevel% equ 0 (
    set "url=%user_url%"
    (echo %user_url%) > "data/url.dat"
    pause
    goto main
) else (
    echo [ERROR] No es una Playlist valida.
    pause
    goto URL
)

:DIR
cls
echo ===========================================
echo DIR ACTUAL: %dir%
echo ESCRIBE 0 PARA CANCELAR
echo ===========================================
set /p "user_dir=Nuevo nombre de carpeta: "
if "%user_dir%"=="0" goto main
set "dir=%user_dir%"
echo %dir% > "data/dir.dat"
echo [OK] Carpeta actualizada.
pause
goto main

:WAIT
cls
echo ===========================================
echo WAIT ACTUAL: %wait% seg
echo Se recomienda mas de 7 segundos
echo ESCRIBE 0 PARA CANCELAR
echo ===========================================
set /p "user_wait=Nuevo tiempo de espera: "
if "%user_wait%"=="0" goto main
set /a "test_num=%user_wait%" 2>nul
if "%test_num%"=="%user_wait%" (
    set "wait=%user_wait%"
    echo %wait% > "data/wait.dat"
    echo [OK] Tiempo actualizado.
    pause
    goto main
) else (
    echo [ERROR] Ingresa solo numeros enteros.
    pause
    goto WAIT
)