/// The anonymization operators (blueprint §4.6 policy, §7.1 reversible modes).
///
/// The first three are **irreversible** surface transforms (implemented in 3a);
/// the last three are **reversible** and vault-backed (Token-Random + Encrypt in
/// 3b, FF1 FPE in 3c).
enum Operator {
  redact('redact'),
  mask('mask'),
  replace('replace'),
  tokenRandom('token_random'),
  fpe('fpe'),
  encrypt('encrypt');

  const Operator(this.policyName);

  /// The snake_case name used in policy YAML.
  final String policyName;

  /// Whether this operator is reversible (produces a vault token/ciphertext).
  bool get isReversible =>
      this == tokenRandom || this == fpe || this == encrypt;

  /// Parses a policy YAML operator name. Throws [FormatException] if unknown.
  static Operator fromPolicyName(String name) {
    for (final op in Operator.values) {
      if (op.policyName == name) return op;
    }
    throw FormatException('Unknown anonymization operator: "$name"');
  }
}
