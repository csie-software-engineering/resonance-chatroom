import 'package:flutter/material.dart';

import '../../pages/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                '一個讓你認識新朋友的地方',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Image.asset(
                'lib/assets/diversity.png',
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              FloatingActionButton.extended(
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
