import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'menu_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://opdwkiuvugnicchqnkqc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wZHdraXV2dWduaWNjaHFua3FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyMTk4NjcsImV4cCI6MjA2Njc5NTg2N30.gRA_4t-ztR-FzFeGTt7A1ovVt3cjabcxUPDfuACSvIA',
  );
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Egble App',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/menu': (context) => const MenuPage(),
      },
    );
  }
}
