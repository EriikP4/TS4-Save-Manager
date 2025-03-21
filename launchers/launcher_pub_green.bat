@echo off
chcp 65001>NUL
title TS4 Save Manager
mode con:cols=70 lines=15
color 0A
powershell exit
set dspver=1.0.0
set dspvar=pub
set colvar=green
set github_link=https://github.com/EriikP4/TS4-Save-Manager
set error_wiki_link=https://github.com/EriikP4/TS4-Save-Manager/blob/main/error_codes.md#
set version_link=https://raw.githubusercontent.com/EriikP4/TS4-Save-Manager/refs/heads/main/data/s4mp_latest_link.txt
:CHECKING_SIMS_PATH
IF EXIST "%CD%\Game\Bin\TS4_x64.exe" (
    goto CHECKING_FIRST_INIT
) ELSE (
    set error_desc=No se encuentra "TS4_x64.exe".
    set error_code=CRITICAL_TS4_NOT_FOUND
    set error_reas=Instalación en directorio erróneo.
    goto ERROR
)

:CHECKING_FIRST_INIT
IF EXIST "%CD%\launcher_data\first_init.txt" (
    set /p first_init=<"%CD%\launcher_data\first_init.txt"
) ELSE (
    set error_desc=No se ha detectado la configuración inicial.
	set error_code=MISSING_FIRST_INIT_NOT_FOUND
	set error_reas=Instalación incorrecta del launcher. Visita GitHub para más información.
	goto error
)
if "%first_init%"=="true" goto first_init
if "%first_init%"=="false" goto CHECKING_S4MP_PATH_SILENT
pause

:CHECKING_S4MP_PATH_SILENT
IF EXIST "mp_launcher.exe" (
	set checkmpstatus=               
	set launcherstatus=OK
) ELSE (
	set checkmpstatus=[no disponible]
	set launcherstatus=FAIL
)
goto CHECKING_FOLDERS

:CHECKING_FOLDERS
IF EXIST "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4" (
    GOTO UNSAVED_FOLDER
) ELSE (
    GOTO MENU
)

:MENU
cls
color 0A
mode con:cols=43 lines=20
echo Cargando datos...
set /p savename_s0=<"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0\SaveName.txt"
set /p savecode_s0=<"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0\SaveCode.txt"
set /p savename_m0=<"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0\SaveName.txt"
set /p savecode_m0=<"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0\SaveCode.txt"
cls
echo +=========================================+
echo .     TS4  Save Manager        v%dspver%-%dspvar% .
echo +=========================================+
echo .                                         .
echo .  1) Principal...                        .
echo .                                         .
echo .  2) Multijugador...     %checkmpstatus% .
echo .                                         .
echo .                                         .
echo .                                         .
echo .  f) Carpeta Electronic Arts             .
echo .                                         .
echo .  u) Actualizar...                       .
echo .                                         .
echo .  g) GitHub                              .
echo .                                         .
echo .  x) Salir                               .
echo .                                         .
echo +=========================================+
choice /C 12fugx /N /M ">"
		if %ErrorLevel%==1 (set savename=%savename_s0%) & (set save=%savecode_s0%) & goto SOLO
		if %ErrorLevel%==2 (set savename=%savename_m0%) & (set save=%savecode_m0%) & goto MULTIPLAYER
		if %ErrorLevel%==3 explorer.exe "%USERPROFILE%\Documents\Electronic Arts" & goto MENU
		if %ErrorLevel%==4 goto update
		if %ErrorLevel%==5 start %github_link% & goto MENU
		if %ErrorLevel%==6 exit

:SOLO
cls
mode con:cols=58 lines=14
cls
echo +========================================================+
echo .                 Partida   Seleccionada                 .
echo +========================================================+
echo .                                                        
echo .  Partida: %savename%
echo .                                                       
echo .  Código de partida: %save%
echo .                                                        
echo .                                                        
echo .  i) Iniciar
echo .  c) Cancelar                                         
echo .                                                        
echo +========================================================+
choice /C ic /N /M ">"
	if %ErrorLevel%==1 goto START_OFFLINE
	if %ErrorLevel%==2 goto CHECKING_S4MP_PATH_SILENT
