import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import '../utils/i18n/app_localizations.dart';
import 'skin_test/traitement.dart';

class SkinDetectionPage extends StatefulWidget {
  const SkinDetectionPage({super.key});

  @override
  State<SkinDetectionPage> createState() => _SkinDetectionPageState();
}

class _SkinDetectionPageState extends State<SkinDetectionPage> {
  XFile? _image;
  Uint8List? _webImage;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> formData = {
    'duree': '',
    'demangeaisons': false,
    'douleur': false,
  };

  Future<void> _takePicture() async {
    if (kIsWeb) {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _webImage = bytes;
          _image = null;
        });
      }
    } else if (Platform.isWindows) {
      // On Windows, image_picker requires a cameraDelegate which is not set up
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La prise de photo n\'est pas supportée sur Windows.'),
        ),
      );
    } else {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (photo != null) {
        setState(() {
          _image = photo;
          _webImage = null;
        });
      }
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
              colors: [Color(0xFFFF7A00), Color.fromARGB(255, 110, 95, 74)],
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (kIsWeb && _webImage != null)
                        Image.memory(
                          _webImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      else if (!kIsWeb && _image != null)
                        Image.file(
                          File(_image!.path),
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 16),
                      GradientButton(
                        onPressed: _takePicture,
                        child: Text(i18n.translate('skin.take_photo')),
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
                        i18n.translate('skin.info.title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: i18n.translate('skin.info.duration'),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'recent',
                            child: Text(
                                i18n.translate('skin.info.duration_recent')),
                          ),
                          DropdownMenuItem(
                            value: 'semaine',
                            child:
                                Text(i18n.translate('skin.info.duration_week')),
                          ),
                          DropdownMenuItem(
                            value: 'mois',
                            child: Text(
                                i18n.translate('skin.info.duration_month')),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            formData['duree'] = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return i18n
                                .translate('skin.info.duration_required');
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
                      const SizedBox(height: 16),
                      GradientButton(
                        onPressed: _submitAnalysis,
                        child: Text(i18n.translate('common.analyze')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAnalysis() async {
    if (_formKey.currentState!.validate() &&
        (kIsWeb ? _webImage != null : _image != null)) {
      try {
        final apiService = ApiService();
        Map<String, dynamic> result;
        if (kIsWeb) {
          result = await apiService.diagnoseSkinWeb(
            _webImage!,
            'image.png',
            formData,
          );
        } else {
          result = await apiService.diagnoseSkin(
            File(_image!.path),
            formData,
          );
        }
        if (!mounted) return;
        // Cast 'recommandations' to List<String> explicitly to avoid type error
        if (result['recommandations'] != null) {
          result['recommandations'] =
              List<String>.from(result['recommandations']);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TraitementSkinPage(diagnostic: result),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du diagnostic: $e')),
        );
      }
    }
  }
}
