# Prévision de la consommation électrique (France métropolitaine)
# ATTENTION : VEUILLEZ DECOMPRESSER LES SYNOP_2023/SYNOP_2024/SYNOP_2025/SYNOP_2026 afin de les avoir en .csv dans votre dossier
## Lancer le projet en un clic

| Système | Action |
|---|---|
| Windows | double-cliquer sur **`LANCER_DEMO.bat`** |
| Mac / Linux | `bash lancer_demo.sh` |

Au premier lancement, le script :
1. télécharge `uv` puis Python 3.13 (sans droits administrateur) ; à défaut, il utilise un Python 3.11+ déjà installé ;
2. crée un environnement isolé `.venv_demo/` dans ce dossier ;
3. installe les bibliothèques de `requirements.txt` (versions figées).

Il propose ensuite :
- **[1]** ouvrir `projet.ipynb` dans Jupyter (puis *Run → Run All Cells*) ;
- **[2]** exécuter tout le notebook et ouvrir le résultat `projet_resultats.html` dans le navigateur.

Les lancements suivants passent directement au menu. Pour réinstaller, supprimer `.venv_demo/`.

## Organisation des fichiers

| Fichier | Contenu |
|---|---|
| `projet.ipynb` | tout le code : chargement, nettoyage, variables, exploration, modèles, évaluation |
| `eCO2mix_RTE_Annuel-Definitif_2023/2024/2025.xls`, `eCO2mix_RTE_En-cours-Consolide.xls` | consommation RTE éCO2mix (fichiers texte tabulés malgré l'extension .xls) |
| `synop_2023.csv` … `synop_2026.csv` | observations météo SYNOP Météo-France |
| `requirements.txt` | dépendances Python |
| `LANCER_DEMO.bat`, `lancer_demo.sh` | lanceurs |

## Ordre d'exécution et étapes coûteuses

Le notebook s'exécute de haut en bas. L'étape la plus longue est la lecture des fichiers SYNOP (environ 250 Mo). Une exécution complète prend environ 1 minute sur un portable récent.

Le dossier `.venv/` éventuellement présent est propre à la machine d'origine. Il n'est pas utilisé et peut être supprimé.
