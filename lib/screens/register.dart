import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_services.dart';
import '../util/logo_tile.dart';
import '../util/my_button.dart';
import '../util/textwidget.dart';
import 'home_page.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final emailCont = TextEditingController();
  final passwordCont = TextEditingController();
  final confirmPassCont = TextEditingController();
  final phoneController =TextEditingController();
  final otpController =TextEditingController();

  final _formKey =GlobalKey<FormState>();

  void showCustomErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign-In Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {Navigator.of(context).pop();},
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    if (passwordCont.text == confirmPassCont.text){
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCont.text,
        password: passwordCont.text,
      );
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Password Mismatch'),
            content: const Text('The passwords do not match.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      UserCredential userCredential = await AuthServices().signInGoogle();
      Navigator.pop(context);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomErrorDialog(context, e.toString());
    }
  }

  void signInFB() async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential? userCredential = await AuthServices().signinFb();
      Navigator.pop(context);

      if (userCredential?.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomErrorDialog(context, e.toString());
    }
  }

  Future<void> signInGithub() async {
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCredential = await AuthServices().signInGithub();
      Navigator.pop(context);

      if (userCredential?.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomErrorDialog(context, e.toString());
    }
  }

  void mobileAuth() async {
    showDialog(context: context,
      builder: (context) =>
      AlertDialog(title: const Text("Phone Number Verification"),
        content: TextField(
        controller: phoneController,
        decoration: const InputDecoration(
          labelText: 'Enter phone number',
          border: OutlineInputBorder(),),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
           onPressed: () async {
             String phone = phoneController.text.trim();
             if (!phone.startsWith('+91')) {
               phone = '+91$phone';
             }
             await AuthServices().phoneAuth(
               phone: phone,
               nextStep: () {
                 Navigator.pop(context);
                 showDialog(
                   context: context,
                   builder: (context) =>
                       AlertDialog(title: const Text("OTP Verification"),
                         content: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Form(
                               key: _formKey,
                               child: TextFormField(
                                 controller: otpController,
                                 decoration: const InputDecoration(
                                   labelText: 'Enter 6 digit OTP',
                                   border: OutlineInputBorder(),
                                 ),
                                 validator: (value) {
                                   if (value == null ||
                                       value.length != 6) {return "Invalid OTP";}
                                        return null;
                                   },
                                 keyboardType: TextInputType.number,
                               ),
                             ),
                           ],
                         ),
                         actions: [
                           TextButton( onPressed: () {
                             if (_formKey.currentState!.validate()) {
                               AuthServices authServices = AuthServices();
                               authServices.loginWithOtp(otp: otpController.text).then((value) {
                                 if (value == 'Success') {
                                   Navigator.pop(context);
                                   Navigator.pushReplacement(context,
                                       MaterialPageRoute(builder: (context) => const HomePage()));
                                 } else {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
                                 }
                               });
                             }
                             },
                             child: const Text("Submit"),
                           ),
                         ],
                       ),
                 );},
             );},
            child: const Text("Submit"),
          ),],
      ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(106, 177, 255, 0.8862745098039215),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const Text(
                  "Welcome !",
                  style: TextStyle(
                    fontFamily: 'Times new Roman',
                    fontStyle: FontStyle.italic,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                    "-- Register --",
                    style: TextStyle(
                      fontFamily: 'Times new Roman',
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    )
                ),

                Textwidget(
                  controller: emailCont,
                  hintText: 'Email',
                  hiddenText: false,
                ),
                Textwidget(
                  controller: passwordCont,
                  hintText: 'Password',
                  hiddenText: true,
                ),
                Textwidget(
                  controller: confirmPassCont,
                  hintText: 'Confirm Password',
                  hiddenText: true,
                ),

                const SizedBox(height: 10,),
                MyButton(text: 'Sign Up', onPressed: registerUser,),
                const SizedBox(height: 10,),

                const Text(
                  'or continue with',
                  style: TextStyle(
                      color: Color.fromRGBO(12, 12, 106, 1.0)
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logoTile(path: 'lib/images/Google_logo.png', onTap: signInWithGoogle,),
                    const SizedBox(width: 16),
                    logoTile(path: 'lib/images/facebook_logo.webp', onTap: signInFB,),
                    const SizedBox(width: 16),
                    logoTile(path: 'lib/images/github_logo.png', onTap: signInGithub),
                    const SizedBox(width: 16),
                    logoTile(path: 'lib/images/mobile_logo.png', onTap: mobileAuth),
                  ],
                ),

                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){ Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );},
                    child: const Text( "Already an account ? Login Here !",
                      style: TextStyle(
                          color: Color.fromRGBO(12, 12, 106, 1.0),
                          fontSize: 16),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
