import 'dart:io';
import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/frosted_glass.dart';
import 'package:astral/shared/widgets/hud/bg_picker_popup.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/features/settings/pages/network/listen_list_page.dart';
import 'package:astral/features/settings/pages/network/network_adapter_page.dart';
import 'package:astral/features/settings/pages/network/vpn_segment_page.dart';
import 'package:astral/features/settings/pages/network/network_settings_page.dart';
import 'package:astral/features/settings/pages/general/startup_page.dart';
import 'package:astral/features/settings/pages/general/software_settings_page.dart';
import 'package:astral/features/settings/pages/general/update_settings_page.dart';
import 'package:astral/features/settings/pages/general/logs_page.dart';
import 'package:astral/features/settings/pages/general/about_page.dart';
import 'package:astral/features/settings/pages/server_settings_page.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, '服务器管理'),
          const SizedBox(height: 8),
          _buildSettingsCard(context, icon: Icons.dns, title: '服务器列表', subtitle: '管理和配置服务器',
              onTap: () => _navigateToPage(context, const ServerSettingsPage())),
          const SizedBox(height: 24),
          _buildSectionHeader(context, LocaleKeys.network_settings.tr()),
          const SizedBox(height: 8),
          _buildSettingsCard(context, icon: Icons.list_alt, title: LocaleKeys.listen_list.tr(), subtitle: '管理网络监听地址',
              onTap: () => _navigateToPage(context, const ListenListPage())),
          _buildSettingsCard(context, icon: Icons.settings_ethernet, title: '网络适配器', subtitle: '选择和管理虚拟网卡',
              onTap: () => _navigateToPage(context, const NetworkAdapterPage())),
          _buildSettingsCard(context, icon: Icons.vpn_lock, title: LocaleKeys.custom_vpn_segment.tr(), subtitle: '配置VPN网段',
              onTap: () => _navigateToPage(context, const VpnSegmentPage())),
          _buildSettingsCard(context, icon: Icons.network_wifi, title: '高级网络设置', subtitle: '协议、加密等高级选项',
              onTap: () => _navigateToPage(context, const NetworkSettingsPage())),
          const SizedBox(height: 24),
          _buildSectionHeader(context, '通用设置'),
          const SizedBox(height: 8),
          if (!Platform.isAndroid)
            _buildSettingsCard(context, icon: Icons.launch, title: LocaleKeys.startup_related.tr(), subtitle: '开机启动和自动连接',
                onTap: () => _navigateToPage(context, const StartupPage())),
          _buildSettingsCard(context, icon: Icons.info, title: LocaleKeys.software_settings.tr(), subtitle: '权限和界面设置',
              onTap: () => _navigateToPage(context, const SoftwareSettingsPage())),
          _buildBgPickerCard(context),
          _buildSettingsCard(context, icon: Icons.system_update, title: LocaleKeys.update_settings.tr(), subtitle: '自动更新和下载设置',
              onTap: () => _navigateToPage(context, const UpdateSettingsPage())),
          _buildSettingsCard(context, icon: Icons.article_outlined, title: '日志', subtitle: '查看应用运行日志',
              onTap: () => _navigateToPage(context, const LogsPage())),
          _buildSettingsCard(context, icon: Icons.info_outline, title: '关于', subtitle: '版本和内核信息',
              onTap: () => _navigateToPage(context, const AboutPage())),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(title.toUpperCase(), style: AppTheme.hudBody(color: AppTheme.textSecondary)),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FrostedGlassPanel(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(title, style: AppTheme.hudBody()),
          subtitle: Text(subtitle, style: AppTheme.hudBody(fontSize: 12, color: AppTheme.textSecondary)),
          trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildBgPickerCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FrostedGlassPanel(
        padding: EdgeInsets.zero,
        onTap: () => showBgPickerDialog(context),
        child: ListTile(
          leading: Icon(Icons.image_outlined, color: AppTheme.primary),
          title: Text('背景图片', style: AppTheme.hudBody()),
          subtitle: Text('切换主界面背景图片', style: AppTheme.hudBody(fontSize: 12, color: AppTheme.textSecondary)),
          trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}
