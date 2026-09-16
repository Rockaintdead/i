# iQ Enforcement Spine V1

**Date:** 2026-09-16
**Repository:** `Rockaintdead/i`
**Stage:** Stages 1 and 2 evidenced; Phase 3 memory-model research recorded.
**Status:** Stage 1 verified from GitHub commit and workflow evidence. Stage 2 production schema application is structurally verified. Phase 3 is a research and design record only; no Phase 3 runtime implementation is claimed.

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

---

## 10. Phase 3 -- Memory Model V1 Research Record

**Authority:** The Owner requested that the current iQ memory-model research be recorded in this human-readable Git document on 2026-09-16.

**Scope of this phase:** Record the researched iQ memory model and its implementation sequence. This phase does not authorize runtime implementation, Neon or D1 schema changes, memory migration, deployment, data movement, deletion, or changes to any Notion owner.

### 10.1 Research conclusion

iQ memory is not one generic memory store. The intended model has four distinct, cooperating lanes:

- **Working memory:** compact, high-signal, scoped context for continuing work. It may include provisional context, active work, blockers, and unresolved material. It is not automatically canonical truth.
- **Episodic memory:** dated evidence of what happened, including conversations, observations, actions, receipts, and experiences.
- **Semantic memory:** durable knowledge, understood facts, preferences, conclusions, relationships, and learned knowledge that should influence later reasoning.
- **Procedural memory:** approved reusable methods, workflows, skills, and operating procedures.

The current human-readable owner is `iQ Memory`, which declares these four lanes. Its current verification state is `Degraded`; the existence of the model and owner does not prove that the runtime implementation works end to end.

### 10.2 Boundaries

- **Current Position is not a fifth memory type.** It is a scoped, verified projection assembled from canonical owners, accepted memory, evidence, and active commitments. It answers: objective, present state, material change, active work, blockers, decisions needed, next action, and evidence/freshness.
- **Prospective memory is not a separate generic memory lane.** Future commitments remain owned by their specialist systems: Goals, Projects, Tasks, Routines, Bills, and calendar records. Working Memory and Current Position may reference them.
- **Domain truth remains with its declared owner.** Memory may point to a Task, Project, decision, financial record, file, person, or relationship, but must not replace that owner's current truth.
- **Search and vector retrieval are discovery aids, not authority.** Retrieved material must resolve through the relevant current owner and evidence rules before it can guide consequential work.
- **Legacy Working Memory and historical SAVEs are recovery evidence only.** They must never silently become the current Working-memory route.

### 10.3 Admission and lifecycle model

The researched path is:

```text
Signal or interaction
  -> capture source and scope
  -> episodic evidence
  -> candidate interpretation
  -> compare with canonical owner and existing memory
  -> promote, correct, defer, or mark conflict under the relevant rule
  -> reconcile Working Memory / Current Position
  -> retrieve bounded, source-linked context when needed
```

An episode is not automatically a fact. A model interpretation is not automatically a remembered truth. A procedure is not automatically approved because it worked once. Corrections must retain the earlier state, source, and reason for supersession.

### 10.4 Proposed build sequence

1. Read-only audit the existing `iQ Memory` four-lane schema, current code paths, owner routing, and legacy Working Memory records. Produce an `EXISTS -> REUSE -> MISSING -> RECOVERY-ONLY` map.
2. Define lane-specific admission, lifecycle, scope, provenance, verification, confidence, conflict, supersession, and retention rules.
3. Implement and prove episodic capture first: authenticated, dated, scoped source evidence and operation receipts.
4. Implement a Working Memory reconciler that creates compact per-scope continuity records from canonical owners and relevant evidence.
5. Implement controlled semantic promotion and correction, preserving evidence and historical versions.
6. Implement procedural learning as versioned candidate methods linked to the canonical Prompts/procedure owner; do not duplicate procedure text into a competing memory owner.
7. Implement bounded cross-lane retrieval: current canonical owner, verified Working Memory, relevant Semantic memory, relevant Episodes, and Procedural memory only when deciding how to operate.
8. Implement Current Position as a derived, scoped service rather than a manual SAVE lookup.
9. Prove one end-to-end loop in an isolated preview: capture -> episode -> Working reconciliation -> verified semantic promotion -> fresh-session retrieval with evidence -> correction -> non-retrieval after removal from active memory.
10. Only after the core loop is proven, consider proactive consolidation, index rebuilding, conflict detection, candidate lessons, and a nightly learning cycle.

