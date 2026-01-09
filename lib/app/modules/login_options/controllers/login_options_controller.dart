import 'dart:async';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_pages.dart';
import '../../on_boarding/controllers/on_boarding_controller.dart';

class LoginOptionsController extends GetxController {
  //TODO: Implement LoginOptionsController

  final count = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void clickOnSignUpWithGoogleButton1() async {
    final supabase = Supabase.instance.client;

    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '420519811486-vrrntteo6nbh4kbrocl4ogk3u8v2bctc.apps.googleusercontent.com';
    const iosClientId = 'my-ios.apps.googleusercontent.com';
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize(clientId: iosClientId, serverClientId: webClientId),
    );
    final googleAccount = await signIn.authenticate();
    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    userData.value = {
      'id': googleAccount.id,
      'email': googleAccount.email,
      'name': googleAccount.displayName,
      'photoUrl': googleAccount.photoUrl,
    };

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    Get.toNamed(Routes.SIGN_UP);
  }
}
