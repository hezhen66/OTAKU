import 'package:astral/core/services/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/features/settings/pages/general/logs_page.dart';
import 'package:astral/shared/utils/helpers/update_helper.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AboutPage extends BaseSettingsPage {
  const AboutPage({super.key});

  @override
  String get title => LocaleKeys.about.tr();

  @override
  Widget buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        buildSettingsCard(
          context: context,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.star, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'OTAKU',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
        ),
        const SizedBox(height: 16),
        buildSettingsCard(
          context: context,
          children: [
            _buildYukiSwitch(context),
            buildDivider(),
            ListTile(
              leading: Hero(tag: "logs_hero", child: const Icon(Icons.article)),
              title: Text(LocaleKeys.view_logs.tr()),
              subtitle: Text(LocaleKeys.view_logs_desc.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigateToLogs(context),
            ),
            buildDivider(),
            ListTile(
              leading: const Icon(Icons.update),
              title: Text(LocaleKeys.check_update.tr()),
              subtitle: Text(LocaleKeys.check_update_available.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _checkForUpdates(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYukiSwitch(BuildContext context) {
    return Watch((_) {
      final enabled = ServiceManager().uiState.isSnowEnabled.value;
      return ListTile(
        leading: const Icon(Icons.ac_unit),
        title: const Text('YUKI', style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold,
          letterSpacing: 2, decoration: TextDecoration.none,
        )),
        trailing: Switch(
          value: enabled,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (v) => ServiceManager().uiState.setSnowEnabled(v),
        ),
      );
    });
  }

  void _navigateToLogs(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LogsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
    if (context.mounted) {
      updateChecker.checkForUpdates(context);
    }
  }
}
