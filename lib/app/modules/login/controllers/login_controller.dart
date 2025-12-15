import 'package:get/get.dart';
import 'package:cangijoo/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  Stream<User?> get streamAuth => auth.authStateChanges();

  var isPasswordvisible = false.obs;

  void handlingShowPassword() {
    isPasswordvisible.value = !isPasswordvisible.value;
  }

  void signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      // Initialize jika diperlukan
      await googleSignIn.initialize();
      
      // Authenticate user - ini satu-satunya langkah yang diperlukan
      final GoogleSignInAccount? account = await googleSignIn.authenticate();

      if (account == null) {
        return; // user cancelled
      }

      // Dapatkan authentication untuk Firebase
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      
      );
      
      // Sign in ke Firebase
      final UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        final SharedPreferences gperfs = await SharedPreferences.getInstance();
        await gperfs.setString('google', user.email ?? '');
        Get.offAndToNamed(Routes.NAVBAR);
      }
      
    } catch (e) {
      Get.defaultDialog(
        title: 'Terjadi kesalahan',
        middleText: 'Gagal masuk dengan akun Google ⚠️',
      );
    }
  }

  Future<void> login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (emailController.text.isEmpty && passwordController.text.isNotEmpty) {
      Get.snackbar('Error', "Fiels can't empty!",
          backgroundColor: Colors.lightGreen[400]);
      return;
    }
    try {
      await auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      prefs.setString('email', 'emailController.text');
      Get.offAndToNamed(Routes.NAVBAR);
    } catch (e) {
      Get.snackbar('Account not found', 'Please check your email and password',
          backgroundColor: Colors.lightGreen[400], duration: 3.seconds);
    }
  }

  void checkAuthState() async {
    try {
      await Future.delayed(Duration(milliseconds: 50));
      final firebaseUser = auth.currentUser;
      if (firebaseUser != null) {
        Get.offAndToNamed(Routes.NAVBAR);
      }
    } catch (e) {
      print('Error checking auth state: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthState();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
