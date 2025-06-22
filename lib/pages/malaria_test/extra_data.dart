import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../widgets/question_block.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/i18n/app_localizations.dart';
import '../../services/audio_service.dart';
import '../../utils/size_manager.dart';
import 'package:provider/provider.dart';

class ExtraDataPage extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onNext;

  const ExtraDataPage({
    super.key,
    required this.formData,
    required this.onNext,
  });

  @override
  State<ExtraDataPage> createState() => _ExtraDataPageState();
}

class _ExtraDataPageState extends State<ExtraDataPage> {
  File? _image;
  final _picker = ImagePicker();
  final _audioService = AudioService();
  bool _isRecording = false;
  String? _audioPath;

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        widget.formData['image_path'] = photo.path;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        widget.formData['audio_path'] = path;
      });
    } else {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final sizeManager = Provider.of<SizeManager>(context);

    return Column(
      children: [
        QuestionBlock(
          title: i18n.translate('malaria.extra.photo.title'),
          child: Column(
            children: [
              if (_image != null)
                Image.file(
                  _image!,
                  height: 200,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: Text(i18n.translate('malaria.extra.photo.take')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        QuestionBlock(
          title: i18n.translate('malaria.extra.audio.title'),
          child: Column(
            children: [
              Text(
                i18n.translate('malaria.extra.audio.description'),
                style: TextStyle(
                    fontSize: 14 * sizeManager.textScale,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording
                    ? i18n.translate('malaria.extra.audio.stop')
                    : i18n.translate('malaria.extra.audio.start')),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isRecording ? Theme.of(context).colorScheme.error : null,
                ),
              ),
              if (_audioPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    i18n.translate('malaria.extra.audio.recorded'),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          onPressed: widget.onNext,
          child: Text(i18n.translate('common.analyze')),
        ),
      ],
    );
  }
}
