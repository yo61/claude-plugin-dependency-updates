# Pitfalls

Configurations that look right and are not. Check each when auditing.

- **Renovate's managers are opt-out.** Handing an ecosystem to Dependabot means disabling every
  Renovate manager that matches its files, not the obviously named one: `poetry` matches
  `pyproject.toml` as well as `pep621`, and left on it edited `pyproject.toml` without
  `uv.lock`. Prefer an `enabledManagers` list to disabling managers one by one, and confirm
  against the Dependency Dashboard's per-manager sections.
- **Dependabot's `gomod` does not move the `go` directive**, so the Go standard library, and
  advisories against it, fall outside it. `govulncheck` in CI is what catches those.
- **A security advisory can be missing from GitHub's database** while the ecosystem's own
  database (OSV, the Go vulnerability database) has it. A CI gate reading the ecosystem's
  database catches what no Dependabot alert raised.
- **A new Go needs a linter built for it.** golangci-lint built against an older Go fails every
  package with `export data version N is greater than maximum supported version`. Bump the
  linter's pin in the same pull request as the toolchain.
- **Renovate's `mise` manager replaces a range with an exact version** (`"1.15"` becomes
  `"1.16.4"`). Pin `mise.toml` exactly, matching CI, and group the two.
- **A workflow `with:` input cannot carry a renovate comment.** Move the version to a step
  `env:` value named `*_VERSION`, annotate it, and pass `${{ env.X_VERSION }}`.
- **A `KEY=value` file whose loader rejects comments** cannot carry annotations; give each key
  its own regex manager.
- **A version beside a checksum** gets a Renovate pull request that fails CI; leave it manual.
- **A generated, gitignored copy of a config** (`.goreleaser.snapshot.yaml`) is not a pin;
  point the regex manager at the source file only.
- **Renovate's default `prHourlyLimit` and a `schedule` in config** both throttle a
  cron-driven runner into opening nothing while every run exits 0.
- **Naming an issue in a pull request can close it.** A tracker integration that links by
  identifier closes the issue when the first pull request naming it merges; name the issue only
  in the pull request that finishes it.
