@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Projet prevision electricite - Demo

set "VENV=%~dp0.venv_demo"
set "PY=%~dp0.venv_demo\Scripts\python.exe"
set "NB=projet.ipynb"

echo ============================================================
echo   Projet de prevision - Consommation electrique France
echo ============================================================
echo.

REM ---------------------------------------------------------------
REM 0. Verification que les donnees sont bien a cote du script
REM ---------------------------------------------------------------
set "MANQUE="
for %%F in (projet.ipynb requirements.txt eCO2mix_RTE_Annuel-Definitif_2023.xls eCO2mix_RTE_Annuel-Definitif_2024.xls eCO2mix_RTE_Annuel-Definitif_2025.xls eCO2mix_RTE_En-cours-Consolide.xls synop_2023.csv synop_2024.csv synop_2025.csv synop_2026.csv) do (
  if not exist "%%F" (
    echo [!] Fichier manquant : %%F
    set "MANQUE=1"
  )
)
if defined MANQUE (
  echo.
  echo Ce script doit etre dans le dossier du projet, a cote du notebook,
  echo de requirements.txt et des fichiers de donnees.
  pause
  exit /b 1
)

REM ---------------------------------------------------------------
REM 1. Environnement deja installe ? -> on passe directement au menu
REM ---------------------------------------------------------------
if exist "%VENV%\.installation_ok" goto :menu

echo [1/2] Creation de l'environnement Python (une seule fois)...
if exist "%VENV%" rmdir /s /q "%VENV%"

REM Methode 1 : uv (telecharge lui-meme Python 3.13, aucun droit admin requis)
call :trouver_uv
if defined UV (
  "%UV%" venv --seed --python 3.13 "%VENV%"
  if exist "%PY%" goto :deps
  echo uv n'a pas pu creer l'environnement, essai avec le Python deja installe...
)

REM Methode 2 : un Python 3.11+ deja present sur la machine (py launcher, Anaconda...)
for %%C in ("py -3.13" "py -3" "python") do (
  if not exist "%PY%" (
    %%~C -c "import sys; sys.exit(0 if sys.version_info>=(3,11) else 1)" >nul 2>nul && %%~C -m venv "%VENV%"
  )
)
if not exist "%PY%" (
  echo.
  echo [ERREUR] Impossible de trouver ou d'installer Python 3.11 ou plus recent.
  echo Installez Python 3.13 depuis https://www.python.org/downloads/ puis relancez.
  pause
  exit /b 1
)

:deps
echo.
echo [2/2] Telechargement des bibliotheques (quelques minutes la premiere fois)...
"%PY%" -m pip install --disable-pip-version-check -q --upgrade pip
"%PY%" -m pip install --disable-pip-version-check -r requirements.txt
if errorlevel 1 (
  echo.
  echo [ERREUR] L'installation des bibliotheques a echoue. Verifiez la connexion internet
  echo puis relancez ce fichier.
  pause
  exit /b 1
)
echo ok> "%VENV%\.installation_ok"
echo.
echo Installation terminee.

REM ---------------------------------------------------------------
REM 2. Menu
REM ---------------------------------------------------------------
:menu
echo.
echo ============================================================
echo   Que voulez-vous faire ?
echo     [1] Ouvrir le notebook dans Jupyter (demo interactive)
echo     [2] Tout executer et ouvrir le resultat dans le navigateur
echo ============================================================
choice /c 12 /n /t 30 /d 1 /m "Votre choix (1 ou 2) - choix 1 automatique dans 30 s : "
if errorlevel 2 goto :executer

echo.
echo Ouverture de Jupyter dans le navigateur...
echo (Dans Jupyter : menu Run ^> Run All Cells pour tout executer.)
echo Laissez cette fenetre ouverte pendant la demo ; fermez-la pour arreter Jupyter.
"%PY%" -m jupyter notebook "%NB%"
goto :eof

:executer
echo.
echo Execution complete du notebook (1 a 3 minutes : lecture des gros fichiers meteo)...
"%PY%" -m jupyter nbconvert --to html --execute --ExecutePreprocessor.timeout=1800 --output projet_resultats "%NB%"
if errorlevel 1 (
  echo.
  echo [ERREUR] L'execution du notebook a echoue, voir le message ci-dessus.
  pause
  exit /b 1
)
echo Resultat : projet_resultats.html
start "" "%~dp0projet_resultats.html"
pause
goto :eof

REM ---------------------------------------------------------------
REM Sous-routine : trouve uv, ou le telecharge depuis astral.sh
REM ---------------------------------------------------------------
:trouver_uv
set "UV="
for /f "delims=" %%U in ('where uv 2^>nul') do if not defined UV set "UV=%%U"
if defined UV exit /b 0
if exist "%USERPROFILE%\.local\bin\uv.exe" (
  set "UV=%USERPROFILE%\.local\bin\uv.exe"
  exit /b 0
)
echo Telechargement de uv (installateur Python leger)...
set "UV_NO_MODIFY_PATH=1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
if exist "%USERPROFILE%\.local\bin\uv.exe" set "UV=%USERPROFILE%\.local\bin\uv.exe"
exit /b 0
