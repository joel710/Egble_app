import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/menu'));
    } else {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    }
    return Scaffold(
      backgroundColor: Color(0xFF191919),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFC34E00)),
      ),
    );
  }
} 