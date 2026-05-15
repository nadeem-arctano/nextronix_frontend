import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ShadApp.custom(
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            appBuilder: (context) {
              return MaterialApp.router(
                title: 'Nextronix Admin',
                debugShowCheckedModeBanner: false,
                theme: Theme.of(context),
                routerConfig: AppRouter.router,
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
