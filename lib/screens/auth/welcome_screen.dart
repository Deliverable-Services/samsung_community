import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:samsung_community/constants/app_colors.dart';

import '../../constants/app_button.dart';
import '../../constants/app_images.dart';
import '../../services/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 585,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(214, 214, 214, 0.1),
                                Color.fromRGBO(112, 112, 112, 0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              0,
                              100,
                              0,
                              0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                    24,
                                    0,
                                    24,
                                    0,
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      children: const [
                                        TextSpan(
                                          text: 'Welcome to our\n',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 26,
                                            letterSpacing: 0.0,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'S Community',
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 26,
                                            letterSpacing: 0.0,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    textScaler: MediaQuery.of(
                                      context,
                                    ).textScaler,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                const Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(24),
                                    ),
                                    child: Image(
                                      image: AssetImage(AppImages.appLogo),
                                      width: 266,
                                      height: 247,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 43),
                  const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(38, 0, 38, 0),
                    child: Text(
                      'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        letterSpacing: 0.0,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                  AppButton(
                    onTap: () => AppRoutes.go(AppRouteName.loginScreen),
                    text: 'Log in',
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "I don't have an account ",
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: AppColors.linkBlue,
                            letterSpacing: 0.0,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign up',
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            color: AppColors.linkBlue,
                            fontSize: 16,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              AppRoutes.go(AppRouteName.signUpScreen);
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 66),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
