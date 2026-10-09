# claude-plugin-dependency-updates

A Claude Code plugin with one skill, `dependency-updates`: keep every pinned dependency in a
GitHub repository or org current, with Dependabot and self-hosted Renovate splitting the pins
so each has exactly one owner.

The skill covers three jobs:

- **Set up** dependency updates in a repository or org: inventory every pin, assign each an
  owner, write `dependabot.yaml` and `renovate.json5`, run Renovate from one runner per org as
  its own GitHub App, and gate CI on known vulnerabilities.
- **Audit** a repository or org for pins nothing updates, or that two things update.
- **Add a pin** with its owner in the same pull request.

It carries the shared policy (cooldowns, grouping, the commit type each kind of update gets),
templates for both bots' configs and the runner workflow, how to verify a configuration
locally before it runs, and the pitfalls that make a configuration look right when it is not.

## Install

```
/plugin marketplace add yo61/claude-skills
/plugin install dependency-updates
```

## Layout

- `skills/dependency-updates/SKILL.md`: the rule, who owns which kind of pin, and the steps.
- `skills/dependency-updates/references/`: policy, inventory, runner, verification and
  pitfalls, each read when the skill points to it.
- `skills/dependency-updates/templates/`: `dependabot.yaml`, `renovate.json5`, the runner
  workflow, and a script that sets the runner's App secrets from 1Password.

CI checks `plugin.json` and each skill's front matter, that every relative link in a skill
resolves, and lints the templates: actionlint on the runner workflow, shellcheck and shfmt on
the script, and Renovate's own validator on `renovate.json5`.

## Updates to this repository

It follows its own rule. Dependabot keeps the action SHAs and pre-commit hooks;
`renovate.json5` gives Renovate the tool versions CI installs, which `yo61`'s Renovate runner
updates once it covers this repository. The templates' versions are examples, not pins, and
nothing updates them; the skill says to look up current versions when copying.

## License

MIT, see [LICENSE](LICENSE).
