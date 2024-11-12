import 'package:flutter/material.dart';
import 'component/dashbord.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/dashbord',
        routes: {
          '/dashbord': (context) => const Dashboard(),
          // '/notepad': (context)=> const Notepad(),
        }
    );
  }

}