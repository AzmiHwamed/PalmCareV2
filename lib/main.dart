import 'package:flutter/material.dart';
import 'package:palmcare/screens/monitor_solar_power.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استيراد الصفحات
import 'screens/access_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/gerer_planning_screen.dart';
import 'screens/planning_list_screen.dart';
import 'screens/add_planning_screen.dart';
import 'screens/edit_planning_screen.dart';
import 'screens/planning_history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

// استيراد ملف إعدادات Supabase
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wovgmgilyfaphiwaowvo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvdmdtZ2lseWZhcGhpd2Fvd3ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0Mzk2ODgsImV4cCI6MjA2MzAxNTY4OH0.SCe1rz20XBqVvpv-PtQG-_gw6uT4QhzvHWzsWL1dSRQ',
  );

  runApp(const PalmCareApp());
}

class PalmCareApp extends StatelessWidget {
  const PalmCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      title: 'PalmCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
      ),
      initialRoute: user == null ? '/access' : '/home',
      routes: {
        '/access': (context) => const AccessScreen(),
        '/auth': (context) => const AuthScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/gererPlanning': (context) => const GererPlanningScreen(),
        '/planningList': (context) => const PlanningListScreen(),
        '/addPlanning': (context) => const AddPlanningScreen(),
        '/editPlanning':
            (context) => EditPlanningScreen(
              planningId:
                  ModalRoute.of(context)!.settings.arguments != null
                      ? (ModalRoute.of(context)!.settings.arguments
                          as Map)['id']
                      : 'sample_id',
            ),
        '/planningHistory':
            (context) => const PlanningHistoryScreen(userId: 'sample_user'),
        '/monitor': (context) => const PanelBatteryMonitoringPage(),
      },
    );
  }
}
