import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fnb_frontend/main.dart';
import 'package:fnb_frontend/providers/auth_provider.dart';
import 'package:fnb_frontend/providers/pos_provider.dart';
import 'package:fnb_frontend/providers/admin_menu_provider.dart';
import 'package:fnb_frontend/providers/admin_promo_provider.dart';
import 'package:fnb_frontend/providers/admin_kasir_provider.dart';
import 'package:fnb_frontend/providers/report_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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

    // Verify that the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
