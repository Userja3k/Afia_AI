import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/random_loading_texts.dart';
import '../utils/i18n/app_localizations.dart';

class LoadingPage extends StatefulWidget {
  final String title;
  final Future<Map<String, dynamic>> analysisTask;
  final Function(Map<String, dynamic>) onComplete;

  const LoadingPage({
    super.key,
    required this.title,
    required this.analysisTask,
    required this.onComplete,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Timer _textTimer;
  String _currentText = '';
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _currentText = LoadingTexts.getRandomText();
    
    _textTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentText = LoadingTexts.getRandomText();
          _progress = (_progress + 1) % 4;
        });
      }
    });

    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    try {
      final result = await widget.analysisTask;
      if (mounted) {
        widget.onComplete(result);
      }
    } catch (e) {
      if (mounted) {
        widget.onComplete({
          'error': true,
          'message': 'Erreur lors de l\'analyse',
        });
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              
              // Animation principale
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.14159,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF7A00),
                            Color(0xFFFFB347),
                            Color(0xFF2196F3),
                            Color(0xFF0D47A1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF7A00).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Indicateur de progression
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey[800],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.3 + (_pulseController.value * 0.7),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Texte animé
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _currentText,
                  key: ValueKey(_currentText),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Points de progression
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= _progress 
                        ? const Color(0xFFFF7A00) 
                        : Colors.grey[600],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}