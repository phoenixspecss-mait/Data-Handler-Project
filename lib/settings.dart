import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        final store = StoreProvider.of<AppState>(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text('Appearance',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(state.themeMode == ThemeMode.dark
                        ? 'Dark'
                        : 'Light'),
                    secondary: Icon(
                      state.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (_) => store.dispatch(triggerThemeAction()),
                  ),
                ),

                const SizedBox(height: 24),


                const Text('Language',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: ['English', 'Hindi', 'Spanish'].map((lang) {
                      return RadioListTile<String>(
                        title: Text(lang),
                        value: lang,
                        groupValue: state.language,
                        onChanged: (value) {
                          if (value != null) {
                            store.dispatch(languageChange(value));
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}