# Inventory every pin

Read the repository, not its config: the config lists only what is already owned. Search with
hidden and ignored files included (`rg --hidden --no-ignore`); a plain search skips `.github/`.

Check each of these, and list every pin with its file and current value:

1. **Package manifests and lockfiles**: `go.mod` (including the `go` and `toolchain`
   directives), `package.json` and its lockfile, `pyproject.toml` and `uv.lock`,
   `Cargo.toml`, `Gemfile`, and the rest.
2. **Workflows** (`.github/workflows/*.y*ml`, `action.yml`): every `uses:` SHA; every
   `with:` input naming a version (`version:`, `go-version:`, `terraform_version:`,
   `prek-version:`, `node_image:`); every `go install …@`, `npx …@`, `curl` URL carrying a
   version; and every `*_VERSION` / `*_SHA256` env value.
3. **Tool pins**: `mise.toml`, `.tool-versions`, `.python-version`, `.nvmrc`, `.go-version`.
4. **Hooks**: `.pre-commit-config.yaml` `rev:` values.
5. **Images**: Dockerfiles, compose files, Kubernetes and Helm manifests, `.goreleaser.yaml`
   (`base_image`), `.ko.yaml`.
6. **Infrastructure**: Terraform `required_providers`, `required_version`,
   `.terraform.lock.hcl`.
7. **Project-specific version files**: a chart's `Chart.yaml` `appVersion`, a docs site's
   pinned-release file, anything named `versions` or `*.version`.
8. **Unpinned on purpose**: `latest`, floating tags (`postgres:18`), ranges (`"1.15"`). List
   them too; each needs a recorded reason to stay floating.

Done when every file in the list above has been read in every repository in scope.
