@echo off
cls

:: Directories
set SRC=%CD%
set BUILD=%SRC%\build
set OUTPUT=%SRC%\output
set CHAPTERS=%SRC%\chapters

:: Files
set COVER=%SRC%\cover.tex
set MATTER=%SRC%\matter.tex

:: Latexmk
set LATEXMK=latexmk -f -silent -lualatex
set FLAGS=-view=none
set FLAGS=%FLAGS% -synctex=0
set FLAGS=%FLAGS% -recorder-
set FLAGS=%FLAGS% -file-line-error
set FLAGS=%FLAGS% -interaction=nonstopmode
set FLAGS=%FLAGS% -r .latexmkrc
set FLAGS=%FLAGS% -auxdir=%BUILD%
set FLAGS=%FLAGS% -outdir=%OUTPUT%

:: Commands
set COMPILE=%LATEXMK% %FLAGS% -cd %COVER% %MATTER%
set ACRO=makeglossaries -q -d %BUILD% matter

:: Chapters (set number of chapters accordingly)
set LISTCHAPTERS=1 2 3 4 5 6 7 8

:: Options
if "%1" == "" ( goto :eof )
if "%1" == "build" (
    call :build "%2"
)
if "%1" == "preview" (
    call :preview "%2"
)
if "%1" == "clean" (
    call :clean
)
if "%1" == "cleanall" (
    call :cleanall
)

exit /b %ERRORLEVEL%

:: Functions
:build
    if "%~1" == "" (
        %COMPILE% & %ACRO% & del %OUTPUT%\cover.pdf del %OUTPUT%\matter.pdf & %COMPILE%
    ) else (
        if "%~1" == "all" (
            %COMPILE% & %ACRO% & del %OUTPUT%\* & %COMPILE%
            for  %%i in (%LISTCHAPTERS%) do (
                %LATEXMK% %FLAGS% %CHAPTERS%\chapter%%i.tex
            )
        ) else (
            if "%~1" == "cover" (
                %LATEXMK% %FLAGS% %~1.tex
            ) else (
                %LATEXMK% %FLAGS% %CHAPTERS%\%~1.tex
            )
        )
    )
    exit /b

:preview
    if "%~1" == "" (
        %LATEXMK% %FLAGS% -pvc -cd %COVER% | %LATEXMK% %FLAGS% -pvc -cd %MATTER%
    ) else (
        if "%~1" == "cover" (
            %LATEXMK% %FLAGS% -pvc -cd %~1.tex
        ) else (
            %LATEXMK% %FLAGS% -pvc -cd %CHAPTERS%\%~1.tex
        )
    )
    exit /b

:clean
    for /f %%F in ('dir /b /a-d /s %BUILD% ^| findstr /vile ".pdf .gitkeep"') do (del %%F)
    exit /b

:cleanall
    for /f %%F in ('dir /b /a-d /s %BUILD% ^| findstr /vile ".gitkeep"') do (del %%F)
    for /f %%F in ('dir /b /a-d /s %OUTPUT% ^| findstr /vile ".gitkeep"') do (del %%F)
    exit /b