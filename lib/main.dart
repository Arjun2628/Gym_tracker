import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/gym_provider.dart';
import 'services/hive_service.dart';
import 'services/firebase_service.dart';
import 'theme/gym_theme.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/member_home_shell.dart';

import 'core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveGymService.init();
  await FirebaseGymService.initialize();
  sl.init();

  runApp(const ApexGymApp());
}

class ApexGymApp extends StatelessWidget {
  const ApexGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GymProvider()),
      ],
      child: MaterialApp(
        title: 'ApexGym Hub',
        debugShowCheckedModeBanner: false,
        theme: GymTheme.darkTheme,
        // Separate web URL routes:
        // Visiting /admin directly opens the Admin Web Portal.
        // Visiting / or /user directly opens the Member Athlete App.
        initialRoute: '/',
        routes: {
          '/': (context) => const _AppRoutingGate(),
          '/admin': (context) => const AdminShell(),
          '/user': (context) => const MemberHomeShell(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/admin') {
            return MaterialPageRoute(builder: (_) => const AdminShell());
          }
          return MaterialPageRoute(builder: (_) => const MemberHomeShell());
        },
      ),
    );
  }
}

/// Routing gate that opens the appropriate standalone view based on the provider's active role
class _AppRoutingGate extends StatelessWidget {
  const _AppRoutingGate();

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    if (gym.isAdmin) {
      return const AdminShell();
    } else {
      return const MemberHomeShell();
    }
  }
}
