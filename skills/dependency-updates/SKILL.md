---
name: dependency-updates
description: >
  Keep every pinned dependency in a GitHub repository or org current, with Dependabot and
  self-hosted Renovate splitting the pins so each has exactly one owner. Use when setting up
  or changing dependency updates (dependabot.yaml, renovate.json5, a Renovate runner),
  auditing a repository or org for pins nothing updates, or adding a new pin (a tool version
  in a workflow, a base image, a mise.toml entry, a version file).
---

# Dependency updates

**The rule: every pin has exactly one owner.** A *pin* is any version, tag or digest a
repository commits to: a lockfile entry, an action SHA, a `go` directive, a tool version in a
workflow, a base image, a `mise.toml` line, a chart's `appVersion`. Its *owner* is the one thing
that moves it: **Dependabot**, **Renovate**, or **manual** with the reason recorded. A pin with
no owner goes stale silently; a pin with two owners gets duplicate pull requests and
conflicting edits.

Repositories squash-merge only, in small focused pull requests, so each update is one commit
and one changelog line.

## Who owns what

| Pin | Owner |
| --- | --- |
| An ecosystem Dependabot supports: npm, `uv`, `pip`, `github-actions` SHAs, `pre-commit` hooks, `terraform` providers, `docker` in Dockerfiles, and so on | Dependabot |
| `go.mod`, whole: modules and the `go` directive (Dependabot cannot move the directive, and one file has one owner) | Renovate |
| `mise.toml` | Renovate |
| A tool version in a workflow (`with: version:`, `go install …@vX`) | Renovate, as an annotated `*_VERSION` value |
| An image outside a Dockerfile (a `.goreleaser.yaml` `base_image`, a `kind` node image) | Renovate, pinned by digest through a regex manager |
| A `KEY=value` versions file, a chart's `appVersion`, anything a regex can find | Renovate, one regex manager per pin |
| A version paired with a checksum (`*_SHA256` beside it) | Manual: Renovate cannot write the new hash, so its pull request would fail CI until a human did |
| A range or `latest` left floating on purpose | Nobody, recorded as a choice |

Dependabot alerts and security updates stay on in every repository, whichever bot owns its
version updates. Renovate's `enabledManagers` lists only the managers it owns in that
repository: that list is the overlap guard.

The policy both bots share (cooldown, grouping, commit types, vulnerability handling) is in
[references/policy.md](references/policy.md). Read it before writing any config.

## Set up a repository or org

The templates' action SHAs and tool versions are examples, and no bot moves them: look up the
current release of each when copying, and pin it within the cooldown in
[references/policy.md](references/policy.md).

1. **Inventory every pin.** Follow [references/inventory.md](references/inventory.md). Done
   when every file that can hold a pin has been read and every pin is listed with its file.
2. **Assign each pin an owner** from the table above. Done when no pin is unowned and none has
   two owners. A manual pin and a floating range each carry their reason.
3. **Record the split** in the project's decision log: the owner table for these repositories,
   the manual pins and why. Get the human's choice on anything the table above does not settle.
4. **Write the Dependabot config** from [templates/dependabot.yaml](templates/dependabot.yaml),
   one block per Dependabot-owned ecosystem and none for an ecosystem Renovate owns.
5. **Write the Renovate config** from [templates/renovate.json5](templates/renovate.json5) in
   each repository with a Renovate-owned pin. Convert each workflow tool version to an
   annotated `*_VERSION` env value, and pin each image by digest.
6. **Run Renovate.** One runner per org, in its infrastructure repository, as its own GitHub
   App: [references/runner.md](references/runner.md) and
   [templates/renovate-runner.yaml](templates/renovate-runner.yaml).
7. **Gate CI on known vulnerabilities** in each repository that ships something:
   `govulncheck` for Go, `pnpm audit --audit-level=moderate` for pnpm, the ecosystem's
   equivalent elsewhere.
8. **Verify.** Follow [references/verify.md](references/verify.md). Done when a local extract
   shows only the owned managers, finding every Renovate-owned pin, and the first real run
   opened its pull requests with the expected titles and green CI.

## Audit a repository or org

Run steps 1 and 2 of the setup against what is committed, then report each pin that breaks the
rule: no owner, two owners, or manual with no recorded reason. Check each repository's
merge settings are squash-only. Done when every pin in every repository is accounted for.
[references/pitfalls.md](references/pitfalls.md) lists configurations that look right and are
not; check each one.

## Add a pin

A new pin gets its owner in the same pull request that adds it: an annotated `*_VERSION`
value, a regex manager, or a Dependabot ecosystem. A manual pin gets its reason beside it.
