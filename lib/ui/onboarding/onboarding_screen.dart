import 'package:flutter/material.dart';
import 'package:allergyguard/ui/common/disclaimer_widget.dart';

/// Schermata di onboarding (primo avvio).
///
/// Flusso:
/// 1. Benvenuto + disclaimer
/// 2. Selezione lingua interfaccia
/// 3. Selezione allergeni (14 EU + personalizzati)
/// 4. Login/registrazione (saltabile)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildAllergenSelectionPage(),
                  _buildLoginPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            'AllergyGuard',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Verifica rapidamente se un prodotto alimentare contiene '
            'allergeni pericolosi per te.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const DisclaimerWidget(),
        ],
      ),
    );
  }

  Widget _buildAllergenSelectionPage() {
    // TODO: Implementare selezione allergeni con lista 14 EU + custom
    return const Center(
      child: Text('Selezione Allergeni'),
    );
  }

  Widget _buildLoginPage() {
    // TODO: Implementare login opzionale
    return const Center(
      child: Text('Login (opzionale)'),
    );
  }

  Widget _buildNavigationButtons() {
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
              child: const Text('Indietro'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // TODO: Navigare alla schermata principale
              }
            },
            child: Text(_currentPage < 2 ? 'Avanti' : 'Inizia'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
