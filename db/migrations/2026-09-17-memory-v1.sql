BEGIN;

CREATE TABLE iq_instances (
  iq_instance_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identity_provider text NOT NULL,
  owner_subject text NOT NULL,
  display_name text,
  status text NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','SUSPENDED','ARCHIVED')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (identity_provider, owner_subject)
);

CREATE TABLE memory_scopes (
  scope_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_type text NOT NULL CHECK (scope_type IN ('OWNER','AREA','VENTURE','PROJECT','TASK')),
  scope_key text NOT NULL,
  title text,
  external_system text,
  external_id text,
  parent_scope_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (iq_instance_id, scope_id),
  UNIQUE (iq_instance_id, scope_key),
  FOREIGN KEY (iq_instance_id, parent_scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT
);
CREATE UNIQUE INDEX memory_scopes_one_owner_idx ON memory_scopes(iq_instance_id) WHERE scope_type = 'OWNER';
CREATE INDEX memory_scopes_external_idx ON memory_scopes(iq_instance_id, external_system, external_id);

CREATE TABLE memory_sources (
  source_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  source_key text NOT NULL,
  source_kind text NOT NULL CHECK (source_kind IN ('TEXT','VOICE','FILE','EMAIL','CALENDAR','CHAT','NOTION','DRIVE','SYSTEM','OTHER')),
  source_locator text,
  source_hash text NOT NULL CHECK (source_hash ~ '^[0-9a-f]{64}$'),
  source_text text,
  asserted_at timestamptz,
  captured_at timestamptz NOT NULL DEFAULT now(),
  actor_ref text NOT NULL,
  retention_class text NOT NULL DEFAULT 'STANDARD' CHECK (retention_class IN ('TRANSIENT','STANDARD','LONG_TERM','LEGAL_HOLD')),
  sensitivity text NOT NULL DEFAULT 'NORMAL' CHECK (sensitivity IN ('NORMAL','SENSITIVE','RESTRICTED','SECRET')),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(metadata) = 'object'),
  UNIQUE (iq_instance_id, source_id),
  UNIQUE (iq_instance_id, source_key),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT
);
CREATE INDEX memory_sources_scope_time_idx ON memory_sources(iq_instance_id, scope_id, captured_at DESC);
CREATE INDEX memory_sources_hash_idx ON memory_sources(iq_instance_id, source_hash);

CREATE TABLE memory_episodes (
  episode_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  source_id uuid NOT NULL,
  episode_type text NOT NULL CHECK (episode_type IN ('CONVERSATION','OBSERVATION','ACTION','RECEIPT','EXPERIENCE','IMPORT')),
  summary text NOT NULL CHECK (length(summary) > 0),
  occurred_at timestamptz NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(metadata) = 'object'),
  UNIQUE (iq_instance_id, episode_id),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, source_id)
    REFERENCES memory_sources(iq_instance_id, source_id) ON DELETE RESTRICT
);
CREATE INDEX memory_episodes_scope_time_idx ON memory_episodes(iq_instance_id, scope_id, occurred_at DESC);

CREATE TABLE memory_operations (
  operation_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  source_id uuid,
  operation_type text NOT NULL CHECK (operation_type IN ('CAPTURE','PROMOTE','CORRECT','FORGET','RETRIEVE','RECONCILE')),
  explicit_intent text NOT NULL DEFAULT 'none' CHECK (explicit_intent IN ('remember','correct','forget','inspect','none')),
  idempotency_key text NOT NULL,
  requested_by text NOT NULL,
  policy_version text NOT NULL,
  outcome text NOT NULL CHECK (outcome IN ('not-captured','evidence-captured','no-memory-candidate','candidate-created','candidate-pending','duplicate-no-change','rejected-by-policy','not-stored-sensitive','conflict-pending','canonical-committed','write-failed','service-unavailable','service-incompatible','retrieved-current','retrieved-history','retrieved-conflict','no-supported-memory','erase-pending','removed-from-active-memory','erased-verified')),
  details jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(details) = 'object'),
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  UNIQUE (iq_instance_id, operation_id),
  UNIQUE (iq_instance_id, idempotency_key),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, source_id)
    REFERENCES memory_sources(iq_instance_id, source_id) ON DELETE RESTRICT
);

