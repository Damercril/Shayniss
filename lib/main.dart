import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/screens/main_navigation.dart';
import 'features/messages/services/message_service.dart';
import 'features/messages/services/sound_service.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  try {
    // Initialiser le service de notifications
    await PushNotificationService.instance.initialize();
  } catch (e) {
    print('Erreur d\'initialisation des notifications: $e');
  }

  await initializeDateFormatting('fr_FR', null);
  await MessageService.instance.init();
  await SoundService.instance.init();
  await AuthService.init(); // Initialiser le service d'authentification
  
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
          initialRoute: '/',
          routes: {
            '/': (context) => const MainNavigation(),
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}
