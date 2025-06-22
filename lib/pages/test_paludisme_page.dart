import 'package:flutter/material.dart';
import '../widgets/gradient_button.dart';
import '../widgets/question_block.dart';
import '../widgets/step_indicator.dart';
import 'malaria_test/extra_data.dart';
import 'malaria_test/traitement.dart';
import '../services/api_service.dart';
import '../utils/i18n/app_localizations.dart';

class TestPaludismePage extends StatefulWidget {
  const TestPaludismePage({super.key});

  @override
  State<TestPaludismePage> createState() => _TestPaludismePageState();
}

class _TestPaludismePageState extends State<TestPaludismePage> {
  int currentStep = 0;
  final formKey = GlobalKey<FormState>();

  // Form data
  final Map<String, dynamic> formData = {
    'nom': '',
    'age': 0,
    'sexe': '',
    'fievre': false,
    'temperature': 37.0,
    'maux_tete': false,
    'fatigue': false,
    'hallucinations': false,
    'vomissements': false,
  };

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('malaria.title')),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7A00), Color.fromARGB(255, 110, 95, 74)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          StepIndicator(currentStep: currentStep, totalSteps: 3),
          Expanded(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCurrentStep(i18n),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GradientButton(
              onPressed: _nextStep,
              child: Text(currentStep < 2
                  ? i18n.translate('common.next')
                  : i18n.translate('common.analyze')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations i18n) {
    switch (currentStep) {
      case 0:
        return _buildInfoBase(i18n);
      case 1:
        return _buildSymptomesCourants(i18n);
      case 2:
        return _buildSymptomesGraves(i18n);
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoBase(AppLocalizations i18n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionBlock(
          title: i18n.translate('malaria.info.title'),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: i18n.translate('malaria.info.name')),
                onSaved: (value) => formData['nom'] = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                    labelText: i18n.translate('malaria.info.age')),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return i18n.translate('malaria.info.age_required');
                  }
                  return null;
                },
                onSaved: (value) => formData['age'] = int.parse(value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: i18n.translate('malaria.info.gender')),
                items: [
                  DropdownMenuItem(
                      value: 'M',
                      child: Text(i18n.translate('malaria.info.male'))),
                  DropdownMenuItem(
                      value: 'F',
                      child: Text(i18n.translate('malaria.info.female'))),
                ],
                onChanged: (value) => setState(() => formData['sexe'] = value),
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
      ],
    );
  }

  Widget _buildSymptomesCourants(AppLocalizations i18n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionBlock(
          title: i18n.translate('malaria.symptoms.common.title'),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.fever')),
                value: formData['fievre'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    formData['fievre'] = value;
                  });
                },
              ),
              if (formData['fievre'] == true)
                Slider(
                  value: formData['temperature'] ?? 37.0,
                  min: 35.0,
                  max: 42.0,
                  divisions: 70,
                  label: '${formData['temperature']}°C',
                  onChanged: (value) {
                    setState(() {
                      formData['temperature'] = value;
                    });
                  },
                ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.headache')),
                value: formData['maux_tete'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    formData['maux_tete'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.fatigue')),
                value: formData['fatigue'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    formData['fatigue'] = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomesGraves(AppLocalizations i18n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionBlock(
          title: i18n.translate('malaria.symptoms.severe.title'),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.hallucinations')),
                value: formData['hallucinations'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    formData['hallucinations'] = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text(i18n.translate('malaria.symptoms.vomiting')),
                value: formData['vomissements'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    formData['vomissements'] = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (currentStep < 2) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        setState(() {
          currentStep++;
        });
      }
    } else {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        _goToExtraDataPage();
      }
    }
  }

  void _goToExtraDataPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraDataPage(
          formData: formData,
          onNext: _submitDiagnosisWithExtraData,
        ),
      ),
    );
  }

  void _submitDiagnosisWithExtraData() async {
    // Here you would call your API service to submit the formData including extra data
    try {
      final apiService = ApiService();
      final result = await apiService.diagnoseMalaria(formData);
      if (!mounted) return;

      // Cast 'recommandations' to List<String> explicitly to avoid type error
      if (result['recommandations'] != null) {
        result['recommandations'] =
            List<String>.from(result['recommandations']);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TraitementMalariaPage(diagnostic: result),
        ),
      );
    } catch (e) {
      // Handle error, show message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du diagnostic: $e')),
      );
    }
  }
}