:START_OFFLINE
cls
echo Renombrando carpeta...
:ren_solo
ren "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_%save%" "Los Sims 4"
if %errorlevel%==1 set error_desc=Error al renombrar la carpeta & set error_code=CRITICAL_CANT_RENAME_FOLDER & set error_reas=La carpeta está siendo usada por otro proceso. Cierra todas las carpetas que tengas abiertas y vuelve a intentarlo. & goto error
timeout 1 >NUL
echo Iniciando The Sims 4...
start /wait Game\Bin\TS4_x64.exe
cls
echo Sesión finalizada
timeout 1 >NUL
goto EXITING

:MULTIPLAYER
cls
IF %LAUNCHERSTATUS%==OK (
	GOTO S4MP_OK
)
:S4MP_FAIL
set error_desc=S4MP no está instalado.
set error_code=MISSING_S4MP_NOT_INSTALLED
set error_reas=S4MP no está instalado/situado en la carpeta del juego.
goto error
:S4MP_OK
cls
mode con:cols=58 lines=15
cls
echo +========================================================+
echo .                 Partida   Seleccionada                 .
echo +========================================================+
echo .                                                        
echo .  Partida: %savename%
echo .                                                       
echo .  Código de partida: %save%
echo .                                                        
echo .                                                        
echo .  i) Iniciar
echo .  e) Entrar sin S4MP (para editar la partida)
echo .  c) Cancelar
echo .                                                        
echo +========================================================+
choice /C iec /N /M ">"
	if %ErrorLevel%==1 goto START_ONLINE
	if %ErrorLevel%==2 goto START_OFFLINE
	if %ErrorLevel%==3 goto CHECKING_S4MP_PATH_SILENT
:START_ONLINE
cls
echo Renombrando carpeta...
ren "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_%save%" "Los Sims 4"
if %errorlevel%==1 set error_desc=Error al renombrar la carpeta & set error_code=CRITICAL_CANT_RENAME_FOLDER & set error_reas=La carpeta está siendo usada por otro proceso. Cierra todas las carpetas que tengas abiertas y vuelve a intentarlo. & goto error
timeout 1 >NUL
echo Iniciando S4MP Launcher
goto S4MP_START
:S4MP_RESTART
echo Reiniciando S4MP Launcher
:S4MP_START
start /wait mp_launcher.exe
echo Sesión finalizada
timeout 1 >NUL
echo Asegurando que la carpeta de datos quede libre...
timeout 3 >NUL
echo Carpeta desbloqueada
timeout 1 >NUL
choice /c SN /N /M "¿Quieres re-abrir S4MP? [S/N]"
	if %ErrorLevel%==1 goto S4MP_RESTART
	if %ErrorLevel%==2 goto EXITING

:EXITING
echo Renombrando carpeta...
ren "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4" "Los Sims 4_%save%"
if %errorlevel%==1 set error_desc=Error al renombrar la carpeta & set error_code=CRITICAL_CANT_RENAME_FOLDER & set error_reas=La carpeta está siendo usada por otro proceso. Cierra todas las carpetas que tengas abiertas y vuelve a intentarlo. & goto error
timeout 1 >NUL
echo Saliendo...
timeout 1 >NUL
exit

:update
mode con:cols=43 lines=14
cls
echo +=========================================+
echo .              Actualizar...              .
echo +=========================================+
echo .                                         .
echo .  s) Actualizar S4MP                     .
echo .                                         .
echo .  l) Actualizar Launcher      [no disp.] .
echo .                                         .
echo .                                         .
echo .                                         .
echo .  b) Atrás...                            .
echo .                                         .
echo +=========================================+
choice /C bs /N /M ">"
		if %ErrorLevel%==1 goto MENU
		if %ErrorLevel%==2 goto download_s4mp
