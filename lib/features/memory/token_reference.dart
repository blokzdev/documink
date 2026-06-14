// The three PII-safe reference forms allowed in Mink memory (memory.md §3.1).
// Raw PII/PHI plaintext must never enter memory tables — only these refs.

/// Form A — a structured token reference, e.g. in `value_json`/`details_json`:
/// `{"type":"token_ref","token_id":"tok_…","display_fallback_type":"PERSON"}`.
class TokenRef {
  const TokenRef({required this.tokenId, this.displayFallbackType});

  final String tokenId;
  final String? displayFallbackType;

  static const String typeMarker = 'token_ref';

  Map<String, dynamic> toJson() => {
    'type': typeMarker,
    'token_id': tokenId,
    if (displayFallbackType != null)
      'display_fallback_type': displayFallbackType,
  };

  factory TokenRef.fromJson(Map<dynamic, dynamic> json) => TokenRef(
    tokenId: json['token_id'] as String,
    displayFallbackType: json['display_fallback_type'] as String?,
  );
}

/// Whether [value] is a Form-A token-reference map (carries no plaintext, so
/// the scanner skips it entirely).
bool isTokenRefMap(Object? value) =>
    value is Map &&
    value['type'] == TokenRef.typeMarker &&
    value['token_id'] is String;

/// Form B — an inline token marker in free text, e.g.
/// `"14 mentions of <<tok_01HXJ…>>"`. Reserved syntax replaced by the renderer.
final RegExp inlineTokenMarker = RegExp(r'<<tok_[0-9A-Za-z]+>>');

/// Replaces Form-B markers with a space so the residual free text can be PII-
/// scanned without the (safe) markers tripping detection or gluing tokens.
String stripInlineTokenMarkers(String text) =>
    text.replaceAll(inlineTokenMarker, ' ');
