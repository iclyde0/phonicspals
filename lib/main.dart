import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/audio/phonics_audio_service.dart';
import 'core/utils/hive_boxes.dart';
import 'features/progress/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Hive.initFlutter();
  final progressBox = await Hive.openBox(HiveBoxes.progress);
  await Hive.openBox(HiveBoxes.settings);

  final audio = PhonicsAudioService();
  await audio.init();

  runApp(
    PhonicsPalsApp(
      repository: ProgressRepository(progressBox),
      audio: audio,
    ),
  );
}