exit
:first_init
mode con:cols=27 lines=7
cls
echo /// Sims 4 Save Manager \\\
echo \\\       by Erik       ///
echo ---------------------------
echo Versión : %dspver%
echo Variante: %dspvar% // %colvar%
echo [ENTER] Iniciar...
pause >NUL
cls
mode con:cols=58 lines=14
echo Bienvenido al gestor de guardados!
timeout 1 >NUL
echo ----------------------------------------------------
echo Esta es la primera versión PÚBLICA de este Launcher
timeout 1 >NUL
echo ----------------------------------------------------
echo Puede que el Launcher contenga errores, si es así
echo por favor repórtalos en GitHub, sería de gran ayuda.
timeout 1 >NUL
echo ----------------------------------------------------
echo Pulsa cualquier tecla para continuar...
pause >NUL
cls
echo Ahora pasarás por la configuración inicial necesaria
echo para que todo funcione correctamente.
echo Pulsa cualquier tecla para continuar...
pause >NUL
cls
mode con:cols=58 lines=14
echo +========================================================+
echo .                Asistente de Instalación                .
echo +========================================================+
echo .                    [-]  ALERTA  [-]                    .
echo .                                                        .
echo .    Este programa gestionará tus partidas guardadas     .
echo .       en el juego. No se recomienda hacer ningún       .
echo .        cambio manualmente a menos que sepas qué        .
echo .              qué es lo que estás haciendo              .
echo .                                                        .
echo +========================================================+
echo . [C] Continuar                                [X] Salir .
echo +========================================================+
choice /C cx /N /M ">"
	if %errorlevel%==2 exit
cls
echo Buscando una partida existente...
timeout 1 >NUL
IF EXIST "%userprofile%\Documents\Electronic Arts\Los Sims 4" (
	echo Partida encontrada
	timeout 1 >NUL
	echo Trabajando...
	ren "%userprofile%\Documents\Electronic Arts\Los Sims 4" "Los Sims 4_save0"
	goto continue1
) ELSE (
	echo No se ha encontrado ninguna partida
	timeout 1 >NUL
	echo Trabajando...
	mkdir "%userprofile%\Documents\Electronic Arts\Los Sims 4_save0"
	goto continue1
)
:continue1
mkdir "%userprofile%\Documents\Electronic Arts\Los Sims 4_mp0"
echo ¡Listo!
timeout 1 >NUL
echo Introduce un nombre para la partida principal
set /p savename_tmp=
echo Guardando...
mkdir "%CD%\launcher_data\saves\singleplayer\0"
mkdir "%CD%\launcher_data\saves\multiplayer\0"
echo %savename_tmp%>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0\SaveName.txt"
echo %savename_tmp%>"%CD%\launcher_data\saves\singleplayer\0\SaveName.txt"
echo save0>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0\SaveCode.txt"
echo save0>"%CD%\launcher_data\saves\singleplayer\0\SaveCode.txt"
echo Multijugador>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0\SaveName.txt"
echo Multijugador>"%CD%\launcher_data\saves\multiplayer\0\SaveName.txt"
echo mp0>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0\SaveCode.txt"
echo mp0>"%CD%\launcher_data\saves\multiplayer\0\SaveCode.txt"
echo false>"%CD%\launcher_data\first_init.txt"
cls
mode con:cols=58 lines=12
echo +========================================================+
echo .                Asistente de Instalación                .
echo +========================================================+
echo .                     [-]  S4MP  [-]                     .
echo .                                                        .
echo .     A continuación se descargará la última versión     .
echo .            de "Sims 4 Multiplayer Laucher".            .
echo .                                                        .
echo +========================================================+
echo . [C] Descargar ahora            [X] Descargar más tarde .
echo +========================================================+
choice /C cx /N /M ">"
	if %errorlevel%==1 goto download_s4mp
	if %errorlevel%==2 set q1=No
:finish
cls
mode con:cols=58 lines=12
echo +========================================================+
echo .                Asistente de Instalación                .
echo +========================================================+
echo .                 [-]  ¡Todo Listo!  [-]                 .
echo .                                                        .
echo .          Ya has terminado de configurar todo.          .
echo .            Disfruta de tus Sims organizados            .
echo .                (El Launcher se cerrará)                .
echo +========================================================+
echo .                      [X] Terminar                      .
echo +========================================================+
pause
exit

