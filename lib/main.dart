import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/theme_manager.dart';
import 'utils/language_manager.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';
import 'utils/i18n/app_localizations.dart';
import 'utils/size_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LanguageManager()),
        ChangeNotifierProvider(create: (_) => SizeManager()),
      ],
      child: const AfiaAI(),
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class AfiaAI extends StatelessWidget {
  const AfiaAI({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final languageManager = Provider.of<LanguageManager>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AfiaAI',
      theme: themeManager.lightTheme,
      darkTheme: themeManager.darkTheme,
      themeMode: themeManager.themeMode,
      locale: languageManager.currentLocale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('es'),
        Locale('pt'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate(),
      ],
      home: const HomePage(),
      navigatorObservers: [routeObserver],
      routes: {
        '/history': (context) => const HistoryPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
