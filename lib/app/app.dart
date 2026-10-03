import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class ChaengoApp extends StatefulWidget {
  const ChaengoApp({super.key});

  @override
  State<ChaengoApp> createState() => _ChaengoAppState();
}

class _ChaengoAppState extends State<ChaengoApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '챙고',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
