import 'package:flutter/material.dart';

/// Schermata gestione allergeni.
///
/// - Lista 14 allergeni EU con toggle on/off
/// - Campo ricerca
/// - Bottone 'Aggiungi allergene personalizzato'
class AllergenSetupScreen extends StatefulWidget {
  const AllergenSetupScreen({super.key});

  @override
  State<AllergenSetupScreen> createState() => _AllergenSetupScreenState();
}

class _AllergenSetupScreenState extends State<AllergenSetupScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei allergeni'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cerca allergene...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          Expanded(
            child: _buildAllergenList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomAllergenDialog,
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
    );
  }

  Widget _buildAllergenList() {
    // TODO: Integrare con Riverpod provider per lista allergeni
    return const Center(child: Text('Caricamento allergeni...'));
  }

  void _showAddCustomAllergenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi allergene personalizzato'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Nome allergene',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Salvare allergene personalizzato
              Navigator.pop(context);
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}
