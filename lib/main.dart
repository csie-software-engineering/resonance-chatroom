import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/src/material_widget.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<SharedPreferenceProvider>(
              create: (_) => SharedPreferenceProvider()),
          Provider<UserProvider>(create: (_) => UserProvider()),
          Provider<ChatProvider>(create: (_) => ChatProvider()),
          Provider<AuthProvider>(create: (_) => AuthProvider()),
          Provider<ActivityProvider>(create: (_) => ActivityProvider()),
          Provider<QuestionProvider>(create: (_) => QuestionProvider()),
        ],
        child: const MaterialWidget(),
      );
}
