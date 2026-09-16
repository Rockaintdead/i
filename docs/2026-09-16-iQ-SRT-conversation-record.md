# iQ SRT Enforcement — Consolidated Conversation Record

**Date:** 2026-09-16  
**Repository:** `Rockaintdead/i`  
**Scope:** Consolidated record of the SRT / GitHub Actions discussion and work in this conversation.

---

## 1. Objective

The objective discussed on this page was to move from a simple written SRT rule toward enforceable controls around it.

The intended SRT contract is:

```yaml
SRT: 1
LAW:
  PASS: CONTINUE
  ELSE: FAIL
FAIL:
  REPORT: HUMAN
  STOP: TRUE
```

The core principle established in the conversation was:

> Protect the rule -> validate the rule -> build the gate -> lock tools behind the gate -> prove bypass fails -> roll out.

A major clarification was also made: simply pointing an AI or agent at `srt.yaml` does **not** force it to read or obey the file. The current GitHub Actions workflow only validates the SRT file when it changes. Runtime enforcement requires a separate gate in front of agent/tool access.

---

## 2. Initial proposal discussed

The proposed next file was:

```text
.github/workflows/validate-SRT.yml
```

Its purpose was to validate `srt.yaml` on push and pull-request changes to that file.

The requested safety properties were:

- `contents: read` only
- checkout pinned to a full commit SHA
- `persist-credentials: false`
- no commit step
- no push step
- no publishing step
- no deployment step
- no secrets requested
- no `pull_request_target`
- reject malformed or unexpected SRT content
- fail closed with a non-zero exit status

The checkout action SHA used was:

```text
11d5960a326750d5838078e36cf38b85af677262
```

This was verified as the commit behind `actions/checkout` v4.4.0 during the conversation.

---

## 3. Validator proposal

The workflow discussed and later observed in the correct GitHub Actions path was:

```yaml
name: Validate SRT

on:
  push:
    paths:
      - srt.yaml
  pull_request:
    paths:
      - srt.yaml

permissions:
  contents: read

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262
        with:
          persist-credentials: false

      - name: Validate SRT
        shell: bash
        run: |
          ruby <<'RUBY'
          require "yaml"

          class ValidationError < StandardError; end

          def reject_duplicate_keys!(node)
            case node
            when Psych::Nodes::Mapping
              seen = {}

              node.children.each_slice(2) do |key, value|
                unless key.is_a?(Psych::Nodes::Scalar)
                  raise ValidationError, "mapping keys must be scalars"
                end

                if seen.key?(key.value)
                  raise ValidationError, "duplicate key: #{key.value}"
                end

                seen[key.value] = true
                reject_duplicate_keys!(value)
              end
            when Psych::Nodes::Stream,
                 Psych::Nodes::Document,
                 Psych::Nodes::Sequence
              node.children.each { |child| reject_duplicate_keys!(child) }
            end
          end

          expected = {
            "SRT" => 1,
            "LAW" => {
              "PASS" => "CONTINUE",
              "ELSE" => "FAIL"
            },
            "FAIL" => {
              "REPORT" => "HUMAN",
              "STOP" => true
            }
          }

          begin
            yaml = File.read("srt.yaml")
            ast = Psych.parse_stream(yaml, filename: "srt.yaml")

            unless ast.children.length == 1
              raise ValidationError, "exactly one YAML document is required"
            end

            reject_duplicate_keys!(ast)

            actual = YAML.safe_load(
              yaml,
              permitted_classes: [],
              permitted_symbols: [],
              aliases: false,
              filename: "srt.yaml"
            )

            unless actual == expected
              raise ValidationError,
                    "schema or values do not exactly match the required SRT contract"
            end

            puts "PASS"
          rescue ValidationError, Psych::Exception, Errno::ENOENT => e
            warn "FAIL: #{e.message}"
            exit 1
          end
          RUBY
```

The validator is intended to reject:

- missing keys
- extra keys
- incorrect values
- incorrect YAML types
- duplicate keys
- multiple YAML documents
- YAML aliases
- unsafe YAML class/object loading

Expected outcome:

- valid contract -> `PASS`, exit 0
- invalid contract -> `FAIL: <reason>`, non-zero exit

---

## 4. Important correction discovered

The first workflow file was accidentally created at the repository root as:

```text
/validate-SRT.yml
```

rather than:

```text
/.github/workflows/validate-SRT.yml
```

