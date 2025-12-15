import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSupplierController extends GetxController {
  // --- Firebase Instance ---
  final FirebaseFirestore db = FirebaseFirestore.instance;
  
  // --- Controllers ---
  late final TextEditingController namaSupplierController;
  late final TextEditingController nomorSupplierController;
  
  // --- State Variables ---
  final isLoading = false.obs;

  /// Menambahkan supplier baru ke Firestore
  Future<void> addSupplier() async {
    final supplierName = namaSupplierController.text.trim();
    final supplierNumber = nomorSupplierController.text.trim();
    
    // Validasi input
    if (supplierName.isEmpty || supplierNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan nomor supplier tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Validasi format nomor telepon Indonesia
    if (!_isValidIndonesianPhoneNumber(supplierNumber)) {
      Get.snackbar(
        'Error',
        'Format nomor telepon tidak valid. Masukkan nomor tanpa 0 di depan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Set loading state
    isLoading.value = true;
    
    try {
      CollectionReference supplier = db.collection('supplier');
      
      // Format nomor untuk penyimpanan (tanpa +62)
      final formattedNumber = supplierNumber.startsWith('8') 
          ? supplierNumber 
          : supplierNumber.replaceFirst(RegExp(r'^0+'), '');
      
      await supplier.add({
        'supplierName': supplierName,
        'supplierNumber': formattedNumber, // Simpan tanpa +62
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Clear form
      namaSupplierController.clear();
      nomorSupplierController.clear();
      
      // Tampilkan snackbar sukses
      Get.snackbar(
        'Berhasil!',
        'Supplier "$supplierName" berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

// Navigate back setelah delay
      await Future.delayed(const Duration(milliseconds: 1000));
      Get.back();
      
      // Navigate back
      Get.back();
      
    } catch (e) {
      print('Error adding supplier: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan supplier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validasi nomor telepon Indonesia
  bool _isValidIndonesianPhoneNumber(String phoneNumber) {
    // Hapus semua karakter non-digit
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Cek panjang nomor (minimal 10, maksimal 13 digit untuk nomor Indonesia)
    if (digitsOnly.length < 10 || digitsOnly.length > 13) {
      return false;
    }
    
    // Cek apakah dimulai dengan 8 (setelah +62) atau 08
    return digitsOnly.startsWith('8') || digitsOnly.startsWith('08');
  }

  @override
  void onInit() {
    namaSupplierController = TextEditingController();
    nomorSupplierController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    namaSupplierController.dispose();
    nomorSupplierController.dispose();
    super.onClose();
  }
}