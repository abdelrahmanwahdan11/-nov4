import 'package:flutter/material.dart';

import '../../widgets/app_scaffold.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.school, size: 72),
              SizedBox(height: 16),
              Text('Tutorials placeholder'),
            ],
          ),
        ),
      ),
    );
  }
}
