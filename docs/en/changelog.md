!!! note "Changelog update"
    The official changelog is available in the [published documentation](https://hacf-fr.github.io/Solar-Router-for-ESPHome/changelog/).

    **Generation Process**:
    - The changelog is automatically generated using [git-cliff](https://github.com/orhun/git-cliff) based on conventional commit messages.
    - Versions are based on Git tags.
    - Lines are extracted from *merge commit messages*.

    **Documentation Update**:
    The `tools/update_documentation.sh` script (maintained by repository maintainers only) updates `changelog.md`, builds the MkDocs site, and deploys to [GitHub Pages](https://hacf-fr.github.io/Solar-Router-for-ESPHome/). The current version's log is used to describe the GitHub release.

    **Note**: This script is intended to be used only by the repository maintainer when a new release is published.