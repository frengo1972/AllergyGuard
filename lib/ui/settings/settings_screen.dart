import 'package:flutter/material.dart';

/// Schermata impostazioni.
///
/// - Gestione allergeni
/// - Velocità TTS (lento/normale/veloce)
/// - Auto-play TTS on/off
/// - Login/logout
/// - GDPR: elimina tutti i dati
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        children: [
          const _SectionHeader('Allergeni'),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Gestisci allergeni'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigare a AllergenSetupScreen
            },
          ),
          const _SectionHeader('Accessibilità'),
          // TODO: TTS speed selector
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Velocità lettura'),
            subtitle: const Text('Normale'),
            onTap: () {
              // TODO: Mostrare selettore velocità TTS
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Lettura automatica risultato'),
            value: true, // TODO: Da Riverpod
            onChanged: (value) {
              // TODO: Salvare preferenza
            },
          ),
          const _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Accedi / Registrati'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Login
            },
          ),
          const _SectionHeader('Privacy'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Elimina tutti i miei dati',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              // TODO: Conferma e cancellazione GDPR
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
