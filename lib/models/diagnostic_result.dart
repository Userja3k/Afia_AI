class DiagnosticResult {
  final String type;
  final String diagnostic;
  final String gravite;
  final bool urgence;
  final double? confiance;
  final List<String> recommandations;
  final DateTime date;
  final Map<String, dynamic>? extraData;

  DiagnosticResult({
    required this.type,
    required this.diagnostic,
    required this.gravite,
    required this.urgence,
    this.confiance,
    required this.recommandations,
    required this.date,
    this.extraData,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      type: json['type'] ?? '',
      diagnostic: json['diagnostic'] ?? '',
      gravite: json['gravite'] ?? '',
      urgence: json['urgence'] ?? false,
      confiance: json['confiance']?.toDouble(),
      recommandations: List<String>.from(json['recommandations'] ?? []),
      date: DateTime.parse(json['date']),
      extraData: json['extraData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'diagnostic': diagnostic,
      'gravite': gravite,
      'urgence': urgence,
      'confiance': confiance,
      'recommandations': recommandations,
      'date': date.toIso8601String(),
      'extraData': extraData,
    };
  }
}