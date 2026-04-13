import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allergyguard/ui/onboarding/onboarding_screen.dart';
import 'package:allergyguard/ui/scanner/scanner_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (_hasUsableSupabaseConfig(supabaseUrl, supabaseAnonKey)) {
      await Supabase.initialize(
        url: supabaseUrl!,
        anonKey: supabaseAnonKey!,
      );
    } else {
      debugPrint(
        'Supabase non configurato: avvio in modalita locale senza backend.',
      );
    }

    runApp(const ProviderScope(child: AllergyGuardApp()));
  } catch (error) {
    runApp(BootstrapErrorApp(message: error.toString()));
  }
}

bool _hasUsableSupabaseConfig(String? url, String? anonKey) {
  if (url == null || anonKey == null) return false;
  final normalizedUrl = url.trim();
  final normalizedKey = anonKey.trim();
  if (normalizedUrl.isEmpty || normalizedKey.isEmpty) return false;
  if (normalizedUrl.contains('your-project.supabase.co')) return false;
  if (normalizedKey == 'your-anon-key') return false;
  return true;
}

class AllergyGuardApp extends StatelessWidget {
  const AllergyGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllergyGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1976D2),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const _AppEntryPoint(),
    );
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllergyGuard',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Errore di avvio')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'L\'app non e riuscita ad avviarsi correttamente.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Controlla il file .env e ricompila l\'app se hai appena '
                'modificato la configurazione.',
              ),
              const SizedBox(height: 24),
              SelectableText(message),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decide se mostrare l'onboarding o la schermata scanner.
class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboardingComplete(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!
            ? const ScannerScreen()
            : const OnboardingScreen();
      },
    );
  }

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }
}
