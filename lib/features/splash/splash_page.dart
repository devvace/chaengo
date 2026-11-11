import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';

/// 앱 시작 직후 브랜드 GIF를 한 번 재생하고 S01로 넘어간다.
/// 네이티브 런치 화면(정지 로고)과 같은 흰 배경이라 끊김 없이 이어진다.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// GIF 한 바퀴 길이(14프레임, 3.2초). 파일을 바꾸면 같이 맞춘다.
  static const duration = Duration(milliseconds: 3200);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _image = AssetImage('assets/brand/splash.gif');

  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // 디코딩이 끝난 뒤부터 재생 시간을 재야 첫 프레임이 잘리지 않는다.
    precacheImage(_image, context).whenComplete(_startTimer);
  }

  void _startTimer() {
    if (!mounted) return;
    _timer = Timer(SplashPage.duration, () {
      if (mounted) context.go(Routes.trips);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: Image(
          image: _image,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
