import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cangijoo/app/routes/app_pages.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 80,
                width: 250,
              ),
              const Gap(20),

              // Email Field
              Container(
                height: 55,
                width: 310,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xA56FCF97)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration.collapsed(hintText: "Email"),
                ),
              ),
              const Gap(16),

              // Password Field
              Container(
                height: 55,
                width: 310,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xA56FCF97)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () => TextFormField(
                    textInputAction: TextInputAction.done,
                    obscureText: !controller.isPasswordVisible.value,
                    controller: controller.passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      isCollapsed: true,
                      suffixIcon: IconButton(
                        onPressed: controller.handleShowPassword,
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(16),

              // Confirm Password Field
              Container(
                height: 55,
                width: 310,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xA56FCF97)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () => TextFormField(
                    textInputAction: TextInputAction.done,
                    obscureText: !controller.isPasswordVisible.value,
                    controller: controller.confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: InputBorder.none,
                      isCollapsed: true,
                      suffixIcon: IconButton(
                        onPressed: controller.handleShowPassword,
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(26),

              // Sign Up Button
              Obx(
                () => Container(
                  height: 50,
                  width: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed:
                        controller.isLoading.value ? null : controller.signup,
                    style: TextButton.styleFrom(
                      backgroundColor: controller.isLoading.value
                          ? Colors.grey[400]
                          : Colors.lightGreen[500],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
              const Gap(20),

              // Login Link
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: Colors.lightGreen[600],
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.offAndToNamed(Routes.LOGIN),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
