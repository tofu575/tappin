import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/widgets/paper_background.dart';

const _officialWebsiteUrl = 'https://tofu575.com/tappin/';
const _privacyPolicyUrl = 'https://tofu575.com/tappin/privacy/';
const _termsOfServiceUrl = 'https://tofu575.com/tappin/terms/';

/// Tappinの公式サイトとポリシー・規約への導線をまとめる画面。
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTappin)),
      body: PaperBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                l10n.aboutDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: context.tapPinColors.stickyNote,
                child: InkWell(
                  key: const Key('official-website-link'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openWebPage(context, _officialWebsiteUrl),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.tapPinColors.paperElevated,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.language_rounded),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.officialWebsite,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.officialWebsiteDescription,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l10n.legalInformation,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      key: const Key('privacy-policy-link'),
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(l10n.privacyPolicy),
                      subtitle: Text(l10n.opensInBrowser),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () => _openWebPage(context, _privacyPolicyUrl),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      key: const Key('terms-of-service-link'),
                      leading: const Icon(Icons.description_outlined),
                      title: Text(l10n.termsOfService),
                      subtitle: Text(l10n.opensInBrowser),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () => _openWebPage(context, _termsOfServiceUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 選択されたWebページを開き、失敗時は画面内で通知する。
  Future<void> _openWebPage(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorMessage = context.l10n.webPageOpenError;
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } on Exception {
      if (!messenger.mounted) return;
    }

    messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
