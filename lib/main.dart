import 'package:flutter/material.dart';
import 'caravella_fab.dart';
import 'viaggio_corrente_tile.dart';

void main() {
  runApp(const CaravellaApp());
}

class CaravellaApp extends StatelessWidget {
  const CaravellaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caravella',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CaravellaHomePage(title: 'Caravella'),
    );
  }
}

class CaravellaHomePage extends StatefulWidget {
  const CaravellaHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CaravellaHomePage> createState() => _CaravellaHomePageState();
}

class _CaravellaHomePageState extends State<CaravellaHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tolgo l'appBar per avere l'immagine a tutto schermo
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/viaggio_bg.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: const ViaggioCorrenteTile(),
          ),
        ],
      ),
      floatingActionButton: CaravellaFab(
        onRefresh: () {
          setState(() {});
        },
      ),
    );
  }
}
