import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/core/widgets/mainbutton.dart';
import 'package:flutter_application_3/features/auth/cubit/cubit/user_auth_cubit.dart';
import 'package:flutter_application_3/features/auth/ui/signup_screen.dart';
import 'package:flutter_application_3/features/auth/ui/widget/textfield.dart';
import 'package:flutter_application_3/features/home/ui/screen/upload_podcast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SinginScreen extends StatefulWidget {
  const SinginScreen({super.key});

  @override
  State<SinginScreen> createState() => _SinginScreenState();
}

late TextEditingController emailcontroller;
late TextEditingController passwordcontroller;
final mykey = GlobalKey<FormState>();

class _SinginScreenState extends State<SinginScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    emailcontroller.dispose();
    passwordcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: BlocConsumer<UserAuthCubit, UserAuthState>(
          listener: (context, state) {
            if (state is UserAuthFailed) {
              print(state.errormessage);
            } else if (state is UserAuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const UploadPodcast(), // Your SignIn screen
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: mykey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150.h,
                      ),
                      Text(
                        'login',
                        style: AppTextStyles.darkHeadline1,
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      MyTextFormField(
                        hinttext: "email",
                        labletext: "email",
                        controller: emailcontroller,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      MyTextFormField(
                        controller: passwordcontroller,
                        hinttext: "password",
                        labletext: "password",
                        obscuretext: true,
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      if (state is UserAuthIsLoading)
                        const CircularProgressIndicator()
                      else
                        AppButton(
                          text: "sign in",
                          function: () {
                            if (mykey.currentState!.validate()) {
                              BlocProvider.of<UserAuthCubit>(context).login(
                                  emailcontroller.text.trim(),
                                  passwordcontroller.text.trim());
                            }
                          },
                        ),
                      SizedBox(
                        height: 15.h,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Already have an account?",
                            style: AppTextStyles.darkBodyText1),
                        TextSpan(
                            text: " Signup",
                            style: GoogleFonts.roboto(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gradientStart,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate to another screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen(), // Your SignIn screen
                                  ),
                                );
                              })
                      ]))
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      )),
    );
  }
}
