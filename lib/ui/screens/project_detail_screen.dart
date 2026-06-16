import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/datetime_format.dart';
import '../../core/routes.dart';
import '../../data/app_database.dart';
import '../../data/id_generator.dart';
import '../../features/anonymization/operator.dart';
import '../../features/detection/pii_span.dart';
import '../../features/projects/active_project_provider.dart';
import '../../features/projects/personal_template.dart';
import '../../features/projects/project_providers.dart';
import '../../features/projects/scaffolded_manifest.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/section_header.dart';
import 'upload_scaffold_screen.dart' show AiScaffoldedBadge;

/// The ordered permission keys shown as editable rows (blueprint §6.1/§6.4).
/// `decode` is tri-state (off / on / biometric); the rest are on/off.
const _permissionKeys = <String>[
  'read_documents',
  'detect_pii',
  'anonymize',
  'decode',
  'rewrite_content',
  'expand_content',
  'export',
  'modify_project_settings',
  'cross_project_search',
  'search_web',
];

/// Project detail (roadmap Phase 14): a Documents tab (the project's documents)
/// and an editable Settings tab (permissions, default policy, Mink persona).
/// Edits round-trip through the stored manifest JSON via
/// [ProjectRepository.updateManifest] (versioned + audited).
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return projectAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          title: l10n.projectDetailLoadError,
          onRetry: () => ref.invalidate(projectByIdProvider(projectId)),
        ),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.projectDetailNotFound)),
          );
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(project.name),
              actions: [
                if (project.templateId == aiScaffoldedTemplateId)
                  const Padding(
                    padding: EdgeInsets.only(right: AppTokens.spacingSm),
                    child: Center(child: AiScaffoldedBadge()),
                  ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.projectDetailDocumentsTab),
                  Tab(text: l10n.projectDetailSettingsTab),
                ],
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  _DocumentsTab(projectId: projectId),
                  _SettingsTab(project: project),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DocumentsTab extends ConsumerWidget {
  const _DocumentsTab({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final docsAsync = ref.watch(projectDocumentsProvider(projectId));
    return docsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => AppErrorState(
        title: l10n.projectDetailLoadError,
        onRetry: () => ref.invalidate(projectDocumentsProvider(projectId)),
      ),
      data: (docs) {
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.folder_open_outlined,
            title: l10n.projectDetailNoDocuments,
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              itemCount: docs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppTokens.spacingSm),
              itemBuilder: (context, i) {
                final doc = docs[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(doc.name),
                    subtitle: Text(
                      '${doc.type} · ${formatTimestamp(doc.createdAt)}',
                    ),
                    onTap: () => context.push(Routes.document(doc.id)),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab({required this.project});

  final Project project;

  Map<String, dynamic> get _manifest =>
      jsonDecode(project.manifestJson) as Map<String, dynamic>;

  /// Applies [mutate] to the decoded manifest and persists it (versioned +
  /// audited), then refreshes the detail.
  Future<void> _edit(
    WidgetRef ref,
    BuildContext context,
    void Function(Map<String, dynamic>) mutate,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final map = _manifest;
    mutate(map);
    await ref
        .read(projectRepositoryProvider)
        .updateManifest(project.id, jsonEncode(map));
    ref.invalidate(projectByIdProvider(project.id));
    messenger.showSnackBar(SnackBar(content: Text(l10n.projectSettingsSaved)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final manifest = _manifest;
    final permissions =
        (manifest['permissions'] as Map?)?.cast<String, dynamic>() ?? const {};
    final policy =
        (manifest['default_policy'] as Map?)?.cast<String, dynamic>() ??
        const {};
    final isActive = ref.watch(activeProjectProvider) == project.id;

    final policyLabels = <String>[
      ..._builtInLabels,
      for (final c in (manifest['custom_entity_types'] as List? ?? const []))
        (c as Map)['label'] as String,
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
        child: ListView(
          key: const Key('project-settings-list'),
          padding: const EdgeInsets.only(bottom: AppTokens.spacingLg),
          children: [
            SwitchListTile(
              key: const Key('active-project-toggle'),
              secondary: const Icon(Icons.adjust_outlined),
              title: Text(l10n.projectDetailActive),
              subtitle: Text(l10n.projectDetailActiveSubtitle),
              value: isActive,
              onChanged: (v) => ref
                  .read(activeProjectProvider.notifier)
                  .set(v ? project.id : null),
            ),

            SectionHeader(l10n.projectSectionPermissions),
            for (final key in _permissionKeys)
              if (key == 'decode')
                _DecodeRow(
                  value: permissions['decode'],
                  onChanged: (v) => _edit(ref, context, (m) {
                    (m['permissions'] ??= <String, dynamic>{})['decode'] = v;
                  }),
                )
              else
                SwitchListTile(
                  key: Key('perm-$key'),
                  title: Text(_permLabel(l10n, key)),
                  value: permissions[key] == true,
                  onChanged: (v) => _edit(ref, context, (m) {
                    (m['permissions'] ??= <String, dynamic>{})[key] = v;
                  }),
                ),

            SectionHeader(l10n.projectSectionPolicy),
            for (final label in policyLabels)
              ListTile(
                key: Key('policy-$label'),
                title: Text(label),
                trailing: DropdownButton<String?>(
                  value: policy[label] as String?,
                  hint: Text(l10n.projectPolicyInherit),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.projectPolicyInherit),
                    ),
                    for (final op in Operator.values)
                      DropdownMenuItem(
                        value: op.policyName,
                        child: Text(_opLabel(l10n, op)),
                      ),
                  ],
                  onChanged: (op) => _edit(ref, context, (m) {
                    final pol =
                        (m['default_policy'] ??= <String, dynamic>{})
                            as Map<String, dynamic>;
                    if (op == null) {
                      pol.remove(label);
                    } else {
                      pol[label] = op;
                    }
                  }),
                ),
              ),

            SectionHeader(l10n.projectSectionPersona),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacingMd,
              ),
              child: _PersonaEditor(
                initial: manifest['mink_persona'] as String? ?? '',
                onSave: (text) => _edit(ref, context, (m) {
                  if (text.isEmpty) {
                    m.remove('mink_persona');
                  } else {
                    m['mink_persona'] = text;
                  }
                }),
              ),
            ),

            SectionHeader(l10n.projectSectionTemplate),
            ListTile(
              key: const Key('save-as-personal-template'),
              leading: const Icon(Icons.bookmark_add_outlined),
              title: Text(l10n.projectSaveAsPersonalTemplate),
              subtitle: Text(l10n.projectSaveAsPersonalTemplateSubtitle),
              onTap: () => _saveAsPersonalTemplate(ref, context),
            ),
          ],
        ),
      ),
    );
  }

  /// Saves the current manifest as a reusable personal template ("Yours" in the
  /// picker — blueprint §6.5).
  Future<void> _saveAsPersonalTemplate(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await ref
        .read(personalTemplateRepositoryProvider)
        .save(
          PersonalTemplate(
            id: defaultIdGenerator(),
            name: project.name,
            manifestJson: project.manifestJson,
            createdAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            origin: project.templateId == aiScaffoldedTemplateId
                ? PersonalTemplateOrigin.aiScaffolded
                : PersonalTemplateOrigin.customized,
          ),
        );
    ref.invalidate(personalTemplatesProvider);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.projectPersonalTemplateSaved)),
    );
  }

  static const _builtInLabels = <String>[
    PiiLabels.person,
    PiiLabels.email,
    PiiLabels.phone,
    PiiLabels.ssn,
    PiiLabels.creditCard,
    PiiLabels.iban,
    PiiLabels.url,
    PiiLabels.ipAddress,
    PiiLabels.date,
    PiiLabels.dateOfBirth,
    PiiLabels.mrn,
    PiiLabels.passport,
    PiiLabels.location,
  ];

  String _permLabel(AppLocalizations l10n, String key) => switch (key) {
    'read_documents' => l10n.permReadDocuments,
    'detect_pii' => l10n.permDetectPii,
    'anonymize' => l10n.permAnonymize,
    'decode' => l10n.permDecode,
    'rewrite_content' => l10n.permRewriteContent,
    'expand_content' => l10n.permExpandContent,
    'export' => l10n.permExport,
    'modify_project_settings' => l10n.permModifyProjectSettings,
    'cross_project_search' => l10n.permCrossProjectSearch,
    'search_web' => l10n.permSearchWeb,
    _ => key,
  };

  String _opLabel(AppLocalizations l10n, Operator op) => switch (op) {
    Operator.redact => l10n.operatorRedact,
    Operator.mask => l10n.operatorMask,
    Operator.replace => l10n.operatorReplace,
    Operator.tokenRandom => l10n.operatorToken,
    Operator.fpe => l10n.operatorFpe,
    Operator.encrypt => l10n.operatorEncrypt,
  };
}

