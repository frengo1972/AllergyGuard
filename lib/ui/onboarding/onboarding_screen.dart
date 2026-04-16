import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/core/locale/locale_provider.dart';
import 'package:allergyguard/data/local/local_allergen_repository.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/domain/models/allergen.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/common/visual_metadata.dart';
import 'package:allergyguard/ui/common/disclaimer_widget.dart';
import 'package:allergyguard/ui/scanner/scanner_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final LocalPreferencesService _preferences = LocalPreferencesService();
  final LocalAllergenRepository _allergenRepository = LocalAllergenRepository();
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isCompleting = false;
  bool _isLoadingPreferences = true;
  List<Allergen> _allergens = <Allergen>[];
  Set<String> _selectedAllergenKeys = <String>{};
  String _languageCode = 'it';

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildLanguageSelectionPage(),
                  _buildAllergenSelectionPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionPage() {
    if (_isLoadingPreferences) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingChooseLanguageTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingChooseLanguageIntro,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingChooseLanguageHint,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const DisclaimerWidget(),
          const SizedBox(height: 20),
          Expanded(
            child: RadioGroup<String>(
              groupValue: _languageCode,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _languageCode = value);
                ref
                    .read(localeControllerProvider.notifier)
                    .setLanguage(value);
              },
              child: ListView(
                children:
                    LocalPreferencesService.supportedLanguages.map((option) {
                  return RadioListTile<String>(
                    value: option.code,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: Text(
                      option.flagEmoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                    title: Text(option.label),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergenSelectionPage() {
    if (_isLoadingPreferences) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context);

    final sortedAllergens = <Allergen>[..._allergens]..sort((left, right) {
        final leftSelected = _selectedAllergenKeys.contains(left.nameKey);
        final rightSelected = _selectedAllergenKeys.contains(right.nameKey);
        if (leftSelected != rightSelected) {
          return leftSelected ? -1 : 1;
        }
        return left
            .localizedName(_languageCode)
            .compareTo(right.localizedName(_languageCode));
      });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingAllergensTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedAllergenKeys.isEmpty
                ? l10n.onboardingAllergensEmptyHint
                : l10n.onboardingAllergensSelectedCount(
                    _selectedAllergenKeys.length,
                  ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: sortedAllergens.length,
              itemBuilder: (context, index) {
                final allergen = sortedAllergens[index];
                final isSelected =
                    _selectedAllergenKeys.contains(allergen.nameKey);

                return CheckboxListTile(
                  value: isSelected,
                  controlAffinity: ListTileControlAffinity.trailing,
                  secondary: allergenBadgeForKey(allergen.nameKey, context),
                  title: Text(allergen.localizedName(_languageCode)),
                  subtitle: Text(
                    allergen.euRegulated
                        ? l10n.onboardingAllergenEuRegulated
                        : l10n.onboardingAllergenCustom,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedAllergenKeys.add(allergen.nameKey);
                      } else {
                        _selectedAllergenKeys.remove(allergen.nameKey);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: Text(l10n.commonBack),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _isCompleting
                ? null
                : () {
                    if (_currentPage < 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
            child: Text(
              _currentPage < 1 ? l10n.commonNext : l10n.commonStart,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadOnboardingState() async {
    final allergens = await _allergenRepository.getAllAllergens();
    final selectedKeys = await _allergenRepository.getSelectedAllergenKeys();
    final languageCode = await _preferences.getInterfaceLanguage();

    if (!mounted) return;
    setState(() {
      _allergens = allergens;
      _selectedAllergenKeys = selectedKeys.toSet();
      _languageCode = languageCode;
      _isLoadingPreferences = false;
    });
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isCompleting = true);
    await _preferences.setInterfaceLanguage(_languageCode);
    await _allergenRepository.setUserAllergens(
      _selectedAllergenKeys.toList()..sort(),
    );
    await _preferences.setOnboardingComplete(true);
    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ScannerScreen(),
      ),
    );

    if (!mounted) return;
    setState(() => _isCompleting = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
