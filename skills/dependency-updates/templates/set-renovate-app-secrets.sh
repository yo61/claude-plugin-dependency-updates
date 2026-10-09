#!/usr/bin/env bash
# Sets the Renovate App's credentials as Actions secrets on the repository where the Renovate
# workflow runs. The 1Password item holds a "Client ID" field and the private key as its one
# attachment. Each value goes from 1Password straight into gh through a pipe: it is never
# printed, held in a variable, or written to disk.
#
# A repository secret, not an organisation secret: on GitHub Free, organisation secrets are not
# available to private repositories.
set -euo pipefail

# Set these four for the org.
org=example-org
vault=Example
item="example-org-renovate GitHub App"
repo=infrastructure

for cmd in op gh jq; do
  command -v "$cmd" > /dev/null || {
    echo "ERROR: $cmd is not installed." >&2
    exit 1
  }
done
op whoami > /dev/null 2>&1 || {
  echo "ERROR: the 1Password CLI is not signed in. Run: op signin" >&2
  exit 1
}

# The private key is the item's one attachment, read by its file name. Only the names are
# listed here, never the contents.
key_file=$(op item get "$item" --vault "$vault" --format json \
  | jq -er '[.files[]?.name] | if length == 1 then .[0]
      else error("expected one attachment, found \(length)") end')

op read --no-newline "op://$vault/$item/Client ID" \
  | gh secret set RENOVATE_APP_CLIENT_ID --repo "$org/$repo"
op read --no-newline "op://$vault/$item/$key_file" \
  | gh secret set RENOVATE_APP_PRIVATE_KEY --repo "$org/$repo"
