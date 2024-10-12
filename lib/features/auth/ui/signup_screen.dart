import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/core/widgets/mainbutton.dart';
import 'package:flutter_application_3/features/auth/cubit/cubit/user_auth_cubit.dart';
import 'package:flutter_application_3/features/auth/ui/login_screen.dart';
import 'package:flutter_application_3/features/auth/ui/widget/textfield.dart';
import 'package:flutter_application_3/features/home/ui/screen/upload_podcast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

late TextEditingController namecontroller;
late TextEditingController emailcontroller;
late TextEditingController passwordcontroller;
final mykey = GlobalKey<FormState>();

class _SignupScreenState extends State<SignupScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    namecontroller = TextEditingController();
    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    // final userdata = context.read<UserAuthCubit>().fetchAndHandleUserData();
    // print(userdata);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    namecontroller.dispose();
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
            if (state is UserAuthSuccess) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadPodcast(),
                  ));
            } else if (state is UserAuthFailed) {
              print(state.errormessage);
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
                        'Sign Up',
                        style: AppTextStyles.darkHeadline1,
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      MyTextFormField(
                        hinttext: "name",
                        labletext: "name",
                        controller: namecontroller,
                      ),
                      SizedBox(
                        height: 15.h,
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
                          text: "signup",
                          function: () {
                            if (mykey.currentState!.validate()) {
                              BlocProvider.of<UserAuthCubit>(context).signUp(
                                  namecontroller.text.trim(),
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
                            text: " Sign up",
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
                                        const SinginScreen(), // Your SignIn screen
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
