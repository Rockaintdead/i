# iQ Memory System Active-Build Boundary

**Date:** 16 September 2026  
**Status:** recorded; GitHub publication verification pending  
**Authority:** Owner authorised the active-versus-legacy boundary, restoration of Policy 1, and the matching README status statement.

## Scope

This record covers the documentation-only boundary for the new iQ Memory System.
It does not authorise runtime implementation, database work, deployment, data
migration, credential changes, or work in `C:\Users\User\iQ\iQ Space`.

## Decision

`Rockaintdead/i` is the sole active build target for the new iQ Memory System.

`C:\Users\User\iQ\iQ Space` is legacy reference material. It is not an
implementation target, runtime target, deployment target, or architectural
authority for the new memory system unless the Owner explicitly authorises a
named, read-only comparison or migration task.

## Change

Commit `ad9ed3118910debcf4d50ca79afe7a25545b576a`:

- added the mandatory iQ Architecture Boundary at the beginning of `AGENTS.md`;
- retained the existing mandatory Policy 1 contract and repository operating rules;
- added the active Memory V1 build-location statement and this record's link to
  `README.md`.

## Verification Evidence

- Local Git whitespace validation (`git diff --check`) passed before the commit.
- Local Git commit completed with the exact commit ID above.
- At the time of this record, remote GitHub push and read-back verification remain
  pending.

## Remaining Human Gate

Any Memory V1 implementation remains a separate authority decision. The next
permitted work is read-only review of the research and current repository
structure, followed by a bounded proposal for an implementation stage.
