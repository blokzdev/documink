import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The original source file behind the text currently in the editor, awaiting an
/// opt-in encrypted save (Phase 4c). Set when navigating from a capture/import
/// into the editor; consumed by the editor's `save()` (stored only if the
/// `keepOriginalProvider` opt-in is on) and cleared when the editor closes. Null
/// for plain pasted text (no source file).
class PendingOriginal {
  const PendingOriginal({required this.path, required this.mime});

  final String path;
  final String mime;
}

final pendingOriginalProvider = StateProvider<PendingOriginal?>((ref) => null);
