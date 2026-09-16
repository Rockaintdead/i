# iQ Enforcement Spine V1

**Date:** 2026-09-16
**Repository:** `Rockaintdead/i`
**Stage:** Stage 1 only
**Status:** Stage 1 verified from GitHub commit and workflow evidence.

---

## 1. Purpose

iQ Enforcement Spine V1 defines the first human-readable Git record for the enforcement path:

```text
Capture -> TALK/DO -> SRT -> Task/Authority -> Capability -> Evidence -> Verification
```

The purpose is to keep consequential iQ work governed by a traceable record rather than by model memory, unstated assumptions, or informal claims of completion.

This document records the Stage 1 scope: repair the SRT file, prove the existing SRT validator passes, and preserve the enforcement rules in human-readable Git documentation.

---

## 2. Standing Documentation Rule

Consequential iQ work must update human-readable Git documentation.

For this rule, consequential work includes any change that affects:

- authority or approval paths
- SRT, policy, or enforcement behavior
- runtime gates or capability access
- task, evidence, interaction, memory, or verification records
- GitHub, Neon, Notion, files, deployment, email, browser, or other operational capabilities
- any claim that iQ has been completed, verified, protected, migrated, deployed, saved, or made live

The documentation must be readable by a human without relying on chat history. It must state:

- what changed
- why it changed
- what authority allowed it
- what evidence verifies it
- what remains out of scope or unverified

If the documentation is missing, stale, or cannot be updated, consequential iQ work must stop and report that gap before claiming completion.

---

## 3. Stage 1 Authority and Scope Lock

Stage 1 was explicitly authorized for these actions only:

1. Create this new human-readable Git document for `iQ Enforcement Spine V1`.
2. Include the standing rule that consequential iQ work must update human-readable Git documentation.
3. Repair only `srt.yaml` to the exact valid YAML structure below.
4. Verify the existing `.github/workflows/validate-SRT.yml` workflow actually passes.
5. Record exact commit and workflow evidence in this document.
6. Stop before Stage 2 or any Neon/database changes and report for authorization.

No Neon, database, runtime gate, branch protection, deployment, or broader system change is authorized in Stage 1.

---

## 4. SRT Contract

The Stage 1 SRT contract is exactly:

```yaml
SRT: 1
LAW:
  PASS: CONTINUE
  ELSE: FAIL
FAIL:
  REPORT: HUMAN
  STOP: TRUE
```

The rule meaning is:

- If SRT passes, continue.
- Else, fail.
- On failure, report to the human and stop.

---

## 5. Enforcement Spine V1

The intended enforcement spine is:

```text
Human input
  -> capture original record
  -> classify TALK or DO
  -> validate current SRT
  -> bind authorized task and scope
  -> allow only scoped capabilities
  -> record consequential action evidence
  -> verify against acceptance criteria
  -> report status with evidence
```

The core rules are:

- Capture before interpretation.
- Discussion is not execution authority.
- Consequential execution requires an authorized task.
- SRT must pass before operational capability.
- Capability is limited to the authorized scope.
- Actions create evidence.
- Completion requires proof, not self-declaration.
- Missing, malformed, ambiguous, or failed authority means stop and report.

---

## 6. Stage 1 Evidence

This section is recorded from verified Git and GitHub Actions results.

**Documentation commit:** `5f3a65952c1809345ad701cd115ec8b0dcc82453`

**SRT repair commit:** `1aaceaf058e540356afe6ecb688cac898ca4987a`

**SRT content blob after repair:** `339274e9040709f83dbb0e3611239597a3d3d73c`

**Workflow:** `Validate SRT`

**Workflow file:** `.github/workflows/validate-SRT.yml`

**Workflow run:** `35093084753`

**Workflow URL:** `https://github.com/Rockaintdead/i/actions/runs/35093084753`

**Workflow event:** `push`

**Workflow head branch:** `main`

**Workflow head SHA:** `1aaceaf058e540356afe6ecb688cac898ca4987a`

**Workflow status:** `completed`

**Workflow conclusion:** `success`

**Job:** `validate`