CREATE TABLE memory_candidates (
  candidate_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  source_id uuid NOT NULL,
  episode_id uuid,
  target_lane text NOT NULL CHECK (target_lane IN ('SEMANTIC','PROCEDURAL')),
  claim_class text NOT NULL CHECK (claim_class IN ('FACT','PREFERENCE','INTENTION','EXPERIENCE','RELATIONSHIP','OPEN_LOOP','INFERENCE','PROCEDURE')),
  fact_key text NOT NULL,
  proposed_value jsonb NOT NULL,
  relationship_to_existing text NOT NULL DEFAULT 'UNKNOWN' CHECK (relationship_to_existing IN ('ADD','DUPLICATE','CORRECT','CONFLICT','UNKNOWN')),
  authority_class text NOT NULL CHECK (authority_class IN ('EXPLICIT_USER','EXPLICIT_CORRECTION','AUTHORIZED_IMPORT','THIRD_PARTY','MODEL_INFERENCE','SYSTEM')),
  epistemic_state text NOT NULL DEFAULT 'INFERRED' CHECK (epistemic_state IN ('CONFIRMED','INFERRED','UNKNOWN','DISPUTED')),
  confidence numeric(4,3) NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  uncertainty text,
  sensitivity text NOT NULL DEFAULT 'NORMAL' CHECK (sensitivity IN ('NORMAL','SENSITIVE','RESTRICTED','SECRET')),
  asserted_at timestamptz,
  valid_from timestamptz,
  valid_to timestamptz,
  status text NOT NULL DEFAULT 'CANDIDATE' CHECK (status IN ('CANDIDATE','APPROVED','REJECTED','CONFLICT','DEFERRED')),
  extraction_model text,
  extraction_schema_version text,
  extraction_code_version text,
  created_at timestamptz NOT NULL DEFAULT now(),
  reviewed_at timestamptz,
  reviewed_by text,
  UNIQUE (iq_instance_id, candidate_id),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, source_id)
    REFERENCES memory_sources(iq_instance_id, source_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, episode_id)
    REFERENCES memory_episodes(iq_instance_id, episode_id) ON DELETE RESTRICT,
  CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to > valid_from)
);
CREATE INDEX memory_candidates_review_idx ON memory_candidates(iq_instance_id, status, target_lane, created_at DESC);
CREATE INDEX memory_candidates_fact_idx ON memory_candidates(iq_instance_id, scope_id, fact_key);

CREATE TABLE memory_slots (
  slot_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  memory_lane text NOT NULL CHECK (memory_lane IN ('SEMANTIC','PROCEDURAL')),
  fact_key text NOT NULL,
  canonical_owner_type text,
  canonical_owner_ref text,
  volatility text NOT NULL DEFAULT 'MUTABLE' CHECK (volatility IN ('STABLE','MUTABLE','EXPIRING')),
  retention_policy text NOT NULL DEFAULT 'STANDARD',
  current_version_id uuid,
  revision bigint NOT NULL DEFAULT 0 CHECK (revision >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (iq_instance_id, slot_id),
  UNIQUE (iq_instance_id, scope_id, memory_lane, fact_key),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT
);

CREATE TABLE memory_versions (
  version_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  slot_id uuid NOT NULL,
  candidate_id uuid,
  previous_version_id uuid,
  value jsonb NOT NULL,
  value_hash text NOT NULL CHECK (value_hash ~ '^[0-9a-f]{64}$'),
  authority_class text NOT NULL CHECK (authority_class IN ('EXPLICIT_USER','EXPLICIT_CORRECTION','AUTHORIZED_IMPORT','THIRD_PARTY','MODEL_INFERENCE','SYSTEM')),
  epistemic_state text NOT NULL CHECK (epistemic_state IN ('CONFIRMED','INFERRED','UNKNOWN','DISPUTED')),
  confidence numeric(4,3) NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
  valid_from timestamptz,
  valid_to timestamptz,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  lifecycle_state text NOT NULL DEFAULT 'ACCEPTED' CHECK (lifecycle_state IN ('ACCEPTED','SUPERSEDED','CONTESTED','TOMBSTONED')),
  created_by text NOT NULL,
  UNIQUE (iq_instance_id, version_id),
  UNIQUE (iq_instance_id, slot_id, version_id),
  FOREIGN KEY (iq_instance_id, slot_id)
    REFERENCES memory_slots(iq_instance_id, slot_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, candidate_id)
    REFERENCES memory_candidates(iq_instance_id, candidate_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, previous_version_id)
    REFERENCES memory_versions(iq_instance_id, version_id) ON DELETE RESTRICT,
  CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to > valid_from)
);
CREATE UNIQUE INDEX memory_versions_one_accepted_idx ON memory_versions(iq_instance_id, slot_id) WHERE lifecycle_state = 'ACCEPTED';
CREATE INDEX memory_versions_history_idx ON memory_versions(iq_instance_id, slot_id, recorded_at DESC);

