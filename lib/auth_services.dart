import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  //Google
  signInGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  //Facebook
  Future<UserCredential?> signinFb() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if(result.status == LoginStatus.success){
      final  credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return null;
  }

  //Github
  Future<UserCredential> signInGithub() async {
    GithubAuthProvider githubAuthProvider =GithubAuthProvider();
    return await FirebaseAuth.instance.signInWithProvider(githubAuthProvider);
  }

  //Phone_Auth
  static String verifyId="";
  Future<void> phoneAuth({
    required String phone,
    required Function nextStep,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 30),
      verificationCompleted: (phoneAuthCredential) async {},
      verificationFailed: (error) async {return;},
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        nextStep();
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        verifyId = verificationId;
      },
    ).onError((error, stackTrace) => null);
  }
  Future<String> loginWithOtp({required String otp,}) async {
    final credential = PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);
    try {
      final user = await FirebaseAuth.instance.signInWithCredential(credential);
      if (user.user != null) {
        return "Success";
      } else {
        return "Failed to log in";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }
}