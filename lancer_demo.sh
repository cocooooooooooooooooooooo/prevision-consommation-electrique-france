#!/usr/bin/env bash
# Lanceur Mac / Linux : installe l'environnement (une fois) puis lance la demo.
# Usage : double-clic (Mac : renommer en .command) ou  bash lancer_demo.sh [1|2]
set -e
cd "$(dirname "$0")"

VENV=".venv_demo"
PY="$VENV/bin/python"
NB="projet.ipynb"

echo "============================================================"
echo "  Projet de prevision - Consommation electrique France"
echo "============================================================"

manque=0
for f in projet.ipynb requirements.txt eCO2mix_RTE_Annuel-Definitif_2023.xls \
         eCO2mix_RTE_Annuel-Definitif_2024.xls eCO2mix_RTE_Annuel-Definitif_2025.xls \
         eCO2mix_RTE_En-cours-Consolide.xls synop_2023.csv synop_2024.csv \
         synop_2025.csv synop_2026.csv; do
  [ -f "$f" ] || { echo "[!] Fichier manquant : $f"; manque=1; }
done
[ "$manque" = 0 ] || { echo "Placez ce script dans le dossier du projet."; exit 1; }

if [ ! -f "$VENV/.installation_ok" ]; then
  echo "[1/2] Creation de l'environnement Python (une seule fois)..."
  rm -rf "$VENV"
  UV="$(command -v uv || true)"
  [ -z "$UV" ] && [ -x "$HOME/.local/bin/uv" ] && UV="$HOME/.local/bin/uv"
  if [ -z "$UV" ]; then
    echo "Telechargement de uv..."
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh || true
    [ -x "$HOME/.local/bin/uv" ] && UV="$HOME/.local/bin/uv"
  fi
  if [ -n "$UV" ] && "$UV" venv --seed --python 3.13 "$VENV"; then :; else
    python3 -m venv "$VENV"
  fi
  echo "[2/2] Telechargement des bibliotheques..."
  "$PY" -m pip install --disable-pip-version-check -q --upgrade pip
  "$PY" -m pip install --disable-pip-version-check -r requirements.txt
  if [ "$(uname)" = "Darwin" ] && ! "$PY" -c "import lightgbm" 2>/dev/null; then
    echo "[!] Sur Mac, LightGBM demande OpenMP : lancez  brew install libomp  puis relancez."
  fi
  echo ok > "$VENV/.installation_ok"
fi

choix="${1:-}"
if [ -z "$choix" ]; then
  echo "  [1] Ouvrir le notebook dans Jupyter (demo interactive)"
  echo "  [2] Tout executer et ouvrir le resultat (HTML)"
  read -r -t 30 -p "Votre choix (1 ou 2, defaut 1) : " choix || true
fi

if [ "$choix" = "2" ]; then
  "$PY" -m jupyter nbconvert --to html --execute --ExecutePreprocessor.timeout=1800 \
        --output projet_resultats "$NB"
  echo "Resultat : projet_resultats.html"
  (command -v open >/dev/null && open projet_resultats.html) || \
  (command -v xdg-open >/dev/null && xdg-open projet_resultats.html) || true
else
  "$PY" -m jupyter notebook "$NB"
fi