ALTER TABLE memory_slots ADD CONSTRAINT memory_slots_current_version_fk
  FOREIGN KEY (iq_instance_id, slot_id, current_version_id)
  REFERENCES memory_versions(iq_instance_id, slot_id, version_id) ON DELETE RESTRICT;

CREATE TABLE memory_version_evidence (
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  version_id uuid NOT NULL,
  source_id uuid NOT NULL,
  evidence_role text NOT NULL DEFAULT 'SUPPORTS' CHECK (evidence_role IN ('SUPPORTS','CHALLENGES','CORRECTS')),
  source_location text,
  content_hash text NOT NULL CHECK (content_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (iq_instance_id, version_id, source_id, evidence_role),
  FOREIGN KEY (iq_instance_id, version_id)
    REFERENCES memory_versions(iq_instance_id, version_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, source_id)
    REFERENCES memory_sources(iq_instance_id, source_id) ON DELETE RESTRICT
);

CREATE TABLE memory_events (
  event_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  slot_id uuid,
  version_id uuid,
  candidate_id uuid,
  operation_id uuid,
  event_type text NOT NULL CHECK (event_type IN ('CAPTURED','PROPOSED','ACCEPTED','SUPERSEDED','CONTESTED','TOMBSTONED','ERASED','RETRIEVED','RECONCILED')),
  actor_ref text NOT NULL,
  event_payload jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(event_payload) = 'object'),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (iq_instance_id, event_id),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, slot_id)
    REFERENCES memory_slots(iq_instance_id, slot_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, version_id)
    REFERENCES memory_versions(iq_instance_id, version_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, candidate_id)
    REFERENCES memory_candidates(iq_instance_id, candidate_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, operation_id)
    REFERENCES memory_operations(iq_instance_id, operation_id) ON DELETE RESTRICT
);
CREATE INDEX memory_events_scope_time_idx ON memory_events(iq_instance_id, scope_id, created_at DESC);

CREATE TABLE memory_conflicts (
  conflict_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  slot_id uuid NOT NULL,
  current_version_id uuid,
  candidate_id uuid NOT NULL,
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','RESOLVED','DISMISSED')),
  resolution text,
  created_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  resolved_by text,
  UNIQUE (iq_instance_id, conflict_id),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, slot_id)
    REFERENCES memory_slots(iq_instance_id, slot_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, current_version_id)
    REFERENCES memory_versions(iq_instance_id, version_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, candidate_id)
    REFERENCES memory_candidates(iq_instance_id, candidate_id) ON DELETE RESTRICT
);
CREATE INDEX memory_conflicts_open_idx ON memory_conflicts(iq_instance_id, status, created_at DESC);

CREATE TABLE working_memory_snapshots (
  working_memory_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  lifecycle_state text NOT NULL DEFAULT 'CURRENT' CHECK (lifecycle_state IN ('CURRENT','SUPERSEDED','ARCHIVED')),
  objective text,
  state_summary text NOT NULL,
  active_threads jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(active_threads) = 'array'),
  blockers jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(blockers) = 'array'),
  decisions_needed jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(decisions_needed) = 'array'),
  next_actions jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(next_actions) = 'array'),
  source_refs jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(source_refs) = 'array'),
  revision bigint NOT NULL DEFAULT 1 CHECK (revision > 0),
  generated_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz,
  supersedes_working_memory_id uuid,
  UNIQUE (iq_instance_id, working_memory_id),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, supersedes_working_memory_id)
    REFERENCES working_memory_snapshots(iq_instance_id, working_memory_id) ON DELETE RESTRICT
);
CREATE UNIQUE INDEX working_memory_one_current_idx ON working_memory_snapshots(iq_instance_id, scope_id) WHERE lifecycle_state = 'CURRENT';
CREATE INDEX working_memory_scope_time_idx ON working_memory_snapshots(iq_instance_id, scope_id, generated_at DESC);

CREATE TABLE current_positions (
  position_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  lifecycle_state text NOT NULL DEFAULT 'CURRENT' CHECK (lifecycle_state IN ('CURRENT','SUPERSEDED','ARCHIVED')),
  objective text,
  state_summary text NOT NULL,
  material_changes jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(material_changes) = 'array'),
  active_threads jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(active_threads) = 'array'),
  blockers jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(blockers) = 'array'),
  decisions_needed jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(decisions_needed) = 'array'),
  primary_next_action text,
  next_action_queue jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(next_action_queue) = 'array'),
  canonical_pointers jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(canonical_pointers) = 'array'),
  evidence_refs jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(evidence_refs) = 'array'),
  verification_state text NOT NULL DEFAULT 'UNVERIFIED' CHECK (verification_state IN ('UNVERIFIED','VERIFIED','DEGRADED','CONFLICT')),
  source_revision_vector jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(source_revision_vector) = 'object'),
  generated_at timestamptz NOT NULL DEFAULT now(),
  verified_at timestamptz,
  supersedes_position_id uuid,
  UNIQUE (iq_instance_id, position_id),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, supersedes_position_id)
    REFERENCES current_positions(iq_instance_id, position_id) ON DELETE RESTRICT,
  CHECK ((verification_state = 'VERIFIED') = (verified_at IS NOT NULL))
);
CREATE UNIQUE INDEX current_positions_one_current_idx ON current_positions(iq_instance_id, scope_id) WHERE lifecycle_state = 'CURRENT';
CREATE INDEX current_positions_scope_time_idx ON current_positions(iq_instance_id, scope_id, generated_at DESC);

