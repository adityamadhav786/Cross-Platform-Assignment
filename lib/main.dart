import 'package:flutter/material.dart';
import 'package:quick_task_app_assignment/login_page.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'AJRbklyFu2CiY1lKvWgp2tgfBq3XqYNpkv3HnQ4b';
  final keyClientKey = 'vmGVUTkjqj0CHk5H9aQZA4HZOkJZa0IPezlVAuWD';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTaskApp',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 33, 33, 33),
        scaffoldBackgroundColor: Colors.grey[200],
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.amber),
      ),
      home: LoginPage(),
    );
  }
}
