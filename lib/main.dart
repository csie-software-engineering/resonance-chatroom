import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'constants/constants.dart';
import 'providers/providers.dart';
import 'pages/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences pref = await SharedPreferences.getInstance();
  runApp(MyApp(
    pref: pref,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences pref;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  MyApp({super.key, required this.pref});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<UserProvider>(
            create: (_) => UserProvider(
              db: firebaseFirestore,
            ),
          ),
          Provider<ChatProvider>(
            create: (_) => ChatProvider(
              pref: pref,
              firebaseFirestore: firebaseFirestore,
            ),
          ),
          ChangeNotifierProvider<AuthProviders>(
            create: (_) => AuthProviders(
              pref: pref,
              firebaseAuth: firebaseAuth,
            ),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              background: const Color(0xffFFFCE3),
              primary: const Color(0xffA7D073),
              onPrimary: const Color(0xff1d1c21),
              secondary: const Color(0xffFFE500),
              inversePrimary: const Color(0xFF8EA373),
              surface: const Color(
                  0xffD9EBD0), // secondary: const Color(0xff1d1c21),
              brightness: MediaQuery.platformBrightnessOf(context),
            ),
          ),
          initialRoute: Routes.initPage.value,
          routes: routes,
          debugShowCheckedModeBanner: false,
        ),
      );
}
