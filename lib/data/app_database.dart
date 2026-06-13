import 'package:drift/drift.dart';

part 'app_database.g.dart';

// DocuMink core data model — blueprint §3.1 (core schema) and §3.2 (Mink schema).
//
// Multi-tenant-ready from day one: every row carries `workspace_id`
// (V1 single-user → single workspace; V3+ Teams → multiple members).
// Timestamps are stored as plain INTEGER columns (epoch millis); the
// repository layer owns the epoch unit. Booleans are modelled as INTEGER
// (DEFAULT 0) to mirror the authoritative SQL exactly rather than emit
// drift's `CHECK (col IN (0,1))` boolean constraint.
//
// The `mink_embeddings` vec0 virtual table (blueprint §3.2) is intentionally
// NOT declared here: it requires the sqlite-vec native extension, which cannot
// be cleanly bundled under SQLCipher on Flutter today, and its only consumers
// (Semantic / Resource memory) activate in V1.2. See docs/adr/ADR-018 and the
// note in blueprint.md §3.2. `mink_semantic_memory.embedding_id` is therefore a
// plain nullable TEXT column with no foreign key (a vec0 virtual table cannot be
// a FK target).

// ---------------------------------------------------------------------------
// §3.1 Core schema
// ---------------------------------------------------------------------------

