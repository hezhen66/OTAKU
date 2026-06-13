import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/utils/network/astral_udp.dart';
import 'package:astral/core/constants/small_window_adapter.dart';
import 'package:astral/features/home/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:signals_flutter/signals_flutter.dart';

final GlobalKey<NavigatorState> globalNavKey = GlobalKey<NavigatorState>();

class KevinApp extends StatefulWidget {
  const KevinApp({super.key});
  @override
  State<KevinApp> createState() => _KevinAppState();
}

class _KevinAppState extends State<KevinApp> {
  final _services = ServiceManager();

  @override
  void initState() {
    super.initState();
    getIpv4AndIpV6Addresses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final themeColor = _services.themeState.themeColor.value;
      final themeMode = _services.themeState.themeMode.value;

      return MaterialApp(
        navigatorKey: globalNavKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (BuildContext context, Widget? child) {
          MediaQueryData mediaQuery = MediaQuery.of(context);
          mediaQuery = SmallWindowAdapter.adaptMediaQuery(mediaQuery);

          return MediaQuery(
            data: mediaQuery,
            child: SmallWindowAdapter.createSafeAreaAdapter(
              child ?? const SizedBox.shrink(),
            ),
          );
        },
        theme: AppTheme.build(themeColor),
        darkTheme: AppTheme.build(themeColor),
        themeMode: themeMode,
        home: MainScreen(),
      );
    });
  }
}
