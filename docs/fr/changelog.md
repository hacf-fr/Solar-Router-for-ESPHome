!!! note "Mise à jour du journal des modifications (Changelog)"
    Le Changelog n'est disponible que dans la [documentation](https://hacf-fr.github.io/Solar-Router-for-ESPHome/changelog/) officiellement publiée.  
    Le Changelog est mis à jour manuellement après la publication d'une nouvelle version.

    Le Changelog est généré à l'aide de `git-cliff`.  
    Les versions sont basées sur les tags.  
    Les lignes ajoutées dans le Changelog sont basées sur les *messages de commit de fusion*.
    Le script `tools/update_documentation.sh` est conçu pour mettre à jour automatiquement et mettre en ligne la documentation sur gh-pages. Le journal des modifications (log) de la version actuelle est utilisé pour décrire la "release" sur GitHub.

    Le script `tools\update_documentation.sh` est conçu pour mettre à jour `changelog.md`, générer et publier la documentation `mkdocs` sur [github pages](https://hacf-fr.github.io/Solar-Router-for-ESPHome/).  
    **Le script de mise à jour de la documentation est destiné à être utilisé uniquement par le responsable du dépôt au moment the la publication d'une nouvell "release".**
