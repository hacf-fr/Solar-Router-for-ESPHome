# Tool tests

The repository tooling tests use [Bats](https://bats-core.readthedocs.io/) and live under `tests/tools/`.

Run them locally with:

```bash
bats tests/tools
```

The tests intentionally build temporary Git repositories so dependency resolution is checked against real Git refs. This framework can be reused by future validation scripts.
