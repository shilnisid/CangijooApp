import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cangijoo/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPassController extends GetxController {
  // --- Controllers & Instances ---
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  // --- State Variables (Observables) ---
  final isLoading = false.obs;

  /// Mengirim email reset password ke alamat email yang diberikan
  Future<void> resetPass() async {
    final email = emailController.text.trim();
    
    // Validasi input
    if (email.isEmpty) {
      Get.snackbar(
        'Error', 
        'Email tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error', 
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Set loading state
    isLoading.value = true;

    try {
      await auth.sendPasswordResetEmail(email: email);
      
      Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Link reset password telah dikirim ke email Anda.',
        onConfirm: () {
          Get.back(); // Close dialog
          emailController.clear(); // Clear email field
          Get.offAndToNamed(Routes.LOGIN);
        },
        confirmTextColor: Colors.white,
        textConfirm: 'OK',
        buttonColor: Colors.green,
      );
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Gagal mengirim link reset password.';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar dalam sistem.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid.';
          break;
        case 'too-many-requests':
          errorMessage = 'Terlalu banyak permintaan. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          errorMessage = 'Koneksi internet bermasalah. Periksa koneksi Anda.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tak terduga.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Reset password error: $e'); // For debugging
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}