/// Tri-state `decode` permission row (off / on / biometric).
class _DecodeRow extends StatelessWidget {
  const _DecodeRow({required this.value, required this.onChanged});

  /// The raw manifest value: `true`, `'requires_biometric'`, or false/absent.
  final Object? value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Map raw → a stable dropdown token.
    final current = value == true
        ? 'on'
        : value == 'requires_biometric'
        ? 'biometric'
        : 'off';
    return ListTile(
      key: const Key('perm-decode'),
      title: Text(l10n.permDecode),
      trailing: DropdownButton<String>(
        value: current,
        items: [
          DropdownMenuItem(value: 'off', child: Text(l10n.projectDecodeOff)),
          DropdownMenuItem(value: 'on', child: Text(l10n.projectDecodeOn)),
          DropdownMenuItem(
            value: 'biometric',
            child: Text(l10n.projectDecodeBiometric),
          ),
        ],
        onChanged: (token) {
          switch (token) {
            case 'on':
              onChanged(true);
            case 'biometric':
              onChanged('requires_biometric');
            default:
              onChanged(false);
          }
        },
      ),
    );
  }
}

/// Persona id editor with an explicit save (mutating the manifest on every
/// keystroke would version-spam the audit log).
class _PersonaEditor extends StatefulWidget {
  const _PersonaEditor({required this.initial, required this.onSave});

  final String initial;
  final ValueChanged<String> onSave;

  @override
  State<_PersonaEditor> createState() => _PersonaEditorState();
}

class _PersonaEditorState extends State<_PersonaEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('persona-field'),
          controller: _controller,
          decoration: InputDecoration(hintText: l10n.projectPersonaHint),
        ),
        const SizedBox(height: AppTokens.spacingSm),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonal(
            key: const Key('persona-save'),
            onPressed: () => widget.onSave(_controller.text.trim()),
            child: Text(l10n.projectPersonaSave),
          ),
        ),
      ],
    );
  }
}
