#!/bin/env python3
"""
Convert configuration using remote to local conf
"""
import argparse
import os
from collections.abc import Sequence

import yaml


# Manage !secret key ---------------------------------------------------------------------------------------------------
class SecretTag:
    """class dedicated to add !secret"""

    def __init__(self, value):
        self.value = value

    def __repr__(self):
        return f"SecretTag(value={self.value!r})"


def secret_constructor(_, node):
    """Manage !secret key"""
    return SecretTag(node.value)


def secret_representer(dumper, data):
    """Sérialiser les instances de SecretTag avec la balise !secret"""
    return dumper.represent_scalar("!secret", data.value)


yaml.add_constructor("!secret", secret_constructor)
yaml.add_representer(SecretTag, secret_representer)


# Manage !include key --------------------------------------------------------------------------------------------------
class IncludeTag:
    """class dedicated to add !include"""

    def __init__(self, filename, vars_values=None):
        self.file = filename
        self.vars = vars_values

    def __repr__(self):
        return f"{self.__class__.__name__}(file={self.file!r}, vars={self.vars!r})"


def include_constructor(loader, node):
    """Manage !include key"""
    data = loader.construct_mapping(node)
    return IncludeTag(**data)  # Return as IncludeTag for proper dumping


def include_representer(dumper, data):
    """Manage vars"""
    mapping = {"file": data.file}
    if data.vars:  # Add `vars` only if not empty
        mapping["vars"] = data.vars
    node = dumper.represent_mapping("!include", mapping)
    return node


yaml.add_constructor("!include", include_constructor)
yaml.add_representer(IncludeTag, include_representer)


# ----------------------------------------------------------------------------------------------------------------------
def load_yaml_with_custom_constructors(file_path):
    """Use custom loader"""
    with open(file_path, "r", encoding="UTF-8") as file:
        data = yaml.load(file, Loader=yaml.Loader)  # Use custom loader
    return data


def get_package_name(filepath):
    """Extract package name from filename"""
    filename = os.path.basename(filepath)
    name, _ = os.path.splitext(filename)
    return name


def update_parameter(config, keys, new_value=None):
    current = config
    for key in keys[:-1]:
        if isinstance(current, dict) and key in current:
            current = current[key]
            continue
        elif isinstance(current, Sequence) and not isinstance(current, str):
            if isinstance(current[0], dict) and key in current[0]:
                current = current[0]
                continue
        return

    if isinstance(current, dict) and keys[-1] in current:
        current[keys[-1]] = "_".join(keys) if new_value is None else new_value


def process_yaml_file(yaml_file, fake_secrets):
    """Convert yaml file"""
    config = load_yaml_with_custom_constructors(yaml_file)
    if "solar_router" in config["packages"]:
        if "files" in config["packages"]["solar_router"]:
            index=0
            for item in config["packages"]["solar_router"]["files"]:
                index = index + 1
                package_name = f'{index}_{get_package_name(item["path"])}'
                config["packages"][package_name] = IncludeTag(filename=item["path"])
                if "vars" in item:
                    config["packages"][package_name].vars = item["vars"]
        del config["packages"]["solar_router"]

    if fake_secrets:
        update_parameter(config, ["api", "encryption", "key"], "/TQQDQvCLeJ1RfoihmoIUjSk+PtvOF9oUCoOGI53ie8=")
        update_parameter(config, ["ota", "platform", "password"])
        update_parameter(config, ["wifi", "ssid"])
        update_parameter(config, ["wifi", "password"])
        update_parameter(config, ["ap", "password"])

    dumped_yaml = yaml.dump(config, sort_keys=False, default_flow_style=False)
    with open(f"local_{os.path.basename(yaml_file)}", "w", encoding="UTF-8") as f:
        f.write(dumped_yaml)


def main():
    """main"""
    parser = argparse.ArgumentParser(description="Convert yaml to use local code")
    parser.add_argument("filename", type=str, help="File to convert")
    parser.add_argument("--ci", action="store_true", help="Add fake secret for CI")
    args = parser.parse_args()

    process_yaml_file(args.filename, args.ci)


if __name__ == "__main__":
    main()
