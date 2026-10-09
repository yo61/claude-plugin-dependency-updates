# Verify

Each check runs in the repository whose config it proves.

1. **Validate the config.**
   `npx --yes --package renovate@<major> -- renovate-config-validator --strict renovate.json5`.
2. **Extract.** Renovate's local platform reads the committed tree, so commit the config first
   (a throwaway commit is fine; amend it afterwards), then:

   ```sh
   LOG_LEVEL=debug LOG_FORMAT=json npx --yes --package renovate@<major> -- \
     renovate --platform=local --dry-run=extract > extract.json
   jq -r 'select(.packageFiles) | .packageFiles | to_entries[] | .key as $m
     | .value[] | .packageFile as $f | .deps[]
     | "\($m)\t\($f)\t\(.depName)\t\(.currentValue // "")\t\(.datasource // "")"' extract.json
   ```

   Done when only the managers in `enabledManagers` appear, and every Renovate-owned pin from
   the inventory is listed.
3. **Look up.** The same command with `--dry-run=full` and `GITHUB_COM_TOKEN=$(gh auth token)`
   (the local platform reads that variable, not `RENOVATE_TOKEN`). The "packageFiles with
   updates" log line shows each proposed `newValue` and branch: check groups, cooldowns
   (`pendingVersions` lists releases still waiting) and that a range was not rewritten
   unexpectedly. The local platform does not log commit messages.
4. **Dry-run the runner**: dispatch the workflow with `dryRun: true`. Done when every target
   logs "Repository started" and "Repository finished" and no `WARN` or `ERROR`.
5. **First real run.** Check each pull request's title against
   [policy.md](policy.md)'s commit types, and its CI.
6. **Prove a gate fails.** For a new CI vulnerability gate, run it against a commit that has a
   known advisory and confirm it exits non-zero.
