import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/bottom_nav.dart';
import '../main.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with RouteAware {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route is shown again (e.g., after popping a pushed route)
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('diagnostic_history') ?? '[]';
    setState(() {
      _history = List<Map<String, dynamic>>.from(
          json.decode(historyJson).map((x) => Map<String, dynamic>.from(x)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final diagnostic = _history[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(diagnostic['type']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${diagnostic['date']}'),
                  Text('Résultat: ${diagnostic['result']}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  setState(() {
                    _history.removeAt(index);
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    'diagnostic_history',
                    json.encode(_history),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
