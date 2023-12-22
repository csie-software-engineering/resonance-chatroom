import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import '../../providers/providers.dart';
import '../routes.dart';

class MaterialWidget extends StatelessWidget {
  const MaterialWidget({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: context.watch<SharedPreferenceProvider>().pref,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final instance = snapshot.data!;
          return MaterialApp(
            title: AppConstants.appTitle,
            theme: ThemeData(
              colorSchemeSeed: (instance.getBool('isHost') ?? false)
                  ? Colors.pink
                  : const Color(0xffA7D073),
            ),
            initialRoute: LoginPage.routeName,
            routes: routes,
            debugShowCheckedModeBanner: false,
          );
        },
      );
}
