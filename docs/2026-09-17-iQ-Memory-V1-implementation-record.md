# iQ Memory V1 — Implementation Record

**Date:** 2026-09-17
**Repository:** `Rockaintdead/i`
**Neon project:** `iQ Core` (`hidden-bar-33718068`)
**Production branch:** `production` (`br-gentle-bird-akmv94n8`)
**Status:** PARTIALLY COMPLETE — implemented and behaviour-tested on an isolated Neon branch; **not applied to production**.

## Authority

The Owner explicitly authorised building the researched iQ Memory V1 after review of the Notion knowledge base and existing Memory Model V1 record.

## Source design reconciled

The implementation follows the current four-lane memory owner and the deeper research already present in Notion:

- Working — compact resumable context.
- Episodic — what happened and when.
- Semantic — durable knowledge and understood facts.
- Procedural — approved reusable methods and workflows.
- Current Position remains a derived projection, not a fifth memory type.
- Search/vector retrieval is discovery only and cannot decide current truth.
- Source/evidence is preserved before interpretation.
- Candidate understanding is distinct from approved memory.
- Corrections supersede prior versions without deleting history.
- Every current memory value must retain provenance.

## Existing production state before this work

Production contained only the Enforcement Spine tables:

- `interactions`
- `tasks`
- `task_events`
- `evidence`

All four contained zero rows at inspection time. The existing `evidence` table is specifically task-verification evidence and was therefore not repurposed as the personal knowledge store.

## Memory V1 schema tested

The isolated branch adds:

- `iq_instances`
- `memory_scopes`
- `memory_sources`
- `memory_episodes`
- `memory_operations`
- `memory_candidates`
- `memory_slots`
- `memory_versions`
- `memory_version_evidence`
- `memory_events`
- `memory_conflicts`
- `working_memory_snapshots`
- `current_positions`
- `memory_receipts`
- `memory_retrieval_log`
- `erasure_jobs`

### Key invariants

1. Every record belongs to an `iq_instance_id`.
2. Scope foreign keys are composite with `iq_instance_id`, preventing cross-instance references.
3. Exactly one Owner scope is allowed per iQ instance.
4. Semantic/Procedural current truth is represented by a stable slot plus immutable/versioned values.
5. Only one `ACCEPTED` version may exist for a slot at once.
6. Working Memory permits only one `CURRENT` snapshot per instance/scope.
7. Current Position permits only one `CURRENT` projection per instance/scope.
8. Source/evidence hashes are retained with accepted memory versions.
9. Candidate claims remain separate from accepted current memory.
10. Explicit correction creates a new version and supersedes the old version.
11. Memory receipts and memory events are intended to be append-only at runtime.
12. Vector retrieval is intentionally not authoritative and pgvector has not been enabled yet.

## Isolated Neon test branch

**Temporary branch:** `mcp-migration-2026-09-17T12-26-56`
**Branch ID:** `br-ancient-band-akja5k7p`
**Parent:** production

Synthetic data only was used.

## Behavioural test evidence

### PASS — schema creation

The isolated branch contains the existing four enforcement tables plus all 16 Memory V1 tables listed above.

### PASS — semantic promotion with exact source provenance

A synthetic source statement was captured, linked to an episodic record, promoted through an approved semantic candidate, written into a stable semantic slot/version, and linked back to the exact source hash/text.

Read-back returned:

- fact key: `person:self/working_style`
- current value: `short direct instructions`
- lifecycle: `ACCEPTED`
- slot revision: `1`
- exact source text present
- Working Memory present
- Current Position present

### PASS — cross-instance isolation

A deliberate attempt to create a source under User B while referencing User A's scope was rejected by the composite foreign key:

`memory_sources_iq_instance_id_scope_id_fkey`

### PASS — exactly one current semantic value

A deliberate attempt to insert a second `ACCEPTED` version for the same memory slot was rejected by:

`memory_versions_one_accepted_idx`

### PASS — exactly one current Working Memory

A deliberate attempt to create a second `CURRENT` Working Memory snapshot for the same instance/scope was rejected by:

`working_memory_one_current_idx`

### PASS — correction and supersession

A synthetic correction was applied in one transaction:

- previous version changed to `SUPERSEDED` with `valid_to` set;
- corrected source captured separately;
- corrected candidate created as `EXPLICIT_CORRECTION`;
- new accepted version linked to `previous_version_id`;
- slot head moved to the corrected version;
- slot revision incremented from 1 to 2;
- correction evidence linked to the new version.

Read-back proved both versions remain queryable while only the new version is current.

### PASS — append-only trigger behaviour on isolated branch

A dedicated PostgreSQL trigger function was added on the isolated branch. Deliberate UPDATE/DELETE attempts against `memory_receipts` and `memory_events` were rejected with an append-only error.

### REJECTED ALTERNATIVE — forced RLS for append-only behaviour

Forced row-level security was tested as a migration-wrapper-friendly alternative. Under the Neon owner role an UPDATE still succeeded. That approach was rejected and the test branch was restored to trigger-based append-only enforcement.

## Migration-tool limitation discovered

Neon's prepared-migration wrapper rejected PostgreSQL trigger-function bodies, both dollar-quoted and single-quoted, before creating a clean second migration branch.

This is a tooling/packaging limitation, not a failure of the tested database behaviour. Direct `run_sql` on the isolated branch successfully created the same function and triggers.

**Consequence:** the currently prepared migration must not be promoted to production because its original migration payload does not include the manually added append-only trigger function/triggers.

## Production boundary

No Memory V1 table has been added to production.
No production data has been written or altered.
No pgvector extension has been enabled.
No Base44 memory traffic has been pointed at Neon yet.
No legacy Working Memory has been imported.

## Next gate

Before production application:

1. Preserve the exact tested DDL in the repository migration package.
2. Apply the DDL through an execution path that supports the append-only function/triggers exactly as tested.
3. Re-run the behavioural suite against the clean migration candidate.
4. Obtain explicit Owner approval for the production schema change.
5. Apply to Neon `production`.
6. Read back all tables, constraints, indexes and triggers.
7. Only then implement the runtime Memory Service and connect Base44 Composer → iQ Core → Memory Service.

## Runtime acceptance target

The first end-to-end runtime proof remains:

`Base44 turn -> exact source capture -> episodic evidence -> semantic candidate -> governed promotion -> Working Memory reconciliation -> fresh-session retrieval with provenance -> correction -> old value remains historical -> new value is current.`
