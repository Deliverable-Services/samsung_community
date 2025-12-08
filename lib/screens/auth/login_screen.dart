import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:samsung_community/constants/app_button.dart';
import 'package:samsung_community/services/app_routes.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../helper_widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          AppImages.appLogo,
                          width: 84,
                          height: 78,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text.rich(
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome to our \n',
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
                        textScaler: MediaQuery.of(context).textScaler,
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'To log in to the app, please fill in the following details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          letterSpacing: 0.0,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 73),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          label: 'Mobile Number',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 40),
                        CustomTextField(
                          label: 'Password',
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          placeholder: 'Password',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'I forgot my password.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: AppColors.linkBlue,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 73),

                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        onTap: () {
                          AppRoutes.go(AppRouteName.homeScreen);
                        },
                        text: 'Log in',
                        width: 200,
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return CustomTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      placeholder: label,
    );
  }
}
