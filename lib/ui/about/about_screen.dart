import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:allergyguard/l10n/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static const String privacyPolicyUrl =
      'https://frengo1972.github.io/AllergyGuard/privacy.html';
  static const String repositoryUrl =
      'https://github.com/frengo1972/AllergyGuard';
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = '${info.version} (build ${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _Header(version: _version, l10n: l10n),
          const SizedBox(height: 24),
          _Disclaimer(l10n: l10n),
          const SizedBox(height: 8),
          _SectionHeader(l10n.aboutSectionLegal),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.aboutPrivacyPolicy),
            subtitle: Text(l10n.aboutPrivacySubtitle),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launch(AboutScreen.privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.balance),
            title: Text(l10n.aboutLicense),
            subtitle: Text(l10n.aboutLicenseSubtitle),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'AllergyGuard',
              applicationVersion: _version,
            ),
          ),
          _SectionHeader(l10n.aboutSectionCredits),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Open Food Facts'),
            subtitle: Text(l10n.aboutOffSubtitle),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launch(AboutScreen.openFoodFactsUrl),
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner_outlined),
            title: const Text('Google ML Kit'),
            subtitle: Text(l10n.aboutMlkitSubtitle),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Supabase'),
            subtitle: Text(l10n.aboutSupabaseSubtitle),
          ),
          _SectionHeader(l10n.aboutSectionContact),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.aboutRepositoryTitle),
            subtitle: const Text('github.com/frengo1972/AllergyGuard'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launch(AboutScreen.repositoryUrl),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(l10n.aboutContact),
            subtitle: const Text('allergyguard.app@gmail.com'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launch('mailto:allergyguard.app@gmail.com'),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Made with care for people with food allergies.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aboutLaunchError(url))),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.version, required this.l10n});

  final String version;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.shield,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AllergyGuard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan. Check. Eat safely.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (version.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.aboutVersion} $version',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade700, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.aboutDisclaimer,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
