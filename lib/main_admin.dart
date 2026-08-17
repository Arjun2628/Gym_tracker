import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/gym_provider.dart';
import 'services/hive_service.dart';
import 'services/firebase_service.dart';
import 'theme/gym_theme.dart';
import 'screens/admin/admin_shell.dart';

import 'core/di/service_locator.dart';

/// Standalone Entry Point for the ADMIN WEB APPLICATION
/// Run with: flutter run -t lib/main_admin.dart -d chrome
/// Build with: flutter build web -t lib/main_admin.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveGymService.init();
  await FirebaseGymService.initialize();
  sl.init();

  runApp(const ApexGymAdminApp());
}

class ApexGymAdminApp extends StatelessWidget {
  const ApexGymAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final p = GymProvider();
            p.setRole(AppRole.admin);
            return p;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ApexGym Management Portal (Admin Web)',
        debugShowCheckedModeBanner: false,
        theme: GymTheme.darkTheme,
        home: const AdminShell(),
      ),
    );
  }
}
