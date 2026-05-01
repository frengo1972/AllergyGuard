import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/data/feedback/feedback_submission_service.dart';
import 'package:allergyguard/data/remote/feedback_remote_repo.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/providers.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({
    super.key,
    this.prefilledResultLevel,
    this.prefilledBarcode,
    this.prefilledAllergenKeys = const <String>[],
    this.initialIsCorrect,
  });

  final String? prefilledResultLevel;
  final String? prefilledBarcode;
  final List<String> prefilledAllergenKeys;
  final bool? initialIsCorrect;

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _commentController = TextEditingController();

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
    _isCorrect = widget.initialIsCorrect;
    unawaited(ref.read(feedbackSubmissionServiceProvider).flushPending());
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(
                icon: Icons.lock_outline,
                text: l10n.feedbackAnonymousNotice,
              ),
              const SizedBox(height: 20),
              Text(l10n.feedbackTypeLabel, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _FeedbackTypeSelector(
                selected: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
                l10n: l10n,
              ),
              if (_selectedType == FeedbackType.scanAccuracy) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.feedbackWasCorrectQuestion,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceChip(
                        label: l10n.feedbackWasCorrectYes,
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
                        label: l10n.feedbackWasCorrectNo,
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
                    l10n.feedbackExpectedQuestion,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ExpectedLevelPicker(
                    selected: _expectedLevel,
                    onChanged: (level) =>
                        setState(() => _expectedLevel = level),
                    l10n: l10n,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Text(l10n.feedbackCommentLabel,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                minLines: 4,
                maxLines: 8,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: _commentHint(l10n),
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
                label: Text(
                  _submitting ? l10n.commonSending : l10n.feedbackSubmit,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n.feedbackStoreReviewCta,
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

  String _commentHint(AppLocalizations l10n) {
    switch (_selectedType) {
      case FeedbackType.scanAccuracy:
        return l10n.feedbackCommentHintScanAccuracy;
      case FeedbackType.suggestion:
        return l10n.feedbackCommentHintSuggestion;
      case FeedbackType.bugReport:
        return l10n.feedbackCommentHintBugReport;
      case FeedbackType.general:
        return l10n.feedbackCommentHintGeneral;
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_commentController.text.trim().isEmpty &&
        _selectedType != FeedbackType.scanAccuracy) {
      _snack(l10n.feedbackNeedComment);
      return;
    }
    if (_selectedType == FeedbackType.scanAccuracy && _isCorrect == null) {
      _snack(l10n.feedbackNeedCorrectness);
      return;
    }

    setState(() => _submitting = true);

    final submissionService = ref.read(feedbackSubmissionServiceProvider);
    final outcome = await submissionService.submit(
      type: _selectedType,
      resultLevel: widget.prefilledResultLevel,
      isCorrect: _isCorrect,
      expectedLevel: _expectedLevel,
      productBarcode: widget.prefilledBarcode,
      allergenKeys: widget.prefilledAllergenKeys,
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (outcome == FeedbackSubmitOutcome.submitted ||
        outcome == FeedbackSubmitOutcome.queued) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.favorite, color: Colors.red, size: 40),
          title: Text(l10n.feedbackThankYouTitle),
          content: Text(l10n.feedbackThankYouBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonClose),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      _snack(l10n.feedbackSubmitError);
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
    required this.l10n,
  });

  final FeedbackType selected;
  final ValueChanged<FeedbackType> onChanged;
  final AppLocalizations l10n;

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
        return l10n.feedbackTypeScanAccuracy;
      case FeedbackType.suggestion:
        return l10n.feedbackTypeSuggestion;
      case FeedbackType.bugReport:
        return l10n.feedbackTypeBugReport;
      case FeedbackType.general:
        return l10n.feedbackTypeGeneral;
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
    required this.l10n,
  });

  final String? selected;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final options = <(String, String, Color)>[
      ('danger', l10n.feedbackExpectedDanger, Colors.red),
      ('warning', l10n.feedbackExpectedWarning, Colors.orange),
      ('safe', l10n.feedbackExpectedSafe, Colors.green),
      ('unknown', l10n.feedbackExpectedUnknown, Colors.grey),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
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
