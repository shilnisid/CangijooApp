import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cangijoo/app/routes/app_pages.dart'; // Pastikan path ini benar

class SignupController extends GetxController {
  // --- Controllers & Instances ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // --- State Variables (Observables) ---
  final isPasswordVisible = false.obs;
  final isLoading = false.obs; // Untuk menampilkan loading indicator di UI

  /// Metode utama untuk menangani seluruh proses registrasi.
  /// Ini mencakup validasi, pengecekan email, pembuatan pengguna, dan penyimpanan data.
  Future<void> signup() async {
    // Tampilkan loading indicator
    isLoading.value = true;

    // --- 1. Validasi Input Pengguna ---
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', "Semua kolom wajib diisi.");
      isLoading.value = false;
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', "Konfirmasi password tidak cocok.");
      isLoading.value = false;
      return;
    }

    try {
      // --- 2. Buat pengguna baru di Firebase Auth ---
      // Note: Firebase will automatically handle duplicate email validation
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --- 3. Simpan informasi pengguna ke Firestore (TANPA PASSWORD) ---
      if (userCredential.user != null) {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // Menyimpan waktu pembuatan akun
        });
      }

      // Clear form fields after successful registration
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      Get.snackbar(
        'Sukses',
        'Akun berhasil dibuat! Silakan login.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.LOGIN);
    } on FirebaseAuthException catch (e) {
      // --- 4. Tangani error spesifik dari Firebase Auth ---
      String errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password yang Anda masukkan terlalu lemah.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email yang Anda masukkan tidak valid.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email ini sudah terdaftar. Silakan gunakan email lain.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operasi tidak diizinkan. Hubungi administrator.';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }
      Get.snackbar('Registrasi Gagal', errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      // --- 5. Tangani error umum lainnya ---
      Get.snackbar('Error', 'Terjadi kesalahan tak terduga.',
          backgroundColor: Colors.red, colorText: Colors.white);
      print('Signup error: $e'); // Untuk proses debugging dengan konteks yang lebih jelas
    } finally {
      // Hentikan loading indicator apa pun hasilnya
      isLoading.value = false;
    }
  }

  /// Mengubah visibilitas password di kolom input.
  void handleShowPassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    // Membersihkan controller untuk mencegah memory leak
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}