import 'package:flutter/material.dart';

import '../../pages/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                '共鳴聚會',
                style: TextStyle(
                  fontSize: 42,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text(
                '一個讓你認識同好的地方',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
              Image.asset(
                'lib/assets/diversity.png',
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
              FloatingActionButton.extended(
                heroTag: 'welcomeFAB',
                onPressed: () =>
                    Navigator.of(context).pushNamed(LoginPage.routeName),
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  '繼續',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
