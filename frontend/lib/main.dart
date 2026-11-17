import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/storage/token_storage.dart';
import 'providers/ai_chat_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'views/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent token storage & cached preferences
  await TokenStorage.init();

  runApp(const ServiceBookingApp());
}

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
      ],
      child: MaterialApp(
        title: 'ServiceEase - Booking & Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashView(),
      ),
    );
  }
}
