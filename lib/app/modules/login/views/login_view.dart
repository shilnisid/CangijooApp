import 'package:cangijoo/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cangijoo/app/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/images/logo.svg",
              height: 80, width: 250),
              const Gap(50),
              Container(
                height: 55,
                width: 310,
                padding: EdgeInsets.all(13),
                decoration:  BoxDecoration(
                  border: Border.all(color: Color(0xA56FCF97)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller : controller.emailController,
                  decoration: InputDecoration.collapsed(hintText: 'Email', border: InputBorder.none),
                ),
              ),
              Gap(16),
              Container(
                height: 55,
                width: 310,
                padding: EdgeInsets.all(13),
                decoration:  BoxDecoration(
                  border: Border.all(color: Color(0xA56FCF97)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx( ()=> TextFormField(
                    textInputAction: TextInputAction.done,
                    controller : controller.passwordController,
                    obscureText: !controller.isPasswordvisible.value,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        isCollapsed: true,
                        suffixIcon: IconButton(
                          onPressed: controller.handlingShowPassword,
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.remove_red_eye),
                        )
                    ),
                  ),
                ),
              ),
              Gap(20),
              Text.rich(
                TextSpan ( children: [
                  TextSpan(text: 'Forgot Password? '),
                  TextSpan(
                    text: 'Reset Password',
                    style: TextStyle(
                      color: Colors.lightGreen[600],
                      fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.toNamed(Routes.RESET_PASS)),
                ]),
              ),
              Gap(30),
              Container(
                height: 50,
                width: 190,
                padding: EdgeInsets.zero,
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(40)),
                child: TextButton(
                  onPressed: ()  {

                    controller.login();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightGreen[500],
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Gap(20),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: "Don't have an account? " ''),
                  TextSpan(
                      text: 'Sign up',
                      style: TextStyle(
                          color: Colors.lightGreen[600],
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.offAndToNamed(Routes.SIGNUP)),
                ]),
              ),
              Gap(20),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: "-----or with Sign in with-----"),
                ]),
              ),
              Gap(20),
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 184,
                //padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.white,
                    border: Border.all(color: Colors.black)),
                child: TextButton(
                    onPressed: () {
                      controller.signInWithGoogle();
                    },
                    child:
                    SvgPicture.asset("assets/images/android_light_rd_SI.svg",  fit: BoxFit.none, )
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
