# Triac Regulator

## Description
Ce régulateur effectue une **Régulation par Contrôle de Phase**.

Un triac est capable de fractionner le courant envoyé à la charge pour réduire la puissance transmise. Ce composant est à la base des gradateurs AC.

## Diagramme
![Régulation par contrôle de phase](images/Regulation_phase_control.png)

??? note "Comment fonctionne ce régulateur ?"
    Si vous voulez en savoir plus sur la façon dont un triac peut réguler l'énergie transmise, vous pouvez vous référer à [Wikipedia](https://en.wikipedia.org/wiki/TRIAC#Application).  
    Le schéma suivant montre comment le sinus d'entrée est coupé pour réduire l'énergie transférée à la charge :

    <figure markdown="span">
      ![fonction triac](images/Triac_function.gif){ width="300" } 
      <figcaption>Fractionnement du sinus (Source : Wikipedia)</figcaption>
    </figure>
    

## Matériel
Dans ce package, nous proposons d'utiliser une carte fabriquée par RobotDyn.

![triac](images/RobotDynTriac24A.png){ width="300" }

!!! warning
    Le triac est censé supporter jusqu'à 24A (ce qui représente une puissance supérieure à 5500W). Le dissipateur thermique est sous-dimensionné par rapport au niveau d'énergie supporté par le triac. Il est donc recommandé de remplacer le dissipateur thermique par un plus grand.

## Schéma de câblage
Le schéma suivant représente le câblage de la carte :
![triac](images/RobotDynTriac24A.drawio.png)

## Configuration
Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_triac.yaml
        vars:
          regulator_gate_pin: GPIO22
          regulator_zero_crossing_pin: GPIO23
```

### Variables

| Variable                     | Obligatoire | Défaut | Description                                                                                     |
| --------------------------- | ----------- | ------ | ----------------------------------------------------------------------------------------------- |
| `regulator_gate_pin`        | oui         | —       | Broche GPIO pour le contrôle de la gâchette/PWM du triac.                                       |
| `regulator_zero_crossing_pin` | oui      | —       | Broche GPIO pour la détection du passage à zéro.                                              |
| `regulator_zero_cross_inverted` | non    | `false` | Définir à `true` si la détection du passage à zéro se fait sur niveau haut (résout les problèmes de flicker). |
