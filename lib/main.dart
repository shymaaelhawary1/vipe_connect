import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vipe_connect/views/OnBoardingPages.dart';

import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('onboarding_done') ?? false;

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MyApp(
        showOnboarding: !seenOnboarding,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vipe Connect',
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      home: showOnboarding ? const OnboardingScreen() : LoginView(),
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
    );
  }
}
