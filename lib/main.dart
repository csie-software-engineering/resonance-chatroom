import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'constants/constants.dart';
import 'providers/providers.dart';
import 'pages/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<UserProvider>(create: (_) => UserProvider()),
          Provider<ChatProvider>(create: (_) => ChatProvider()),
          Provider<AuthProvider>(create: (_) => AuthProvider()),
          Provider<ActivityProvider>(create: (_) => ActivityProvider()),
          Provider<QuestionProvider>(create: (_) => QuestionProvider()),
        ],
        child: MaterialApp(
          title: AppConstants.appTitle,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xffA7D073)),
            typography: Typography.material2021(),
          ),
          initialRoute: LoginPage.routeName,
          routes: routes,
          debugShowCheckedModeBanner: false,
        ),
      );
}
