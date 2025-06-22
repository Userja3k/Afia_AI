import 'package:flutter/material.dart';
import '../../widgets/question_block.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/i18n/app_localizations.dart';

class SymptomesCourantsPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;

  const SymptomesCourantsPage({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<SymptomesCourantsPage> createState() => _SymptomesCourantsPageState();
}

class _SymptomesCourantsPageState extends State<SymptomesCourantsPage> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Column(
      children: [
        QuestionBlock(
          title: i18n.translate('malaria.symptoms.common.title'),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.fever')),
                value: widget.formData['fievre'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['fievre'] = value;
                  });
                },
              ),
              if (widget.formData['fievre'] == true) ...[
                const SizedBox(height: 16),
                Text(i18n.translate('malaria.symptoms.temperature')),
                Slider(
                  value: widget.formData['temperature'] ?? 37.0,
                  min: 35.0,
                  max: 42.0,
                  divisions: 70,
                  label: '${(widget.formData['temperature'] ?? 37.0).toStringAsFixed(1)}°C',
                  onChanged: (value) {
                    setState(() {
                      widget.formData['temperature'] = value;
                    });
                  },
                ),
              ],
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.headache')),
                value: widget.formData['maux_tete'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['maux_tete'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.fatigue')),
                value: widget.formData['fatigue'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    widget.formData['fatigue'] = value;
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