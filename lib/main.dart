import 'package:flutter/material.dart';
import 'menu_page.dart';

void main() {
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
      home: const MenuPage(),
    );
  }
}
