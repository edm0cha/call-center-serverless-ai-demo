package terraform

import rego.v1

# ── Helpers ───────────────────────────────────────────────────────────────────

_mutating(change) if change.actions[_] == "create"

_mutating(change) if change.actions[_] == "update"

_wildcard_action(action) if action == "*"

_wildcard_action(action) if action[_] == "*"

# ── Rule 1: No wildcard IAM actions ──────────────────────────────────────────
# Wildcard actions grant every AWS API call. Require explicit action lists so
# the blast radius of any credential compromise stays bounded.

deny contains msg if {
  r := input.resource_changes[_]
  r.type == "aws_iam_policy"
  _mutating(r.change)
  policy := json.unmarshal(r.change.after.policy)
  stmt := policy.Statement[_]
  _wildcard_action(stmt.Action)
  msg := sprintf("no wildcard IAM actions: %s has Action \"*\"", [r.address])
}

deny contains msg if {
  r := input.resource_changes[_]
  r.type == "aws_iam_role_policy"
  _mutating(r.change)
  policy := json.unmarshal(r.change.after.policy)
  stmt := policy.Statement[_]
  _wildcard_action(stmt.Action)
  msg := sprintf("no wildcard IAM actions: %s has Action \"*\"", [r.address])
}

# ── Rule 2: Lambda function URLs must use IAM auth ────────────────────────────
# authorization_type = "NONE" exposes the function URL to the public internet.
# Require AWS_IAM so only SigV4-signed callers can invoke the function.

deny contains msg if {
  r := input.resource_changes[_]
  r.type == "aws_lambda_function_url"
  _mutating(r.change)
  r.change.after.authorization_type == "NONE"
  msg := sprintf("public lambda URL: %s must set authorization_type = \"AWS_IAM\"", [r.address])
}

# ── Rule 3: All resources must have required tags ─────────────────────────────
# Every resource must carry Organization, Repository, and Environment tags so
# resources can be traced to their owning team, source repo, and deployment tier.

_required_tags := {"Organization", "Repository", "Environment"}

deny contains msg if {
  r := input.resource_changes[_]
  r.mode == "managed"
  _mutating(r.change)
  is_object(r.change.after.tags_all)
  tag := _required_tags[_]
  not r.change.after.tags_all[tag]
  msg := sprintf("missing required tag: %s must set tags.%s", [r.address, tag])
}
