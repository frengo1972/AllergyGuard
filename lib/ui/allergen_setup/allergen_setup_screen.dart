import 'package:flutter/material.dart';
import 'package:allergyguard/data/local/local_allergen_repository.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/domain/models/allergen.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/common/visual_metadata.dart';

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
  final LocalAllergenRepository _allergenRepository = LocalAllergenRepository();
  final LocalPreferencesService _preferences = LocalPreferencesService();

  String _searchQuery = '';
  bool _isLoading = true;
  String _languageCode = 'it';
  List<Allergen> _allergens = <Allergen>[];
  Set<String> _selectedAllergenKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allergenSetupTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.allergenSetupSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
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
        label: Text(l10n.allergenSetupAddButton),
      ),
    );
  }

  Widget _buildAllergenList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = AppLocalizations.of(context);
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filtered = _allergens.where((allergen) {
      if (normalizedQuery.isEmpty) return true;
      return allergen.allNames.any(
        (name) => name.toLowerCase().contains(normalizedQuery),
      );
    }).toList()
      ..sort((left, right) {
        final leftSelected = _selectedAllergenKeys.contains(left.nameKey);
        final rightSelected = _selectedAllergenKeys.contains(right.nameKey);
        if (leftSelected != rightSelected) {
          return leftSelected ? -1 : 1;
        }
        return left
            .localizedName(_languageCode)
            .compareTo(right.localizedName(_languageCode));
      });

    if (filtered.isEmpty) {
      return Center(child: Text(l10n.allergenSetupEmpty));
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        112 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final allergen = filtered[index];
        final isSelected = _selectedAllergenKeys.contains(allergen.nameKey);
        return SwitchListTile(
          value: isSelected,
          secondary: allergenBadgeForKey(allergen.nameKey, context),
          title: Text(allergen.localizedName(_languageCode)),
          subtitle: Text(
            allergen.euRegulated
                ? l10n.onboardingAllergenEuRegulated
                : l10n.onboardingAllergenCustom,
          ),
          onChanged: (value) => _toggleAllergen(allergen.nameKey, value),
        );
      },
    );
  }

  void _showAddCustomAllergenDialog() {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.allergenSetupAddCustom),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.allergenSetupNameHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final nextId = _allergens.isEmpty
                    ? 1000
                    : _allergens.map((allergen) => allergen.id).reduce(
                            (left, right) => left > right ? left : right) +
                        1;
                final generatedKey = name
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
                    .replaceAll(RegExp(r'^_+|_+$'), '');

                await _allergenRepository.addCustomAllergen(
                  Allergen(
                    id: nextId,
                    nameKey:
                        generatedKey.isEmpty ? 'custom_$nextId' : generatedKey,
                    names: <String, String>{
                      _languageCode: name,
                      'en': name,
                      'it': name,
                    },
                    severity: 'medium',
                    euRegulated: false,
                  ),
                );

                if (!mounted) return;
                navigator.pop();
                await _loadState();
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.allergenSetupAddedToList(name)),
                  ),
                );
              },
              child: Text(l10n.allergenSetupAddButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadState() async {
    final allergens = await _allergenRepository.getAllAllergens();
    final selectedKeys = await _allergenRepository.getSelectedAllergenKeys();
    final languageCode = await _preferences.getInterfaceLanguage();

    if (!mounted) return;
    setState(() {
      _allergens = allergens;
      _selectedAllergenKeys = selectedKeys.toSet();
      _languageCode = languageCode;
      _isLoading = false;
    });
  }

  Future<void> _toggleAllergen(String allergenKey, bool enabled) async {
    final updated = <String>{..._selectedAllergenKeys};
    if (enabled) {
      updated.add(allergenKey);
    } else {
      updated.remove(allergenKey);
    }

    setState(() => _selectedAllergenKeys = updated);
    await _allergenRepository.setUserAllergens(updated.toList()..sort());
  }
}
