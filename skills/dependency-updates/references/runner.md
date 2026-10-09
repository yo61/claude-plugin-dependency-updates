# The Renovate runner

One self-hosted runner per org: a scheduled workflow in the org's infrastructure repository
([templates/renovate-runner.yaml](../templates/renovate-runner.yaml)) running Renovate over an
explicit list of repositories, each of which carries its own `renovate.json5`.

## The GitHub App

A dedicated org App, `<org>-renovate`, not one shared with release automation: a leak of
either use would expose both, and the release token would gain `workflows` and `issues` write.

- **Repository permissions:** Contents, Pull requests, Issues, Workflows and Commit statuses
  read and write; Checks, Dependabot alerts and Metadata read-only. Commit statuses is write
  because `minimumReleaseAge` posts a `renovate/stability-days` status; read-only makes
  Renovate abort the repository while the job still exits 0.
- **No webhook.** Only on this account.
- **Install it on every repository in `RENOVATE_TARGETS`**, including the runner's own if
  Renovate updates it.
- The token is minted per run with `actions/create-github-app-token`, scoped to the target
  repositories and to these permissions. A permission added to the App does nothing until it is
  added to the token step too.

## Secrets

The App's client ID and private key are repository secrets on the runner's repository:
organisation secrets do not reach private repositories on GitHub Free. Keep them in the
team's secret store and set them with a script
([templates/set-renovate-app-secrets.sh](../templates/set-renovate-app-secrets.sh)) that pipes
each value into `gh secret set` without printing it; re-run it after rotating the key. With
1Password's desktop integration, `op whoami` reports "not signed in" until something prompts,
so run the script from an interactive terminal.

## Runner settings

- `RENOVATE_REQUIRE_CONFIG: required` and `RENOVATE_ONBOARDING: "false"`: a repository without
  a `renovate.json5` is skipped, and no onboarding pull requests open.
- Commits are authored as the App's bot user (`<slug>[bot]`, with its user id).
- `workflow_dispatch` with `dryRun` and `logLevel`, so a change can be tried before the cron.
- A zero exit does not show Renovate did anything. Check each repository's Dependency
  Dashboard after changing the App, its permissions or the workflow. The dashboard is not
  rewritten on a run with nothing new, so its timestamp cannot serve as a per-run check.
