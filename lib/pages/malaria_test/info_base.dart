import 'package:flutter/material.dart';
import '../../widgets/question_block.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/i18n/app_localizations.dart';

class InfoBasePage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;

  const InfoBasePage({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<InfoBasePage> createState() => _InfoBasePageState();
}

class _InfoBasePageState extends State<InfoBasePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          QuestionBlock(
            title: i18n.translate('malaria.info.title'),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: i18n.translate('malaria.info.name'),
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (value) => widget.formData['nom'] = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: i18n.translate('malaria.info.age'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return i18n.translate('malaria.info.age_required');
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 120) {
                      return i18n.translate('malaria.info.age_invalid');
                    }
                    return null;
                  },
                  onSaved: (value) => widget.formData['age'] = int.parse(value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: i18n.translate('malaria.info.gender'),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'M',
                      child: Text(i18n.translate('malaria.info.male')),
                    ),
                    DropdownMenuItem(
                      value: 'F',
                      child: Text(i18n.translate('malaria.info.female')),
                    ),
                  ],
                  onChanged: (value) => widget.formData['sexe'] = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return i18n.translate('malaria.info.gender_required');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onNext();
              }
            },
            child: Text(i18n.translate('common.next')),
          ),
        ],
      ),
    );
  }
}