:download_s4mp
mode con:cols=58 lines=12
cls
echo Eliminando versión anterior...
erase /q "mp_launcher.exe"
echo Obteniendo la versión más reciente...
wget --quiet --no-check-certificate "%version_link%" -O samp_link.txt
set /p samp_link=<samp_link.txt
erase /Q samp_link.txt
echo Descargando la versión más reciente...
wget --quiet --show-progress --no-check-certificate "%samp_link%" -O s4mp.zip
powershell Expand-Archive -Path "s4mp.zip" -DestinationPath (Get-Location)
echo Renombrando...
ren "S4MP Launcher Windows.exe" "mp_launcher.exe"
echo Eliminando archivos temporales...
erase /Q s4mp.zip
echo S4MP descargado con éxito
timeout 2 >NUL
if "%first_init%"=="true" goto finish
if "%first_init%"=="false" goto CHECKING_S4MP_PATH_SILENT

:UNSAVED_FOLDER
set /p path_fix=<"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4\SaveCode.txt"
cls
color 0C
echo Se ha detectado un mal cierre
echo Nunca cierres el launcher manualmente
timeout 1 >NUL
echo Partida actual: %path_fix%
echo Solucionando problemas...
timeout 1 >NUL
ren "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4" "Los Sims 4_%path_fix%"
echo Carpeta renombrada
echo Pulsa cualquier tecla para volver al menú...
pause >NUL
echo Volviendo al menú...
timeout 1 >nul
goto INIT

:ERROR
mode con:cols=100 lines=15
color 0C
cls
echo Parada crítica
echo Se ha producido un error.
echo Descripción    : %error_desc%
echo Código de error: %error_code%
echo Razón probable : %error_reas%
timeout 3 >NUL
echo ¿Visitar ayuda en GitHub?
choice /C CGN /N /M "[C] Continuar/Reintentar | [G] Visitar GitHub | [N] Salir"
		if %ErrorLevel%==1 goto PARSER_%error_code%
		if %ErrorLevel%==2 start %error_wiki_link%%error_code% & goto error
		if %ErrorLevel%==3 exit

:PARSER_CRITICAL_TS4_NOT_FOUND
if %error_code%==CRITICAL_TS4_NOT_FOUND goto ERROR

:PARSER_MISSING_S4MP_NOT_INSTALLED
color 0B
cls
echo ¿Quieres descargar S4MP?
choice /C SN /N /M "[S] Sí | [N] No"
		if %ErrorLevel%==1 goto download_s4mp
		if %ErrorLevel%==2 goto CHECKING_S4MP_PATH_SILENT
:PARSER_CRITICAL_CANT_RENAME_FOLDER
goto ren_solo

:PARSER_MISSING_FIRST_INIT_NOT_FOUND
echo ¿Saltarse la configuración inicial?
echo No afectará en nada, pero no podrás modificar ciertos aspectos del Launcher.
echo ¿Seguro que quieres continuar?
choice /C SN /N /M "[S] Saltar | [N] No"
		if %ErrorLevel%==1 echo Creando datos por defecto... & mkdir "%CD%\launcher_data" & timeout 1>NUL & echo false>"%CD%\launcher_data\first_init.txt" & echo Principal>"%CD%\launcher_data\saves\singleplayer\0\SaveName.txt" & echo save0>"%CD%\launcher_data\saves\singleplayer\0\SaveCode.txt" & echo Multijugador>"%CD%\launcher_data\saves\multiplayer\0\SaveName.txt" & echo save0>"%CD%\launcher_data\saves\multiplayer\0\SaveCode.txt" & ren "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4" & mkdir "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0" & ren "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4" "Los Sims 4_save0" & if %errorlevel%==1 mkdir "%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0" & echo Principal>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0\SaveName.txt" & echo save0>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_save0\SaveCode.txt" & echo Multijugador>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0\SaveName.txt" & echo mp0>"%USERPROFILE%\Documents\Electronic Arts\Los Sims 4_mp0\SaveCode.txt" & goto CHECKING_FIRST_INIT
		if %ErrorLevel%==2 mkdir "%CD%\launcher_data" & timeout 1 >NUL & echo true>"%CD%\launcher_data\first_init.txt" & goto CHECKING_FIRST_INIT