class Workspaces extends Table {
  TextColumn get id => text()(); // ULID
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get kekVersion => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id =>
      text()(); // ULID; also used as workspace_id for isolation
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get name => text()();
  TextColumn get templateId => text().nullable()();
  TextColumn get manifestJson => text()();
  IntColumn get manifestVersion => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get archived => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Documents extends Table {
  TextColumn get id => text()(); // ULID
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
  )(); // NULL = outside any project
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'text','image','pdf', (V4) 'form','signed'
  BlobColumn get sourceHash => blob()(); // SHA-256 of original input
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get redactedArtifactPath => text().nullable()();
  TextColumn get status => text()(); // 'draft','redacted','exported'
  TextColumn get metadataJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_entities_document', columns: {#documentId})
class Entities extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get documentId => text().references(Documents, #id)();
  TextColumn get entityType => text()(); // 'EMAIL','PERSON','MRN', or custom
  TextColumn get detector => text()(); // 'regex','mlkit','gliner','llm'
  IntColumn get spanStart => integer()();
  IntColumn get spanEnd => integer()();
  RealColumn get confidence => real()();
  TextColumn get operatorApplied => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'idx_tokens_fingerprint',
  columns: {#workspaceId, #plaintextFingerprint},
)
class Tokens extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get entityId => text().references(Entities, #id)();
  TextColumn get tokenValue => text()();
  BlobColumn get plaintextFingerprint => blob()(); // HMAC-SHA256 (separate key)
  BlobColumn get ciphertext => blob()(); // AES-GCM with token_value as AAD
  IntColumn get keyVersion => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class CustomEntityTypes extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable().references(
    Projects,
    #id,
  )(); // NULL = global to workspace
  TextColumn get label => text()();
  TextColumn get regexPattern => text().nullable()();
  TextColumn get validator => text().nullable()();
  TextColumn get examplesJson => text().nullable()();
  TextColumn get defaultOperator => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {workspaceId, projectId, label},
  ];
}

// audit_log.project_id / document_id / entity_id are deliberately plain TEXT
// with no FK, mirroring the §3.1 SQL (audit rows may reference deleted records
// and global events carry NULLs).
class AuditLog extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable()(); // NULL for global events
  TextColumn get eventType => text()();
  TextColumn get documentId => text().nullable()();
  TextColumn get entityId => text().nullable()();
  TextColumn get toolName => text().nullable()(); // for mink_tool_call events
  IntColumn get success => integer()();
  TextColumn get biometricResult => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class VaultMeta extends Table {
  TextColumn get key => text()();
  BlobColumn get value => blob()();

  @override
  Set<Column> get primaryKey => {key};
}

class SyncState extends Table {
  TextColumn get deviceId => text()();
  IntColumn get lastPushAt => integer().nullable()();
  IntColumn get lastPullAt => integer().nullable()();
  TextColumn get peerPublicKeysJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

// ---------------------------------------------------------------------------
// §3.2 Mink-specific schema
// ---------------------------------------------------------------------------

class ChatSessions extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId =>
      text().nullable().references(Projects, #id)(); // NULL = global chat
  TextColumn get title => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get tierAtCreation => text()();
  TextColumn get variantAtCreation => text()();
  TextColumn get modelIdAtCreation => text()();
  IntColumn get archived => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'idx_chat_messages_session',
  columns: {#sessionId, #createdAt},
)
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(ChatSessions, #id)();
  TextColumn get role =>
      text()(); // 'user','mink','tool_call','tool_result','system'
  TextColumn get content => text()(); // may contain token refs, not plaintext
  TextColumn get toolCallJson => text().nullable()();
  TextColumn get toolResultJson => text().nullable()();
  IntColumn get tokensInput => integer().nullable()();
  IntColumn get tokensOutput => integer().nullable()();
  IntColumn get inferenceMs => integer().nullable()();
  TextColumn get modelId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// Type 1: Core Memory — stable identity and preferences. Active V1.
class MinkCoreMemory extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId =>
      text().nullable().references(Projects, #id)(); // NULL = global
  TextColumn get key => text()(); // e.g. 'user_preferred_tone'
  TextColumn get valueJson => text()(); // may contain token refs; never raw PII
  TextColumn get provenance => text()();
  RealColumn get confidence => real().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {workspaceId, projectId, key},
  ];
}

// Type 2: Episodic Memory — time-stamped activity summaries. Active V1.
@TableIndex(
  name: 'idx_episodic_time',
  columns: {#workspaceId, #projectId, #occurredAt},
)
class MinkEpisodicMemory extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  IntColumn get occurredAt => integer()();
  TextColumn get summary => text()(); // may contain token refs
  TextColumn get detailsJson => text().nullable()();
  TextColumn get episodeType => text()();
  TextColumn get tokenRefsJson => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// Type 4: Semantic Memory — entities/relationships, PII-safe via token refs.
// Schema V1, activation V1.2.
@TableIndex(
  name: 'idx_semantic_fingerprint',
  columns: {#workspaceId, #canonicalFingerprint},
)
@TableIndex(name: 'idx_semantic_parent', columns: {#parentId})
class MinkSemanticMemory extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  TextColumn get entityType => text()(); // 'PERSON','ORGANIZATION', etc.
  BlobColumn get canonicalFingerprint =>
      blob().nullable()(); // HMAC-SHA256(plaintext); NULL for non-PII concepts
  TextColumn get descriptor => text().nullable()();
  TextColumn get parentId =>
      text().nullable().references(MinkSemanticMemory, #id)(); // tree parent
  IntColumn get occurrenceCount => integer().withDefault(const Constant(1))();
  IntColumn get firstSeenAt => integer()();
  IntColumn get lastSeenAt => integer()();
  // V1.2: references mink_embeddings(id) once the vec0 table is activated.
  // Plain TEXT (no FK) — a vec0 virtual table cannot be a FK target.
  TextColumn get embeddingId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_rel_from', columns: {#fromEntityId})
@TableIndex(name: 'idx_rel_to', columns: {#toEntityId})
class MinkSemanticRelationships extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  // Two FKs target the same table; name the reverse references so drift's
  // generated manager can disambiguate them.
  @ReferenceName('relationshipsFrom')
  TextColumn get fromEntityId => text().references(MinkSemanticMemory, #id)();
  @ReferenceName('relationshipsTo')
  TextColumn get toEntityId => text().references(MinkSemanticMemory, #id)();
  TextColumn get predicate => text()(); // 'works_at','mentioned_in', etc.
  RealColumn get confidence => real()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// Type 5: Procedural Memory — observed workflow patterns. Schema V1, activation V1.2.
class MinkProceduralMemory extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  TextColumn get triggerPatternJson => text()();
  TextColumn get actionPatternJson => text()();
  IntColumn get observedCount => integer().withDefault(const Constant(1))();
  RealColumn get confidence => real()();
  IntColumn get lastObservedAt => integer()();
  IntColumn get userConfirmed => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Workspaces,
    Projects,
    Documents,
    Entities,
    Tokens,
    CustomEntityTypes,
    AuditLog,
    VaultMeta,
    SyncState,
    ChatSessions,
    ChatMessages,
    MinkCoreMemory,
    MinkEpisodicMemory,
    MinkSemanticMemory,
    MinkSemanticRelationships,
    MinkProceduralMemory,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Production code injects the SQLCipher-backed executor (see
  /// `sqlcipher_executor.dart`); tests inject `NativeDatabase.memory()`.
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Enforce foreign keys on every connection (prod + tests). For the
      // SQLCipher executor this runs after `PRAGMA key`; see sqlcipher_executor.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
