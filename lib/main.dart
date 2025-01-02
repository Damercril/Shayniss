import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/professional/screens/professional_navigation.dart';
import 'features/client/screens/client_navigation.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/messages/services/message_service.dart';
import 'features/notifications/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  try {
    await PushNotificationService.instance.initialize();
  } catch (e) {
    print('Erreur d\'initialisation des notifications: $e');
  }

  await initializeDateFormatting('fr_FR', null);
  await MessageService.instance.init();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Shayniss',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          home: FutureBuilder<bool>(
            future: AuthService.isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                return FutureBuilder<bool>(
                  future: AuthService.isProfessional(),
                  builder: (context, proSnapshot) {
                    if (proSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return proSnapshot.data == true
                        ? const ProfessionalNavigation()
                        : const ClientNavigation();
                  },
                );
              }

              return const LoginScreen();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/professional': (context) => const ProfessionalNavigation(),
            '/client': (context) => const ClientNavigation(),
          },
        );
      },
    );
  }
}
