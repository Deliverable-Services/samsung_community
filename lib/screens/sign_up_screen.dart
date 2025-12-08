import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:samsung_community/components/custom_input_field.dart';
import 'package:samsung_community/constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  _buildHeaderSection(context),
                  const SizedBox(height: 73),
                  _buildFormSection(),
                  const SizedBox(height: 73),
                  _buildActionsSection(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'asset/images/logo.png',
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
                text: 'Welcome to our high\n',
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
          'To sign up for the app, please fill in the following details.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rubik',
            letterSpacing: 0.0,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildInputField(
            label: 'Mobile Number',
            controller: _mobileController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Password',
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return CustomInputField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      placeholder: label,
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 350,
          height: 48,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 7.86,
                sigmaY: 7.86,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.navGradientStartActive,
                      AppColors.navGradientEndActive,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.navBorderActive.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 7.43),
                      blurRadius: 16.6,
                      color: AppColors.buttonShadow,
                    ),
                    BoxShadow(
                      offset: Offset(0, 30.15),
                      blurRadius: 30.15,
                      color: AppColors.buttonShadowMedium,
                    ),
                    BoxShadow(
                      offset: Offset(0, 68.16),
                      blurRadius: 41.07,
                      color: AppColors.buttonShadowLight,
                    ),
                    BoxShadow(
                      offset: Offset(0, 121.02),
                      blurRadius: 48.5,
                      color: AppColors.buttonShadowExtraLight,
                    ),
                    BoxShadow(
                      offset: Offset(0, 189.18),
                      blurRadius: 52.87,
                      color: AppColors.shadowTransparent,
                    ),
                  ],
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement sign up logic
                    debugPrint('Sign up pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      color: AppColors.white,
                      letterSpacing: 0.0,
                      shadows: [
                        Shadow(
                          color: AppColors.buttonShadow,
                          offset: Offset(0.0, 7.43),
                          blurRadius: 16.6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: RichText(
            textScaler: MediaQuery.of(context).textScaler,
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'I already have an account ',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: AppColors.linkBlue,
                    letterSpacing: 0.0,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: 'Log in',
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    color: AppColors.linkBlue,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pop();
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

