import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/i18n/app_localizations.dart';
import '../../utils/size_manager.dart';
import 'package:provider/provider.dart';

class TraitementSkinPage extends StatelessWidget {
  final Map<String, dynamic> diagnostic;

  const TraitementSkinPage({
    super.key,
    required this.diagnostic,
  });

  Color _getSeverityColor() {
    final severity = diagnostic['gravite'] ?? 'modérée';
    switch (severity) {
      case 'élevée':
        return Colors.red;
      case 'modérée':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getDiseaseIcon() {
    final disease = diagnostic['maladie'] ?? '';
    switch (disease.toLowerCase()) {
      case 'melanome':
        return Icons.warning;
      case 'eczema':
        return Icons.healing;
      case 'psoriasis':
        return Icons.local_hospital;
      case 'acne':
        return Icons.face;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final confidence = diagnostic['confiance'] ?? 0.0;
    final sizeManager = Provider.of<SizeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('skin.result.title')),
        backgroundColor: _getSeverityColor(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _getSeverityColor().withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getDiseaseIcon(),
                          color: _getSeverityColor(),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            diagnostic['maladie'] ?? '',
                            style: TextStyle(
                              fontSize: 20 * sizeManager.textScale,
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${i18n.translate('skin.result.confidence')}: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 16 * sizeManager.textScale),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${i18n.translate('skin.result.severity')}: ${diagnostic['gravite']}',
                      style: TextStyle(fontSize: 16 * sizeManager.textScale),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.translate('skin.result.recommendations'),
                      style: TextStyle(
                        fontSize: 18 * sizeManager.textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...((diagnostic['recommandations'] as List<String>?) ?? [])
                        .map((rec) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(rec)),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ),
            if (diagnostic['maladie'] == 'melanome') ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        i18n.translate('skin.result.urgent_warning'),
                        style: TextStyle(
                          fontSize: 16 * sizeManager.textScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.translate('skin.result.disclaimer.title'),
                      style: TextStyle(
                        fontSize: 16 * sizeManager.textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      i18n.translate('skin.result.disclaimer.text'),
                      style: TextStyle(
                        fontSize: 14 * sizeManager.textScale,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: Text(i18n.translate('common.back_home')),
            ),
          ],
        ),
      ),
    );
  }
}