A further inspection found that the root copy also contained literal Markdown code fences, which would have made it invalid as a GitHub Actions workflow.

An attempted automated fix through the connected GitHub integration failed with:

```text
403 Resource not accessible by integration
```

No write was made by that failed attempt.

The user then manually created the workflow in the correct path and deleted the mistaken root copy.

Later verification in the conversation showed:

- `.github/workflows/validate-SRT.yml` existed in the correct location.
- the mistaken root-level `validate-SRT.yml` no longer existed.

---

## 5. Current SRT file issue discovered

The actual `srt.yaml` observed in the repository was still stored as one line:

```text
SRT:1 LAW: PASS: CONTINUE ELSE: FAIL FAIL: REPORT: HUMAN STOP: TRUE
```

That is not the intended structured YAML contract.

The intended file remains:

```yaml
SRT: 1
LAW:
  PASS: CONTINUE
  ELSE: FAIL
FAIL:
  REPORT: HUMAN
  STOP: TRUE
```

The next immediate technical step identified was to correct `srt.yaml` to that exact structure and commit only that change so the validation workflow actually runs against it.

---

## 6. What the workflow does and does not do

### What it does

The GitHub Actions workflow wakes up when `srt.yaml` is changed through a push or a pull request matching the configured path filter.

It checks whether the file exactly matches the expected SRT contract.

### What it does not do

It does **not** run merely because a human or AI reads the repository.

It does **not** force an AI to read `srt.yaml`.

It does **not** automatically prevent an agent from using tools.

It does **not** create a runtime security gate by itself.

The conversation established the distinction as:

> We have guarded the rulebook. We still need to put the bouncer on the door.

---

## 7. Required runtime enforcement model

The proposed runtime direction was:

1. Load and validate SRT before an agent receives operational access.
2. Fail closed if SRT is missing, unreadable, malformed, stale, or invalid.
3. Put tool access behind that gate.
4. Require proof of the validated SRT version/hash with authorised actions or sessions.
5. Reject direct or bypass tool calls that do not carry that proof.
6. Attack-test the system against prompt injection and attempts to skip or falsify SRT processing.

The desired architecture is therefore not just "tell the model to read SRT". It is to make SRT a machine-enforced precondition for capability.

---

## 8. Next ten steps agreed in the conversation

1. **Fix `srt.yaml`** to the exact structured contract.
2. **Commit only that change** so `Validate SRT` is triggered.
3. **Check GitHub Actions** and require an actual green `PASS`; if it fails, stop and diagnose.
4. **Protect the SRT files** so `srt.yaml` and its validator cannot quietly bypass review/validation.
5. **Create the actual SRT gate** that loads SRT before an agent receives operational access.
6. **Fail closed** if SRT is missing, unreadable, invalid, wrong-version, or otherwise fails validation.
7. **Put tools behind the gate** so GitHub writes, databases, Notion, files, deployment, and other actions are not directly reachable.
8. **Prove the agent passed SRT** using a validated SRT version/hash or equivalent machine-verifiable evidence.
9. **Attack-test the gate** against attempts to ignore, skip, alter, stale-copy, malformed-file, direct-tool-call, prompt-injection, and false-claim bypasses.
10. **Roll out progressively** from one test agent to broader iQ agent infrastructure only after bypass tests fail safely.

---

## 9. Current position at end of this page

**Verified in this conversation:**

- The workflow had been moved/created at `.github/workflows/validate-SRT.yml`.
- The mistaken root workflow had been removed.
- The workflow content was readable from GitHub at the correct path.
- `srt.yaml` was still the malformed one-line version when last inspected.

**Not verified in this conversation:**

- A successful workflow run after correcting `srt.yaml`.
- A CodeRabbit approval of the final repository state.
- Branch protection or required-status-check enforcement.
- Any runtime SRT gate in front of agent/tool access.
- Any completed bypass/adversarial test suite.

Therefore the overall SRT enforcement work was **not complete** at the end of this page.

---

## 10. Working rule going forward

Do not confuse documentation, model instructions, CI validation, and runtime enforcement.

They are four different layers:

1. **Documentation** — states the rule.
2. **Model instruction** — asks the model to follow the rule.
3. **CI validation** — protects the rule file from malformed changes.
4. **Runtime enforcement** — blocks capabilities unless the rule has actually been passed.

For iQ, the target is layer 4.
