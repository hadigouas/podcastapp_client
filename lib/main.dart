import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/audio_player_service.dart';
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
  setupLocator();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.myapp.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<UserAuthCubit>(context).fetchAndHandleUserData();
    });
  }

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
          home: BlocBuilder<UserAuthCubit, UserAuthState>(
            builder: (context, state) {
              if (state is UserAuthIsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is UserAuthSuccess) {
                return const MyNavigationBar(
                  podcast: null,
                );
              } else if (state is UserAuthFailed) {
                return const SignupScreen();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        );
      },
    );
  }
}
