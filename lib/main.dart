import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/Screens/test.dart';
import 'package:managment/Screens/analytics.dart';
import 'package:managment/Screens/people.dart';
import 'package:managment/Screens/chat.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  const MyAppHome({Key? key}) : super(key: key);

  @override
  _MyAppHomeState createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ChatScreen(),
    const Analytics(),
    const People(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelli-FinTech'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 201, 158, 212),
              ),
              child: Text(
                'App Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Wallet Advisor'),
              onTap: () {
                _changePage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Analytical Dashboard'),
              onTap: () {
                _changePage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Wealth Accumulation'),
              onTap: () {
                _changePage(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
    );
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
