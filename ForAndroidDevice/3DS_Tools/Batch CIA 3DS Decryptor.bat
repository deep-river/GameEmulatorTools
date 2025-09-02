@echo off
mode con cols=52 lines=26
title Batch CIA 3DS Decryptor
SetLocal EnableExtensions EnableDelayedExpansion

:: 过程日志（覆盖写）
echo %date% %time% >log.txt 2>&1
echo Decrypting...

:: 清理上次残留的临时分区文件
for %%a in (*.ncch) do del "%%a" >nul

:: ========= 处理 .3ds：输出为 .cci =========
for %%a in (*.3ds) do (
    set "CUTN=%%~na"
    if /i x!CUTN!==x!CUTN:decrypted=! (
        echo | decrypt "%%a" >>log.txt 2>&1
        set "ARG="
        for %%f in ("!CUTN!.*.ncch") do (
            if %%f==!CUTN!.Main.ncch set i=0
            if %%f==!CUTN!.Manual.ncch set i=1
            if %%f==!CUTN!.DownloadPlay.ncch set i=2
            if %%f==!CUTN!.Partition4.ncch set i=3
            if %%f==!CUTN!.Partition5.ncch set i=4
            if %%f==!CUTN!.Partition6.ncch set i=5
            if %%f==!CUTN!.N3DSUpdateData.ncch set i=6
            if %%f==!CUTN!.UpdateData.ncch set i=7
            set "ARG=!ARG! -i "%%f:!i!:!i!""
        )
        :: 改为 CCI 输出（原来是 !CUTN!-decrypted.3ds）
        makerom -f cci -ignoresign -target p -o "!CUTN!-decrypted.cci"!ARG! >>log.txt 2>&1

        :: 成功则立刻记录到 changelog.txt
        if exist "!CUTN!-decrypted.cci" >>changelog.txt echo [%date% %time%] Created: "%cd%\!CUTN!-decrypted.cci"
    )
)

:: ========= 处理 .cia（原逻辑保持），产生 decfirst.cia / patch / dlc =========
for %%a in (*.cia) do (
    set "CUTN=%%~na"
    if /i x!CUTN!==x!CUTN:decrypted=! (
        ctrtool -tmd "%%a" >content.txt
        set "FILE=content.txt"
        set /a i=0
        set "ARG="
        findstr /pr "^T.*D.*00040000" !FILE! >nul
        if not errorlevel 1 (
            echo | decrypt "%%a" >>log.txt 2>&1
            for %%f in ("!CUTN!.*.ncch") do (
                set "ARG=!ARG! -i "%%f:!i!:!i!""
                set /a i+=1
            )
            makerom -f cia -ignoresign -target p -o "!CUTN!-decfirst.cia"!ARG! >>log.txt 2>&1
        )
        findstr /pr "^T.*D.*0004000E ^T.*D.*0004008C" !FILE! >nul
        if not errorlevel 1 (
            set "TEXT=Content id"
            set /a X=0
            echo | decrypt "%%a" >>log.txt 2>&1
            for %%h in ("!CUTN!.*.ncch") do (
                set "NCCHN=%%~nh"
                set /a n=!NCCHN:%%~na.=!
                if !n! gtr !X! set /a X=!n!
            )
            for /f "delims=" %%d in ('findstr /c:"!TEXT!" !FILE!') do (
                set "CONLINE=%%d"
                call :EXF
            )
            findstr /pr "^T.*D.*0004000E" !FILE! >nul
            if not errorlevel 1 makerom -f cia -ignoresign -target p -o "!CUTN! (Patch)-decrypted.cia"!ARG! >>log.txt 2>&1
            findstr /pr "^T.*D.*0004008C" !FILE! >nul
            if not errorlevel 1 makerom -f cia -dlc -ignoresign -target p -o "!CUTN! (DLC)-decrypted.cia"!ARG! >>log.txt 2>&1
        )
    )
)

:: content.txt 是 CIA 解析的中间文件
del content.txt >nul

:: ========= 将 *-decfirst.cia 统一转为 .cci，并立刻记录 =========
for %%a in (*-decfirst.cia) do (
    set "CUTN=%%~na"
    makerom -ciatocci "%%a" -o "!CUTN:-decfirst=-decrypted!.cci" >>log.txt 2>&1
    if exist "!CUTN:-decfirst=-decrypted!.cci" >>changelog.txt echo [%date% %time%] Created: "%cd%\!CUTN:-decfirst=-decrypted!.cci"
)

:: 清理中间文件
for %%a in (*-decfirst.cia) do del "%%a" >nul
for %%a in (*.ncch) do del "%%a" >nul

cls
echo Finished, please press any key to exit.
pause >nul
exit


:EXF
if !X! geq !i! (
    if exist !CUTN!.!i!.ncch (
        set "CONLINE=!CONLINE:~24,8!"
        call :GETX !CONLINE!, ID
        set "ARG=!ARG! -i "!CUTN!.!i!.ncch:!i!:!ID!""
        set /a i+=1
    ) else (
        set /a i+=1
        goto EXF
    )
)
exit /B

:GETX v dec
set /a dec=0x%~1
if [%~2] neq [] set %~2=%dec%
exit /b
rem matif
