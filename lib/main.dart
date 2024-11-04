import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/classes/shared_pref.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/features/auth/cubit/cubit/user_auth_cubit.dart';
import 'package:flutter_application_3/features/auth/repos/auth_repo.dart';
import 'package:flutter_application_3/features/auth/ui/signup_screen.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_cubit.dart';
import 'package:flutter_application_3/features/home/repo/podcast_repo.dart';
import 'package:flutter_application_3/navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause:
        true, // Optional: set to false if you want notification to stay when paused
  );
  await SharedPrefs.init();

  Dio mydio = Dio();
  AuthRepo authRepo = AuthImpl(dio: mydio);
  PodcastRepo podcastRepo = PodcastImpl(dio: mydio);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PodcastCubit(podcastRepo),
          child: Container(),
        ),
        BlocProvider(
          create: (context) =>
              UserAuthCubit(authRepo)..fetchAndHandleUserData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryColor: AppColors.lightPrimaryColor,
            scaffoldBackgroundColor: AppColors.lightBackgroundColor,
          ),
          darkTheme: ThemeData(
            primaryColor: AppColors.darkPrimaryColor,
            scaffoldBackgroundColor: AppColors.darkBackgroundColor,
          ),
          themeMode: ThemeMode.dark,
          home: BlocListener<UserAuthCubit, UserAuthState>(
              listener: (context, state) {
                if (state is UserAuthSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyNavigationBar(
                              audioPlayer: null,
                              podcast: null,
                            )),
                  );
                } else if (state is UserAuthFailed) {
                  // Navigate to SignupScreen if authentication fails
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()),
                  );
                }
              },
              child: const Center(
                  child: CircularProgressIndicator()) // Initial loading state

              ),
        );
      },
    );
  }
}
