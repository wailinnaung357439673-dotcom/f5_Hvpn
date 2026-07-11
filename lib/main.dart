import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/vpn_provider.dart';
import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VpnProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'F5 VPN',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}