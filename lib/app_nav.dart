import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:project/home_page.dart';
import 'package:project/settings.dart';
import 'package:project/main.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currind = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String>(
      converter: (store) => store.state.language,
      builder: (context, language) {
        return Scaffold(
          body: _pages[_currind],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currind,
            onTap: (index) => setState(() => _currind = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: language == 'Hindi' ? 'पात्र' : 'Characters',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: language == 'Hindi' ? 'सेटिंग्स' : 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}