import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/audio/phonics_audio_service.dart';
import 'core/theme/app_theme.dart';
import 'features/progress/progress_cubit.dart';
import 'features/progress/progress_repository.dart';
import 'features/splash/splash_screen.dart';

class PhonicsPalsApp extends StatelessWidget {
  const PhonicsPalsApp({
    super.key,
    required this.repository,
    required this.audio,
  });

  final ProgressRepository repository;
  final PhonicsAudioService audio;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: audio,
      child: BlocProvider(
        create: (_) => ProgressCubit(repository)..tickStreak(),
        child: MaterialApp(
          title: 'PhonicsPals',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
