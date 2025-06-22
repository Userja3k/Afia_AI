import 'package:flutter/material.dart';
import '../../widgets/question_block.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/i18n/app_localizations.dart';

class SymptomesGravesPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;

  const SymptomesGravesPage({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<SymptomesGravesPage> createState() => _SymptomesGravesPageState();
}

class _SymptomesGravesPageState extends State<SymptomesGravesPage> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Column(
      children: [
        QuestionBlock(
          title: i18n.translate('malaria.symptoms.severe.title'),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.hallucinations')),
                value: widget.formData['hallucinations'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['hallucinations'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.vomiting')),
                value: widget.formData['vomissements'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['vomissements'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.confusion')),
                value: widget.formData['confusion'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['confusion'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.difficulty_breathing')),
                value: widget.formData['difficulte_respiration'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['difficulte_respiration'] = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          onPressed: widget.onNext,
          child: Text(i18n.translate('common.next')),
        ),
      ],
    );
  }
}