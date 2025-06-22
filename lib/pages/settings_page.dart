import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/language_manager.dart';
import '../utils/theme_manager.dart';
import '../utils/size_manager.dart';
import '../utils/i18n/app_localizations.dart';
import '../widgets/bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _sendEmail(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('settings.report')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)
                    .translate('settings.report_hint'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(AppLocalizations.of(context).translate('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@afiaai.com',
                queryParameters: {
                  'subject': 'Signalement de problème - AfiaAI',
                },
              );

              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9E3D),
            ),
            child: Text(AppLocalizations.of(context).translate('common.send')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('settings.title')),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(i18n.translate('settings.language')),
            trailing: Consumer<LanguageManager>(
              builder: (context, languageManager, child) {
                return DropdownButton<Locale>(
                  value: languageManager.currentLocale,
                  items: const [
                    DropdownMenuItem(
                      value: Locale('fr'),
                      child: Text('Français'),
                    ),
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('es'),
                      child: Text('Español'),
                    ),
                    DropdownMenuItem(
                      value: Locale('pt'),
                      child: Text('Português'),
                    ),
                  ],
                  onChanged: (locale) {
                    if (locale != null) {
                      languageManager.changeLocale(locale);
                    }
                  },
                );
              },
            ),
          ),
          Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              return SwitchListTile(
                title: Text(i18n.translate('settings.theme')),
                value: themeManager.isDarkMode,
                onChanged: (bool value) {
                  themeManager.toggleTheme();
                },
              );
            },
          ),
          Consumer<SizeManager>(
            builder: (context, sizeManager, child) {
              return ListTile(
                title: Text(i18n.translate('settings.textSize')),
                subtitle: Slider(
                  value: sizeManager.textScale,
                  min: 0.8,
                  max: 1.2,
                  divisions: 4,
                  label: 'x${sizeManager.textScale.toStringAsFixed(1)}',
                  onChanged: (value) {
                    sizeManager.setTextScale(value);
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text(i18n.translate('settings.rate')),
            subtitle: Center(
              child: RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Color(0xFFFF9E3D),
                ),
                onRatingUpdate: (rating) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(i18n
                          .translate('settings.rating_thanks')
                          .replaceAll('{rating}', rating.toString())),
                      backgroundColor: const Color(0xFFFF9E3D),
                    ),
                  );
                },
              ),
            ),
          ),
          ListTile(
            title: Text(i18n.translate('settings.report')),
            trailing: IconButton(
              icon: const Icon(Icons.email),
              onPressed: () => _sendEmail(context),
            ),
          ),
          ListTile(
            title: Text(i18n.translate('settings.about')),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'AfiaAI',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7A00), Color(0xFFFFB347)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.health_and_safety, color: Colors.white),
                ),
                children: [
                  Text(i18n.translate('settings.about_description')),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