### 10.5 Phase 3 acceptance boundary

Phase 3 can only be called implemented after a fresh, authenticated client can complete the following without relying on chat history:

1. Capture a meaningful source event with scope and provenance.
2. Retrieve its episodic record correctly.
3. Reconcile a bounded Working-memory record for the same scope.
4. Promote one verified item to Semantic memory through its declared rule.
5. Retrieve the current result in a new session with cited source/evidence.
6. Correct the item without losing its earlier version or reason for change.
7. Exclude a removed item from active retrieval and state the exact deletion/retention verification level honestly.
8. Retrieve an approved procedure without presenting a model-generated suggestion as an approved method.

### 10.6 Evidence sources used for this record

- Current iQ Memory owner record: `https://app.notion.com/p/a3491085d0424b40b530b7bc4d71e66a`
- Current iQ Intelligence page: `https://app.notion.com/p/ea8c641336cc43088217fbde7eae4c11`
- Current Spine: `https://app.notion.com/p/3d4a3bb9a4028187828dd4187959e427`
- iQ Intelligence Architecture, Memory, Bootstrap & Notion Control Plane proposal v2.0: `https://app.notion.com/p/3daa3bb9a40281da855be0e22fa50a8f`
- iQ Second Brain -- Purpose, Findings & Completion Plan: `https://app.notion.com/p/3dca3bb9a402817e9ae6ee781a752177`

### 10.7 Stop point

This record documents the Phase 3 research model only. The next action is the proposed read-only Memory Model V1 audit. Any implementation, schema change, migration, deployment, or data operation requires separate explicit authorization.

---

## 11. Repository Agent Operating Rules

**Authority:** The Owner explicitly authorised the addition of the standing repository agent rules on 2026-09-16.

**Change:** `AGENTS.md` now defines the repository's operational rules for purpose and authority, required orientation, scope and human gates, the exact SRT contract, evidence before completion claims, secrets and repository hygiene, the Phase 3 Memory Model V1 boundary, and README maintenance.

**Why:** The README is a human-facing iQ front door, but it cannot by itself ensure that future intelligence clients resolve authority, respect human gates, preserve the exact SRT contract, maintain evidence, and stop at Phase 3's implementation boundary.

**Verification boundary:** This is a documentation and repository-instruction change only. It does not prove runtime enforcement, workflow execution, deployment, authentication, memory functionality, or production behaviour.

**Standing rule:** For every consequential iQ change, future agents must update the detailed human-readable record under `docs/` and the current-state summary in `README.md` before reporting completion.

---

## 12. README North Star and Product Positioning

**Authority:** The Owner explicitly approved the README north-star wording on 2026-09-16.

**Change:** The README now leads with the product promise: `Know me. Understand what matters. Hold the thread. Help me move toward the future I chose.` It defines the North Star as helping people move toward the future they choose without losing the thread of their lives.

**What iQ is building:** A trusted personal intelligence system that captures what happens, remembers what matters, connects relevant context, shows what is true now, and helps a person take the next useful action. The README also names the intended product components: one intelligence layer across life and work, distinct memory responsibilities, a calm Current Position, and evidence-backed help with human authority retained.

**Source grounding:** This wording is grounded in the current iQ Second Brain purpose and product promise, and is consistent with the Current Spine's purpose of helping Alan understand his position, choose his direction, and make meaningful progress.

**Verification boundary:** This is a documentation and product-positioning change only. It does not represent a production launch, working Memory V1 runtime, verified customer outcome, or changed system authority.

---

## 13. Policy 1 Machine Contract

**Authority:** The Owner explicitly authorised installation of the supplied Policy 1 Machine Contract in `AGENTS.md` on 2026-09-16.

**Change:** Policy 1 is now the first repository instruction. It is mandatory for repository agents and takes priority over the repository-specific operating rules that follow it.

**Contract coverage:** Truth, authority, plan lock, evidence before claims, definition of done, certainty labels, resource discipline, measurable progress, stop conditions, error disclosure, Owner override, three-strikes enforcement, no loopholes, the execution loop, and the required acknowledgement.

**Verification boundary:** This records an agent instruction and governance rule. It does not itself prove that any runtime, workflow, deployment, database, memory service, or external system enforces Policy 1.
