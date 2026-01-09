import 'dart:async';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userData = {}.obs;

class OnBoardingController extends GetxController {
  final count = 0.obs;

  void increment() => count.value++;

  void clickOnSignUpWithGoogleButton() async {
    final supabase = Supabase.instance.client;

    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '420519811486-vrrntteo6nbh4kbrocl4ogk3u8v2bctc.apps.googleusercontent.com';

    /// TODO: update the iOS client ID with your own.
    ///
    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId = 'my-ios.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    final GoogleSignIn signIn = GoogleSignIn.instance;

    // At the start of your app, initialize the GoogleSignIn instance
    unawaited(
      signIn.initialize(clientId: iosClientId, serverClientId: webClientId),
    );

    // Perform the sign in
    final googleAccount = await signIn.authenticate();
    // final googleAuthorization = await googleAccount.authorizationClient
    //     .authorizationForScopes([]);
    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    //final accessToken = googleAuthorization?.accessToken;

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
      //accessToken: accessToken,
    );
    Get.toNamed(Routes.SIGN_UP);
  }
}
