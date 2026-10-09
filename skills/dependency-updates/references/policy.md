# Policy

Both bots apply the same policy. Each Renovate-covered repository carries the whole policy in
its own `renovate.json5`, so a reader of a public repository can see why its bot behaves as it
does; keep the copies alike.

## Cooldown

- **7 days** for minor and patch updates, **14 days** for majors: a release published today
  can be yanked tomorrow, and majors are the ones that get emergency-patched.
  - Dependabot: `cooldown: {default-days: 7, semver-major-days: 14}` where the ecosystem
    supports per-semver days; a flat `default-days: 7` where it does not (`github-actions`).
  - Renovate: `minimumReleaseAge: "7 days"`, and a package rule giving majors `"14 days"`.
- **Vulnerability fixes skip the cooldown** in both bots. Dependabot's `cooldown` applies only
  to version updates, not security updates. Renovate's vulnerability pull requests bypass
  `minimumReleaseAge` and `schedule`.
- **The project's own releases skip it**: a pin following a release the same team published
  (a chart's `appVersion`, a docs site's pinned version) sets `minimumReleaseAge: null`.
- `minimumReleaseAgeBehaviour: "timestamp-optional"`: Renovate dates Docker images only from
  Docker Hub, so under the default an image on any other registry is never proposed.

## Grouping

Minor and patch updates of one ecosystem arrive as one pull request; majors arrive singly.
Pins that must move together share a group (kind with its node image; a Terraform version in
CI with the same version in `mise.toml`).

## Commit types

The type decides whether a squash-merged update cuts a release under Release Please, so choose
it by consequence:

| Update | Type |
| --- | --- |
| Routine dependency bump | `chore(deps)` |
| Fixes a known vulnerability | `fix(deps)`: Renovate `vulnerabilityAlerts: {semanticCommitType: "fix"}` |
| A toolchain that changes what ships (a Go `go` directive) | `fix` |
| Following the project's own release (a chart's `appVersion`) | `feat(<scope>)`, so the dependent artefact releases too |
| CI or development tooling | `chore` |

Renovate's `config:recommended` types dependency updates as `fix(deps)`; override it to
`chore` for routine bumps, or every bump cuts a release. Dependabot's
`commit-message: {prefix: chore, include: scope}` gives `chore(deps)`; it cannot give a
security update a different type from a routine one, which is one reason a released module
ecosystem such as Go goes to Renovate.

## Renovate settings

- `semanticCommits: "enabled"`, `dependencyDashboard: true`.
- `prHourlyLimit: 0`: the default throttles a bot that runs continuously; a cron run is one
  hour, so the default caps a repository at two pull requests a run.
- **No `schedule`.** The runner's cron is the only schedule; a second gate on top of it parks
  updates outside a window the late-starting cron misses, and Renovate then opens nothing.
- `osvVulnerabilityAlerts: true`, and `vulnerabilityAlerts: {semanticCommitType: "fix",
  labels: ["security"]}`.
- `enabledManagers`: exactly the managers this repository's Renovate-owned pins need.
