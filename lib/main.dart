import 'package:flutter/material.dart';
import 'package:memory_notes/views/Home_page_notesView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,

        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const NotesView(),
      home: const NotesListScreen(),
    );
  }
}
