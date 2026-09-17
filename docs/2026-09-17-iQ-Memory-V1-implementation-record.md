# iQ Memory V1 — Implementation Record

**Date:** 2026-09-17
**Repository:** `Rockaintdead/i`
**Neon project:** `iQ Core` (`hidden-bar-33718068`)
**Production branch:** `production` (`br-gentle-bird-akmv94n8`)
**Status:** PRODUCTION SCHEMA APPLIED AND VERIFIED — Memory V1 schema is live in Neon production; runtime Memory Service and Base44 traffic are not yet connected.

## Authority

The Owner explicitly authorised building the researched iQ Memory V1 after review of the Notion knowledge base and existing Memory Model V1 record.

After isolated-branch implementation and behavioural testing, the Owner was shown the production gate and explicitly answered **yes** to applying Memory V1 to Neon production on 2026-09-17.

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

## Existing production state before Memory V1

Immediately before production application, Neon `iQ Core` / `production` / `neondb` contained only the Enforcement Spine tables:

- `interactions`
- `tasks`
- `task_events`
- `evidence`

No Memory V1 tables were present. The existing `evidence` table is specifically task-verification evidence and was therefore not repurposed as the personal knowledge store.

## Memory V1 production schema

Production now includes:

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

The exact repository migration package is:

`db/migrations/2026-09-17-memory-v1.sql`

### Key invariants

1. Every memory record belongs to an `iq_instance_id`.
2. Scope foreign keys are composite with `iq_instance_id`, preventing cross-instance references.
3. Exactly one Owner scope is allowed per iQ instance.
4. Semantic/Procedural current truth is represented by a stable slot plus immutable/versioned values.
5. Only one `ACCEPTED` version may exist for a slot at once.
6. Working Memory permits only one `CURRENT` snapshot per instance/scope.
7. Current Position permits only one `CURRENT` projection per instance/scope.
8. Source/evidence hashes are retained with accepted memory versions.
9. Candidate claims remain separate from accepted current memory.
10. Explicit correction creates a new version and supersedes the old version.
11. `memory_receipts` and `memory_events` are append-only through PostgreSQL triggers.
12. Vector retrieval is intentionally non-authoritative and pgvector has not been enabled yet.

## Isolated-branch implementation proof

**Temporary branch:** `mcp-migration-2026-09-17T12-26-56`
**Branch ID:** `br-ancient-band-akja5k7p`
**Parent:** production

Synthetic data only was used on the isolated branch.

### PASS — schema creation

The isolated branch contained the existing four enforcement tables plus all 16 Memory V1 tables listed above.

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

### PASS — append-only behaviour on isolated branch

A dedicated PostgreSQL trigger function was added on the isolated branch. Deliberate UPDATE/DELETE attempts against `memory_receipts` and `memory_events` were rejected with an append-only error.

### REJECTED ALTERNATIVE — forced RLS for append-only behaviour

Forced row-level security was tested as a migration-wrapper-friendly alternative. Under the Neon owner role an UPDATE still succeeded. That approach was rejected and trigger-based append-only enforcement was retained.

## Production application — 17 September 2026

### Execution path

Neon's prepared-migration wrapper could not package the PostgreSQL trigger-function body reliably. The exact repository DDL was therefore applied to production through a direct Neon SQL transaction, including the tested append-only trigger function and both triggers in the same transaction.

The production transaction completed successfully.

### PASS — production table read-back

A post-application query returned the original four Enforcement Spine tables plus all 16 Memory V1 tables.

### PASS — production key-constraint read-back

Production read-back confirmed, among other protections:

- `memory_sources_iq_instance_id_scope_id_fkey` — tenant/scope-safe composite foreign key.
- `memory_operations_iq_instance_id_idempotency_key_key` — per-instance idempotency uniqueness.
- `memory_slots_iq_instance_id_scope_id_memory_lane_fact_key_key` — stable logical memory slot uniqueness.
- `memory_slots_current_version_fk` — slot head must point to a version belonging to the same instance and slot.

### PASS — production one-current indexes

Production read-back confirmed:

- `memory_scopes_one_owner_idx`
- `memory_versions_one_accepted_idx`
- `working_memory_one_current_idx`
- `current_positions_one_current_idx`

### PASS — production append-only trigger read-back

Production contains both UPDATE and DELETE trigger coverage for:

- `memory_events_append_only`
- `memory_receipts_append_only`

Both invoke `memory_append_only_guard()` before mutation.

### PASS — production rollback-only tamper test: memory events

A synthetic instance, owner scope and memory event were inserted inside one database transaction, followed by an attempted UPDATE of the event.

Result:

`NeonDbError: memory_events is append-only`

Because the failure occurred inside a transaction, the synthetic inserts rolled back. A direct read-back found `0` residual test rows.

### PASS — production rollback-only tamper test: memory receipts

A synthetic instance, owner scope, memory operation and receipt were inserted inside one database transaction, followed by an attempted UPDATE of the receipt.

Result:

`NeonDbError: memory_receipts is append-only`

The transaction rolled back. A direct read-back found `0` residual test rows.

### PASS — clean production data state

A final count across all 16 Memory V1 tables returned `0` rows in every table.

Therefore:

- no synthetic production test data remains;
- no personal memory data has been ingested yet;
- the schema exists but is still empty until the runtime Memory Service starts writing governed records.

## Current production boundary

Memory V1 schema: **live in production and structurally verified**.

Not yet done:

- runtime Memory Service implementation/wiring;
- Base44 Composer → iQ Core → Memory Service traffic;
- Base44 user → `iq_instance_id` identity mapping;
- live semantic promotion/reconciliation policy execution;
- knowledge ingestion from Notion, Drive, email, files or calendar;
- pgvector or any external semantic-index provider;
- legacy Working Memory import/reconciliation;
- 100-question semantic-memory acceptance test against the live runtime.

The temporary preparation branch `br-ancient-band-akja5k7p` still exists and is non-production. It has not been treated as an authority or runtime target.

## Next gate

Implement the runtime Memory Service against the now-live production schema, then prove the first end-to-end path without bypassing SRT or identity isolation:

`Base44 turn -> iQ Core -> exact source capture -> episodic evidence -> semantic candidate -> governed promotion -> Working Memory reconciliation -> fresh-session retrieval with provenance -> correction -> old value remains historical -> new value is current.`

Only after that runtime proof should broader knowledge ingestion and vector/hybrid retrieval be enabled.
