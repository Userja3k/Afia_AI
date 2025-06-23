import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/gradient_button.dart';
import '../../widgets/question_block.dart';
import '../../utils/i18n/app_localizations.dart';

class SkinInputPage extends StatefulWidget {
  final VoidCallback onAnalyze;

  const SkinInputPage({
    super.key,
    required this.onAnalyze,
  });

  @override
  State<SkinInputPage> createState() => _SkinInputPageState();
}

class _SkinInputPageState extends State<SkinInputPage> {
  File? _image;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> formData = {
    'duree': '',
    'demangeaisons': false,
    'douleur': false,
    'changement_recent': false,
  };
/*
  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }
¨*/
  Future<void> _pickFromGallery() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('skin.title')),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuestionBlock(
                title: i18n.translate('skin.photo.title'),
                child: Column(
                  children: [
                    if (_image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Aucune image sélectionnée',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Gallery"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              QuestionBlock(
                title: i18n.translate('skin.info.title'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: i18n.translate('skin.info.duration'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'recent',
                          child:
                              Text(i18n.translate('skin.info.duration_recent')),
                        ),
                        DropdownMenuItem(
                          value: 'semaine',
                          child:
                              Text(i18n.translate('skin.info.duration_week')),
                        ),
                        DropdownMenuItem(
                          value: 'mois',
                          child:
                              Text(i18n.translate('skin.info.duration_month')),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          formData['duree'] = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return i18n.translate('skin.info.duration_required');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(i18n.translate('skin.info.itching')),
                      value: formData['demangeaisons'] ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          formData['demangeaisons'] = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text(i18n.translate('skin.info.pain')),
                      value: formData['douleur'] ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          formData['douleur'] = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text(i18n.translate('skin.info.recent_change')),
                      value: formData['changement_recent'] ?? false,
                      onChanged: (bool value) {
                        setState(() {
                          formData['changement_recent'] = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _image != null) {
                    widget.onAnalyze();
                  } else if (_image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(i18n.translate('skin.photo.required')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(i18n.translate('common.analyze')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