CREATE TABLE memory_receipts (
  receipt_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  operation_id uuid NOT NULL,
  outcome text NOT NULL CHECK (outcome IN ('not-captured','evidence-captured','no-memory-candidate','candidate-created','candidate-pending','duplicate-no-change','rejected-by-policy','not-stored-sensitive','conflict-pending','canonical-committed','write-failed','service-unavailable','service-incompatible','retrieved-current','retrieved-history','retrieved-conflict','no-supported-memory','erase-pending','removed-from-active-memory','erased-verified')),
  source_id uuid,
  slot_id uuid,
  version_id uuid,
  assertion_hash text CHECK (assertion_hash IS NULL OR assertion_hash ~ '^[0-9a-f]{64}$'),
  worker_version text NOT NULL,
  git_commit text,
  schema_version text NOT NULL,
  policy_version text NOT NULL,
  database_fingerprint text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (iq_instance_id, receipt_id),
  UNIQUE (iq_instance_id, operation_id),
  FOREIGN KEY (iq_instance_id, operation_id)
    REFERENCES memory_operations(iq_instance_id, operation_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, source_id)
    REFERENCES memory_sources(iq_instance_id, source_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, slot_id)
    REFERENCES memory_slots(iq_instance_id, slot_id) ON DELETE RESTRICT,
  FOREIGN KEY (iq_instance_id, version_id)
    REFERENCES memory_versions(iq_instance_id, version_id) ON DELETE RESTRICT
);

CREATE TABLE memory_retrieval_log (
  retrieval_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  query_hash text NOT NULL CHECK (query_hash ~ '^[0-9a-f]{64}$'),
  query_text text,
  retrieval_mode text NOT NULL CHECK (retrieval_mode IN ('EXACT','LEXICAL','VECTOR','HYBRID')),
  outcome text NOT NULL CHECK (outcome IN ('retrieved-current','retrieved-history','retrieved-conflict','no-supported-memory')),
  result_version_ids uuid[] NOT NULL DEFAULT ARRAY[]::uuid[],
  result_episode_ids uuid[] NOT NULL DEFAULT ARRAY[]::uuid[],
  source_refs jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(source_refs) = 'array'),
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT
);
CREATE INDEX memory_retrieval_scope_time_idx ON memory_retrieval_log(iq_instance_id, scope_id, created_at DESC);

CREATE TABLE erasure_jobs (
  erasure_job_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  iq_instance_id uuid NOT NULL REFERENCES iq_instances(iq_instance_id) ON DELETE RESTRICT,
  scope_id uuid NOT NULL,
  requested_by text NOT NULL,
  target_type text NOT NULL CHECK (target_type IN ('SOURCE','SLOT','VERSION','SCOPE','INSTANCE')),
  target_ref text NOT NULL,
  status text NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','IN_PROGRESS','PARTIAL','VERIFIED','FAILED')),
  targets jsonb NOT NULL DEFAULT '[]'::jsonb CHECK (jsonb_typeof(targets) = 'array'),
  verification jsonb NOT NULL DEFAULT '{}'::jsonb CHECK (jsonb_typeof(verification) = 'object'),
  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  FOREIGN KEY (iq_instance_id, scope_id)
    REFERENCES memory_scopes(iq_instance_id, scope_id) ON DELETE RESTRICT
);

CREATE OR REPLACE FUNCTION memory_append_only_guard() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% is append-only', TG_TABLE_NAME;
END;
$$;

CREATE TRIGGER memory_events_append_only
BEFORE UPDATE OR DELETE ON memory_events
FOR EACH ROW EXECUTE FUNCTION memory_append_only_guard();

CREATE TRIGGER memory_receipts_append_only
BEFORE UPDATE OR DELETE ON memory_receipts
FOR EACH ROW EXECUTE FUNCTION memory_append_only_guard();

COMMIT;
