import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssistantFloatingBot extends StatelessWidget {
  const AssistantFloatingBot({super.key});

  Future<void> _showBotDialog(BuildContext context) async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
    );

    final currentRoute = ModalRoute.of(context)?.settings.name ?? 'home';
    final prompt = '''
    Tu es l'assistant AfiaAI, un guide médical IA. Explique la page $currentRoute 
    et ses fonctionnalités de manière simple et rassurante. Inclus:
    - Le but de cette page
    - Les actions possibles
    - Les précautions à prendre
    Reste professionnel mais chaleureux.
    ''';

    final content = [Content.text(prompt)];
    
    try {
      final response = await model.generateContent(content);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Assistant AfiaAI'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(response.text ?? 'Je ne peux pas vous aider pour le moment.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion à l\'assistant')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBotDialog(context),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}