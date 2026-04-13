import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/data/remote/feedback_remote_repo.dart';
import 'package:allergyguard/providers.dart';

/// Schermata feedback utente.
///
/// Raccoglie in forma anonima:
/// - Tipo di feedback (suggerimento, bug, generale, accuratezza scansione)
/// - Commento libero
/// - Opzionale: se il risultato di una scansione era corretto + livello atteso
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({
    super.key,
    this.prefilledResultLevel,
    this.prefilledBarcode,
    this.prefilledAllergenKeys = const <String>[],
  });

  final String? prefilledResultLevel;
  final String? prefilledBarcode;
  final List<String> prefilledAllergenKeys;

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _commentController = TextEditingController();
  final _prefs = LocalPreferencesService();

  FeedbackType _selectedType = FeedbackType.general;
  bool? _isCorrect;
  String? _expectedLevel;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledResultLevel != null) {
      _selectedType = FeedbackType.scanAccuracy;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lascia un feedback')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _InfoCard(
                icon: Icons.lock_outline,
                text:
                    'Il feedback è completamente anonimo. Non raccogliamo '
                    'nome, email o posizione. Solo un ID casuale per evitare '
                    'duplicati.',
              ),
              const SizedBox(height: 20),
              Text('Tipo di feedback', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _FeedbackTypeSelector(
                selected: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              if (_selectedType == FeedbackType.scanAccuracy) ...[
                const SizedBox(height: 24),
                Text(
                  'Il risultato della scansione era corretto?',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceChip(
                        label: 'Sì, corretto',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        selected: _isCorrect == true,
                        onTap: () => setState(() {
                          _isCorrect = true;
                          _expectedLevel = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChoiceChip(
                        label: 'No, sbagliato',
                        icon: Icons.cancel,
                        color: Colors.red,
                        selected: _isCorrect == false,
                        onTap: () => setState(() => _isCorrect = false),
                      ),
                    ),
                  ],
                ),
                if (_isCorrect == false) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Quale sarebbe stato il risultato corretto?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ExpectedLevelPicker(
                    selected: _expectedLevel,
                    onChanged: (level) =>
                        setState(() => _expectedLevel = level),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Text('Commento', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                minLines: 4,
                maxLines: 8,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: _commentHint,
                  border: const OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Invio...' : 'Invia feedback'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Se ti piace l\'app, lascia una recensione sullo store!',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _commentHint {
    switch (_selectedType) {
      case FeedbackType.scanAccuracy:
        return 'Descrivi cosa hai scansionato e cosa ti aspettavi...';
      case FeedbackType.suggestion:
        return 'Quale funzionalità vorresti vedere nell\'app?';
      case FeedbackType.bugReport:
        return 'Descrivi il problema riscontrato. Cosa hai fatto prima che accadesse?';
      case FeedbackType.general:
        return 'Raccontaci cosa pensi dell\'app...';
    }
  }

  Future<void> _submit() async {
    if (_commentController.text.trim().isEmpty &&
        _selectedType != FeedbackType.scanAccuracy) {
      _snack('Scrivi un commento prima di inviare.');
      return;
    }
    if (_selectedType == FeedbackType.scanAccuracy && _isCorrect == null) {
      _snack('Indica se il risultato della scansione era corretto.');
      return;
    }

    setState(() => _submitting = true);

    final repo = ref.read(feedbackRemoteRepoProvider);
    if (!repo.isConfigured) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _snack(
        'Backend non configurato. Il feedback verrà inviato quando disponibile.',
      );
      return;
    }

    final deviceId = await _prefs.getOrCreateDeviceId();
    final languageCode = await _prefs.getInterfaceLanguage();
    final packageInfo = await PackageInfo.fromPlatform();
    final countryCode = WidgetsBinding
            .instance.platformDispatcher.locale.countryCode ??
        '';

    final success = await repo.submit(
      deviceId: deviceId,
      type: _selectedType,
      resultLevel: widget.prefilledResultLevel,
      isCorrect: _isCorrect,
      expectedLevel: _expectedLevel,
      productBarcode: widget.prefilledBarcode,
      allergenKeys: widget.prefilledAllergenKeys,
      comment: _commentController.text.trim(),
      languageCode: languageCode,
      countryCode: countryCode,
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.favorite, color: Colors.red, size: 40),
          title: const Text('Grazie!'),
          content: const Text(
            'Il tuo feedback ci aiuta a migliorare AllergyGuard. '
            'Ogni segnalazione viene letta e presa in considerazione.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      _snack('Errore di invio. Riprova più tardi.');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackTypeSelector extends StatelessWidget {
  const _FeedbackTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final FeedbackType selected;
  final ValueChanged<FeedbackType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FeedbackType.values.map((type) {
        final label = _labelFor(type);
        final icon = _iconFor(type);
        final isSelected = type == selected;
        return ChoiceChip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }

  String _labelFor(FeedbackType type) {
    switch (type) {
      case FeedbackType.scanAccuracy:
        return 'Accuratezza scansione';
      case FeedbackType.suggestion:
        return 'Suggerimento';
      case FeedbackType.bugReport:
        return 'Segnala bug';
      case FeedbackType.general:
        return 'Commento generale';
    }
  }

  IconData _iconFor(FeedbackType type) {
    switch (type) {
      case FeedbackType.scanAccuracy:
        return Icons.fact_check_outlined;
      case FeedbackType.suggestion:
        return Icons.lightbulb_outline;
      case FeedbackType.bugReport:
        return Icons.bug_report_outlined;
      case FeedbackType.general:
        return Icons.chat_bubble_outline;
    }
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : null,
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey.shade600),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ExpectedLevelPicker extends StatelessWidget {
  const _ExpectedLevelPicker({
    required this.selected,
    required this.onChanged,
  });

  final String? selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('danger', 'Pericoloso', Colors.red),
    ('warning', 'Attenzione', Colors.orange),
    ('safe', 'Sicuro', Colors.green),
    ('unknown', 'Non determinabile', Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((option) {
        final (value, label, color) = option;
        final isSelected = value == selected;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.2),
          side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
          onSelected: (_) => onChanged(value),
        );
      }).toList(),
    );
  }
}