**Job ID:** `104783798633`

**Job conclusion:** `success`

**Validated step:** `Validate SRT`

**Validated step conclusion:** `success`

---

## 7. Stop Point

Stage 1 stops after the SRT repair, documentation update, commit evidence, and workflow evidence are recorded.

Stage 2 would require separate human authorization before any Neon/database schema design, branch creation, migration, runtime gate implementation, or operational capability changes.

This document records no Stage 2 authorization and no Neon/database changes.
---
## 8. Stage 2 Authorization, Design, and Test Evidence
**Authority:** The Owner authorized Stage 2 in this conversation on 2026-09-16 after reviewing its stated scope.
**Scope executed:** Design and test the iQ Core enforcement schema on an isolated temporary Neon branch. No production schema, runtime gate, capability integration, deployment, or operational tool connection was changed.
**Discovery:** An earlier temporary branch named `test` already existed, contained `core_records`, `core_record_versions`, and `core_operations`, and had stored test data. It was not modified. A new branch was created to avoid overwriting or conflating that prior work.
**Temporary branch:** `stage2-enforcement-spine-v1`
**Branch ID:** `br-fragrant-band-akqiec0f`
**Parent:** `production`
**Branch type:** schema-only
**Expiry:** 2026-09-17 13:04:43 GMT+1
**Schema added on the temporary branch:**
- `interactions`: immutable captured source records; unique conversation sequence.
- `tasks`: task authority, SRT version/hash, acceptance criteria, guarded lifecycle, and verification state.
- `task_events`: append-only task-event ledger.
- `evidence`: append-only evidence ledger linked to a task and optional task event.
- Indexes for task-event order and verified-evidence lookup.
- Append-only triggers rejecting UPDATE or DELETE on `interactions`, `task_events`, and `evidence`.
- Task lifecycle trigger rejecting definition/authority mutation, deletion, invalid state transitions, and `COMPLETE` without verified evidence.
**Verified temporary-branch tests:**
1. Attempted to mark an `AWAITING_VERIFICATION` task `COMPLETE` with no verified evidence. Result: rejected with `COMPLETE requires verified evidence`.
2. Added a verified evidence record, then completed the same task. Result: one row showed `status = COMPLETE`, `verification_status = VERIFIED`, `has_verified_at = true`, `has_completed_at = true`, and `verified_evidence_count = 1`.
3. Attempted to rewrite an `interactions` record. Result: rejected as append-only.
**SQL editor evidence:** schema application completed successfully as 13 statements; constraint test transaction completed successfully as 13 statements; final verification query returned one row.
**Production boundary:** Production remains the default branch `production`; it was inspected only. No production database write, merge, migration, or promotion was performed.
**Stop point:** Stage 2 is tested only on the temporary branch. Human authorization is required before applying any schema to production. Stage 3 runtime-gate work remains out of scope and is not authorized by this record.
---
## 9. Stage 2 Production Application Evidence
**Authority:** The Owner explicitly authorized publication to GitHub `main` and application to Neon `production` in this conversation on 2026-09-16.
**GitHub documentation commit before production application:** `ba19b78f68ce3e74b80ed3dcf30ce153c3a14c37`.
**Neon target:** iQ Core, default branch `production` (branch ID `br-gentle-bird-akmv94n8`), database `neondb`.
**Pre-application inspection:** A read-only inventory found zero base tables in the `public` schema.
**Production application:** The tested schema was applied successfully as 13 SQL statements.
**Production read-back:** A metadata query returned these four tables:
- `interactions`
- `tasks`
- `task_events`
- `evidence`
It also returned these four live triggers:
- `interactions.interactions_append_only`
- `task_events.task_events_append_only`
- `evidence.evidence_append_only`
- `tasks.tasks_guarded_lifecycle`
**Verification boundary:** No synthetic test records were inserted into production. The negative and positive behavioural tests remain documented from the isolated temporary branch, where the identical schema was executed and verified before production application.
**Current status:** Stage 2 schema is applied and structurally verified in production. Stage 3 runtime-gate implementation remains out of scope and requires separate authorization.
