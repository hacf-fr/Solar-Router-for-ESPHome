# Contributing to Development

**Solar Router for [ESPHome](http://esphome.io)** is designed in a modular way to facilitate customization with different power meters and different regulators.  
Would you like to contribute? You are welcome and you will find below some recommendations to do so.

!!! Tip "Tip: Get inspired by already developed code to go faster."

## Developing **Hardware**

You can propose any hardware according to your needs. If this new hardware requires the use of GPIO, the pins used by your hardware must be configured in the `vars` section associated with your package.

Documentation must be added describing this new hardware and its constraints (e.g.: list of GPIOs and usage). See the chapter [updating the documentation](#updating-the-documentation) below.

## Developing a **Software Package**

### Setting up the Development Environment

To contribute to **Solar Router for ESPHome**, develop a new feature on your computer and propose a **pull request**, you must:

- Fork the [**Solar Router for ESPHome** repository](https://github.com/hacf-fr/Solar-Router-for-ESPHome) on Github
- Clone your forked repository to your PC
- Create a development branch from **main**
- [Create and activate a Python virtual environment](https://docs.python.org/3/library/venv.html)
    ```shell
    python -m venv venv
    source venv/bin/activate
    ```

    !!! Tip "Go faster with Linux"
        Add an alias to you venv :  
        `echo "alias venv='. ~/.virtualenvs/python3/bin/activate'" >> ~/.bash_aliases `  
        Reopen you console and call `venv` to activate you Python virtual environment.

  - Install ESPHome CLI and other dependencies:
    ```shell
    pip install -r requirements.txt
    ```
- Install and test your code on your device with the `esphome` command:
    ```shell
    esphome run my_configuration.yaml
    ```

    !!! Tip "Local development"
        **Solar-Router-For-ESPHome** is designed to use files stored on GitHub.  
        The `tools` directory contains the script `convert_to_local_source.py` which allows you to convert a `yaml` file pointing to GitHub into a source file with the same name prefixed by `local` and pointing to files located in the `solar-router` subdirectory.  
        Thus, local modifications will be taken into account immediately by the `esphome run local_<my_yaml_file>` command.

- Once stabilized, push the changes to your repository
- And finally, propose a *pull request* from your fork to the official repository

### Developing a **Power Meter**

A **Power Meter** is a component designed to provide and periodically update a sensor named `real_power`.

```yaml linenums="1"
sensor:
  # Sensor showing current power consumption
  - id: real_power
    platform: template
    name: "Real Power"
    device_class: "power"
    unit_of_measurement: "W"
    update_interval: 1s
```

This sensor is used by **Engines** to obtain the value of power exchanged with the grid.

If this new power meter requires specific configuration, the required parameters must be added in the `vars` section associated with your package.

Documentation must be added describing the power meter and how to configure it. See the chapter [updating the documentation](#updating-the-documentation) below.

### Developing **Regulators**

A **Regulator** must manage the percentage of energy sent to its load based on its regulation level sensor (e.g., `regulator_opening` for TRIAC/SSR). The level of each regulator can vary from 0 (where no energy is sent to the load) to 100 (where all possible energy is sent to the load).

The overall system state is managed by the `router_level` sensor, which controls all regulators. When `router_level` is at 0, all regulators must be off, and when it is at 100, all regulators must be at maximum. For systems with a single regulator, the regulator level generally reflects the `router_level`, but they remain separate because `router_level` is used for LED indicators and energy counting logic.

Here is an example regulator implementation (excerpt from [regulator_triac.yaml](https://github.com/hacf-fr/Solar-Router-for-ESPHome/blob/main/solar_router/regulator_triac.yaml)) using the `light` component and its `brightness` to control energy diversion:

```yaml linenums="1"
script:
  # Apply regulation on the triac using the light component
  - id: regulation_control
    mode: single
    then:
      # Apply router_level to the triac using the light component
      - light.turn_on:
          id: dimmer_controller
          brightness: !lambda return id(regulator_opening).state/100.0;
```

You can develop one or more regulators to work together in the same system. Each regulator must:
- Have its own level sensor ranging from 0 to 100
- Respond to changes in the global system `router_level`
- Manage its specific hardware control logic

If this new power meter requires specific configuration, the required parameters must be added in the `vars` section associated with your package.

Documentation must be added describing the power meter and how to configure it. See the chapter [updating the documentation](#updating-the-documentation) below.

## Updating the **Documentation**

The documentation is written using [mkdocs](https://www.mkdocs.org/) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

To install `mkdocs`, you must install [Python](https://python.org) then:

- Create a virtual environment (see [Python documentation](https://docs.python.org/3/library/venv.html)).
- Install the required modules with the following command `pip install -r requirements.txt`.

The documentation is stored in the `docs` directory. To see your changes in real time in your browser, run the `mkdocs serve` command and navigate to [http://127.0.0.1:8000](http://127.0.0.1:8000)

!!! note "Updating the Changelog"
    The Changelog is only available in the officially published [documentation](https://hacf-fr.github.io/Solar-Router-for-ESPHome/changelog/).  
    The Changelog is updated manually after a new version is released.

    The Changelog is generated using `git-cliff`.  
    Versions are based on tags.  
    Lines added to the changelog are based on *merge commit messages*.

    The `tools\update_documentation.sh` script is designed to update `changelog.md`, generate and publish the `mkdocs` documentation on [github pages](https://hacf-fr.github.io/Solar-Router-for-ESPHome/).  
    **The documentation update script is intended to be used only by the repository maintainer.**
