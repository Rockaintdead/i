# Repository Operating Rules

## Purpose And Authority

This repository is iQ's engineering and evidence layer. Notion remains the human control plane for its designated records. Follow the rule: one fact, one current owner, many useful views.

`README.md` is an orientation surface. It does not override the authoritative sources it links to.

## Required Orientation

Before consequential iQ work:

1. Read `README.md`.
2. Read the relevant record under `docs/`.
3. Read `srt.yaml` when the work concerns SRT, policy, authority, or enforcement.
4. Resolve the relevant current authority source before acting.

Do not treat chat history, search results, a document index, or a historical record as authority when a current owner must be resolved.

## Scope And Human Gates

Discussion, inspection, and planning are not implementation authority. Agents may inspect and propose within the request, but must stop before any production, schema, deployment, data migration, credential, permission, deletion, bulk, or external-send action unless the Owner explicitly authorised that specific scope.

When the actual state materially differs from the authorised plan, stop and report the difference, impact, evidence, and authority needed.

## SRT Contract

`srt.yaml` is an exact contract, not illustrative configuration. Any SRT change must preserve its required structure and values and must be verified by `.github/workflows/validate-SRT.yml`.

The current workflow runs only when `srt.yaml` changes. Documentation-only changes do not create SRT workflow evidence and must not be described as SRT validation.

## Evidence And Completion

Do not claim work is done, verified, live, deployed, saved, migrated, protected, or working without direct evidence.

For consequential work, record the exact change, authority, commit, test or workflow evidence, remaining limitation, and next human gate. A successful tool call, write response, or local build alone is not proof of the intended outcome.

## Secrets And Repository Hygiene

Never commit credentials, tokens, connection strings, private data, personal records, environment files, or unapproved exports. Do not overwrite unrelated work, make destructive changes without explicit authority, or create a parallel owner, database, or control surface where an existing canonical owner applies.

## Phase 3 Boundary -- Memory Model V1

Phase 3 documents the researched Working, Episodic, Semantic, and Procedural memory model. It does not authorise runtime implementation, schema changes, memory migration, deployment, data movement, deletion, or Notion-owner changes.

Until separate authority is given, the only permitted Phase 3 action is a read-only audit that produces an `EXISTS -> REUSE -> MISSING -> RECOVERY-ONLY` map.

## README Is The iQ Front Door

`README.md` is the human-facing GitHub home for iQ. Keep it concise, current, and readable without requiring a person to inspect the repository tree or chat history.

For every consequential iQ change, before reporting completion:

1. Update the relevant human-readable record under `docs/` with authority, scope, change, evidence, and remaining limitations.
2. Update `README.md` with the current state, an evidence link, and any material item that remains unverified or awaits authority.
3. Do not claim the README reflects a live system state without direct verification.

The README is an orientation and status surface. It links to canonical owners and detailed evidence; it does not replace them or become a competing source of truth.
