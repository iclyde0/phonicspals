import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/audio/phonics_audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/kid_button.dart';
import '../mascot/mascot_widget.dart';
import '../world_map/world_map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _enter() {
    context.read<PhonicsAudioService>().playTap();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const WorldMapScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.04).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: Image.asset(
                  'assets/images/logo_mascot.png',
                  height: MediaQuery.sizeOf(context).height * 0.58,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const MascotWidget(size: 220),
                ),
              ),
              const Spacer(),
              KidButton(
                label: 'Play',
                icon: Icons.play_arrow_rounded,
                onPressed: _enter,
              ),
              const SizedBox(height: 12),
              Text(
                '100% offline · made for little readers',
                style: AppTheme.nunito(size: 13, color: AppColors.meadow),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
