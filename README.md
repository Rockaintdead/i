# iQ

## Know me. Understand what matters. Hold the thread. Help me move toward the future I chose.

iQ is a trusted personal intelligence system: a persistent companion that captures what happens, remembers what matters, connects relevant context, shows what is true now, and helps a person take the next useful action toward the life they choose.

### The North Star

**Help people move toward the future they choose without losing the thread of their lives.**

### What We Are Building

- One personal intelligence layer across life and work.
- Memory that distinguishes what happened, what is true, what is current, and how to do things.
- A calm Current Position view that answers: where am I, what matters, what changed, and what next?
- Safe, evidence-backed help that proposes action while keeping the human in charge.

> **Current build state -- 17 September 2026**
> Stage 1 SRT validation is verified. Stage 2 task and evidence enforcement schema is structurally verified in production. **Memory V1 is now applied to Neon production and verified**, including multi-instance isolation constraints, source provenance structures, versioned semantic/procedural memory, Working Memory and Current Position uniqueness, and append-only audit protections. Production Memory V1 tables are currently empty: no personal memory has been ingested yet. The runtime Memory Service and Base44 Composer are **not yet connected** to this schema.
>
> **Active Memory V1 build location:** this repository. `C:\Users\User\iQ\iQ Space` is legacy reference material and is not an implementation or runtime target unless the Owner explicitly authorises a named, read-only comparison or migration task. See the [active-build boundary record](docs/2026-09-16-iQ-Memory-System-Active-Boundary.md).

---

## System Model

```text
You
  -> direction, judgement, and human approval
  -> iQ Intelligence
  -> memory, evidence, current position, and proposed action
  -> verified outcome
```

iQ is not intended to replace every system you use. Specialist systems retain their own truth. iQ provides the layer that connects them:

```text
identity -> context -> memory -> attention -> reasoning -> action -> verification -> learning
```

The governing principle is simple: **one fact, one current owner, many useful views.**

---

## Memory Model V1

iQ memory has four cooperating lanes. They are not interchangeable.

| Lane | Purpose |
|---|---|
| **Working** | Compact, scoped context for continuing work: active state, blockers, open loops, and next action. |
| **Episodic** | What happened and when: conversations, observations, actions, receipts, and experiences. |
| **Semantic** | Durable knowledge: verified facts, preferences, conclusions, relationships, and learned knowledge. |
| **Procedural** | Approved reusable methods, workflows, skills, and operating procedures. |

**Current Position** is not a fifth memory type. It is a verified, scoped view built from canonical owners, accepted memory, evidence, and active commitments.

Future commitments remain in Goals, Projects, Tasks, Routines, Bills, and calendar systems. Memory can connect to those records, but it does not replace their ownership.

Read the full [Phase 3 Memory Model V1 record](docs/2026-09-16-iQ-Enforcement-Spine-V1.md#10-phase-3----memory-model-v1-research-record) and the [Memory V1 implementation record](docs/2026-09-17-iQ-Memory-V1-implementation-record.md).

---

## How iQ Operates

```text
Signal or request
  -> resolve scope and authority
  -> capture evidence
  -> understand and propose
  -> obtain human approval where required
  -> execute once
  -> verify the actual outcome
  -> record evidence and update continuity
```

An interaction is not automatically a fact. A model suggestion is not automatically a decision. A successful tool call is not proof of a successful outcome.

For consequential work, iQ stops when authority, scope, evidence, or verification is missing.

---

## Where Things Live

| Place | Role |
|---|---|
| [Notion](https://app.notion.com/p/3d6a3bb9a40281f78146e1a565f9e651) | Human control, direction, knowledge, and designated canonical records. |
| [GitHub](https://github.com/Rockaintdead/i) | Engineering truth, source control, human-readable implementation records, and verification history. |
| iQ Core | Governed runtime: scoped continuity, memory, events, identity references, and evidence it needs to operate. |
| Specialist systems | Their own domain truth, such as tasks, finances, files, communications, and calendars. |

---

## Current Work

| Area | State | Evidence |
|---|---|---|
| SRT enforcement | Verified | [SRT conversation record](docs/2026-09-16-iQ-SRT-conversation-record.md) |
| Enforcement Spine V1 | Stages 1 and 2 evidenced | [Enforcement Spine record](docs/2026-09-16-iQ-Enforcement-Spine-V1.md) |
| Memory Model V1 | **Production schema applied and verified; runtime Memory Service still pending** | [Memory V1 implementation record](docs/2026-09-17-iQ-Memory-V1-implementation-record.md) |
| Repository operating rules | Current and published | [AGENTS.md](AGENTS.md) |
| Policy 1 machine contract | Mandatory for repository agents | [AGENTS.md](AGENTS.md#iq-machine-contract----policy-1) |

**Next proposed slice:** implement the runtime Memory Service against the live Neon schema, map authenticated Base44 users to `iq_instance_id`, then prove one end-to-end capture → promotion → recall → correction loop with provenance before enabling broader knowledge ingestion or semantic/vector retrieval.

---

## Start Here

### Human routes

- [Start -- everyday iQ dashboard](https://app.notion.com/p/3d6a3bb9a40281f78146e1a565f9e651)
- [Today](https://app.notion.com/p/3d6a3bb9a402810c9f18cf3ac3ccea02)
- [Knowledge](https://app.notion.com/p/3d6a3bb9a4028192bb8efa2ee8be160d)
- [Admin -- system control area](https://app.notion.com/p/3d6a3bb9a40281dab467f5b2a12c6169)

### Governing routes

- [Human + Intelligence Operating Contract](https://app.notion.com/p/3cba3bb9a40281ce9ea5cb95da70cc5c)
- [Current Spine](https://app.notion.com/p/3d4a3bb9a4028187828dd4187959e427)
- [System Directory](https://app.notion.com/p/3d7a3bb9a402817f8b0fd43ffdc98b88)
- [iQ Memory](https://app.notion.com/p/caeaa52d8e364916b42e7a304d7d429a)
- [AI Failure Modes and safeguards](https://app.notion.com/p/3dca3bb9a402818daf3fe23970849c63)

### Engineering routes

- [SRT authority file](srt.yaml)
- [GitHub workflows](.github/workflows/)
- [Memory V1 production migration](db/migrations/2026-09-17-memory-v1.sql)
- [Human-readable Git documentation](docs/)

---

## The Rules That Matter

- Read before write.
- Discussion is not execution authority.
- Never exceed the authorised scope.
- Preserve evidence, prior states, and reasons for corrections.
- Search and vector retrieval can locate material; they cannot decide what is current or true.
- Verify real state before reporting success.
- When actual state materially differs from the plan: **stop and report.**

**Operating loop:** `UNDERSTAND -> INSPECT -> PLAN -> AUTHORISE -> EXECUTE -> VERIFY -> REPORT`

---

## Keeping This Page Current

This README is iQ's human-facing GitHub front door.

Every consequential iQ change must update this page with the current state, the relevant evidence link, and what remains unverified or awaiting authority. The detailed record belongs in [docs/](docs/); this page remains the short, readable map.

---

## For Intelligence Clients

Use this page for orientation, then resolve the authoritative source for the task:

```text
Operating Contract -> Current Spine -> System Directory -> relevant current owner/source -> act only when authorised -> verify
```

This README is a route map, not an authority that overrides the sources it links to.