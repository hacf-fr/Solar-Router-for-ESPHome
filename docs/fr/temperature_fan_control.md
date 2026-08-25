# Contrôle du ventilateur

Ce package est conçu pour piloter un ventilateur afin de contrôler la température du routeur solaire.  
Ce module lit la température fournie par un `temperature limiter`.
Le ventilateur peut être configuré pour démarrer dès que la température de démarrage est atteinte et s'arrêter lorsque la température mesurée passe sous la température d'arrêt.

??? Note "Détails du mécanisme de régulation anti-rebond"
    La régulation à deux seuils utilisée ici est appelée **hystérésis**. Ce mécanisme évite les oscillations de la régulation.  
    Voir ***Plus de détails sur l'hystérésis et le trigger de Schmitt*** sur la page [temperature_limiter](temperature_limiter.md).


!!! danger "ATTENTION : effectuez des tests avant de laisser le système réguler seul"
    La logique de contrôle du ventilateur peut contenir des bugs. Il est fortement conseillé de valider soigneusement le comportement de votre système avant de le laisser fonctionner seul.

## Prérequis

Ce package n'est pas autonome. Il repose sur des identifiants fournis par deux autres packages qui doivent être inclus dans votre configuration :

- un package `engine_*` (par exemple `engine_1dimmer.yaml`) qui fournit l'interrupteur `activate`,
- un package `temperature_limiter_*` (par exemple `temperature_limiter_DS18B20.yaml`) qui fournit le capteur `safety_temperature`.

## Sens de régulation

Le ventilateur est destiné à refroidir l'élément surveillé par `safety_temperature`. Il se met en marche lorsque la température dépasse `fan_start_temperature` et s'arrête lorsqu'elle descend en dessous de `fan_stop_temperature`. Si vous avez besoin d'un fonctionnement inverse, ce paquet ne convient pas.

## Invariant des seuils

Les deux seuils sont couplés : `fan_start_temperature > fan_stop_temperature` est garanti en permanence. Si vous modifiez l'un des deux à une valeur qui casserait cet invariant, l'autre est automatiquement ajusté de 1 °C pour préserver une hystérésis valide :

- fixer `fan_stop_temperature` à une valeur `>=` à l'actuel `fan_start_temperature` remonte `fan_start_temperature` à `fan_stop_temperature + 1`,
- fixer `fan_start_temperature` à une valeur `<=` à l'actuel `fan_stop_temperature` descend `fan_stop_temperature` à `fan_start_temperature - 1`.

Vous pouvez donc modifier l'un ou l'autre des seuils dans n'importe quel ordre sans jamais tomber sur une configuration invalide.

## Câblage

L'énergie disponible sur une broche de l'ESP32 n'est pas suffisante pour alimenter directement un ventilateur. Il est donc nécessaire d'ajouter un circuit supplémentaire pour piloter un ventilateur en 5 V ou 12 V.

Le schéma suivant présente le câblage du ventilateur :

![FanControl](images/fan_controller.png){width=400}

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  fan_controller:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/temperature_fan_control.yaml
        vars:
          fan_control_pin: GPIO4
```

### Variables

| Variable               | Obligatoire | Défaut    | Description                                                                                                           |
| ---------------------- | ----------- | --------- | --------------------------------------------------------------------------------------------------------------------- |
| `fan_control_pin`      | oui         | —         | Broche GPIO qui pilote le circuit de commande du ventilateur.                                                         |
| `fan_control_inverted` | non         | `"False"` | À mettre à `"True"` si le circuit de commande inverse la logique (par exemple étage à transistor actif à l'état bas). |
