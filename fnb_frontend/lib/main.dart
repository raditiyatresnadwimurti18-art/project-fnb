import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/pos_provider.dart';
import 'providers/admin_menu_provider.dart';
import 'providers/admin_promo_provider.dart';
import 'providers/admin_kasir_provider.dart';
import 'providers/report_provider.dart';
import 'core/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => AdminMenuProvider()),
        ChangeNotifierProvider(create: (_) => AdminPromoProvider()),
        ChangeNotifierProvider(create: (_) => AdminKasirProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appRouter = AppRouter(authProvider).router;

    return MaterialApp.router(
      title: 'FNB Project',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
