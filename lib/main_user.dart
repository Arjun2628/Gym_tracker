import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/gym_provider.dart';
import 'services/hive_service.dart';
import 'services/firebase_service.dart';
import 'theme/gym_theme.dart';
import 'screens/member_home_shell.dart';

import 'core/di/service_locator.dart';

/// Standalone Entry Point for the USER / MEMBER MOBILE APPLICATION
/// Run with: flutter run -t lib/main_user.dart
/// Build with: flutter build apk -t lib/main_user.dart / flutter build appbundle
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveGymService.init();
  await FirebaseGymService.initialize();
  sl.init();

  runApp(const ApexGymUserApp());
}

class ApexGymUserApp extends StatelessWidget {
  const ApexGymUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final p = GymProvider();
            p.setRole(AppRole.user);
            return p;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ApexGym Athlete Hub',
        debugShowCheckedModeBanner: false,
        theme: GymTheme.darkTheme,
        home: const MemberHomeShell(),
      ),
    );
  }
}
