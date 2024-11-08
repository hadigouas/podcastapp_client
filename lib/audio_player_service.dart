import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
}
