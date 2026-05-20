import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';
import 'provider/auth_provider.dart';
import 'provider/provider.dart';
import 'provider/user_provider.dart';

void main() {
  usePathUrlStrategy();
  runApp(const NextronixAdmin());
}

class NextronixAdmin extends StatelessWidget {
  const NextronixAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HsnProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => BusinessSettingsProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => ReturnProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => GstProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => VariantProvider()),
        ChangeNotifierProvider(create: (_) => VariantGroupProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => ColorMasterProvider()),
        ChangeNotifierProvider(create: (_) => MaterialMasterProvider()),
        ChangeNotifierProvider(create: (_) => SuperAdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminsTableProvider()),
        ChangeNotifierProvider(create: (_) => ThemeCatalogProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, auth, _) {
          return ShadApp.custom(
            themeMode: themeProvider.themeMode,
            theme: themeProvider.compiledLightTheme,
            darkTheme: themeProvider.compiledDarkTheme,
            appBuilder: (context) {
              return MaterialApp.router(
                title: 'Nextronix Admin',
                debugShowCheckedModeBanner: false,
                theme: Theme.of(context),
                routerConfig: AppRouter.build(auth),
                localizationsDelegates: const [
                  GlobalShadLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                builder: (context, child) {
                  return ShadAppBuilder(child: child!);
                },
              );
            },
          );
        },
      ),
    );
  }
}


// Super Admin → superadmin@nextronix.com / SuperAdmin@123

//    Tronix Electronics:
//      Admin    → admin@tronix.com / admin123
//      Manager  → manager@tronix.com / manager123
//      Customer → customer1@tronix.com ... customer10@tronix.com / customer123
//    Lumora Lights:
//      Admin    → admin@lumora.com / admin123
//      Manager  → manager@lumora.com / manager123
//      Customer → customer1@lumora.com ... customer10@lumora.com / customer123
//    Volta Power:
//      Admin    → admin@volta.com / admin123
//      Manager  → manager@volta.com / manager123
    //  Customer → customer1@volta.com ... customer10@volta.com / customer123