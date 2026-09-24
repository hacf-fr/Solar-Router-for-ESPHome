!!! note "Mise à jour du journal des modifications (Changelog)"
    Le journal des modifications officiel est disponible dans la [documentation publiée](https://hacf-fr.github.io/Solar-Router-for-ESPHome/changelog/). 

    **Processus de génération** :

    - Le journal des modifications est généré automatiquement à l'aide de [git-cliff](https://github.com/orhun/git-cliff) basé sur les messages de commit conventionnels.
    - Les versions sont basées sur les tags Git.
    - Les lignes sont extraites des *messages de commit de fusion*.
    **Mise à jour de la documentation** :
    Le script `tools/update_documentation.sh` (maintenu exclusivement par les responsables du dépôt) met à jour `changelog.md`, génère le site MkDocs et déploie sur [GitHub Pages](https://hacf-fr.github.io/Solar-Router-for-ESPHome/). Le journal de la version actuelle est utilisé pour décrire la release sur GitHub.

    **Remarque** : Ce script est destiné à être utilisé uniquement par le responsable du dépôt lors de la publication d'une nouvelle release.
