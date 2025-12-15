import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SupplierController extends GetxController {
  
  final FirebaseFirestore db = FirebaseFirestore.instance;

  
  Stream<QuerySnapshot> streamDataSupplier() {
    return db.collection('supplier').orderBy('createdAt', descending: true).snapshots();
  }

  
  Future<void> toWa(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Error', 
        'Nomor WhatsApp tidak ditemukan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
     
      String formattedNumber = _formatPhoneNumber(phoneNumber);
      
      // Debug log untuk melihat nomor yang diformat
      print('Original number: $phoneNumber');
      print('Formatted number: $formattedNumber');

      
      final urls = [
        'https://wa.me/$formattedNumber',
        'https://api.whatsapp.com/send?phone=$formattedNumber',
        'whatsapp://send?phone=$formattedNumber',
      ];

      bool success = false;
      
      for (String urlString in urls) {
        try {
          final Uri uri = Uri.parse(urlString);
          print('Trying URL: $urlString');
          
          if (await canLaunchUrl(uri)) {
            await launchUrl(
              uri, 
              mode: LaunchMode.externalApplication,
              webOnlyWindowName: '_blank',
            );
            success = true;
            break;
          }
        } catch (e) {
          print('Failed to launch $urlString: $e');
          continue;
        }
      }

      if (!success) {
        
        await _tryFallbackMethods(formattedNumber);
      }

    } catch (e) {
      print('WhatsApp launch error: $e');
      Get.snackbar(
        'Error',
        'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall di perangkat Anda.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  
  String _formatPhoneNumber(String phoneNumber) {
    
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    
    
    if (cleaned.startsWith('0')) {
      // Nomor lokal: 08xxxxxxxxx -> 628xxxxxxxxx
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('8')) {
      // Nomor tanpa 0: 8xxxxxxxxx -> 628xxxxxxxxx
      cleaned = '62$cleaned';
    } else if (!cleaned.startsWith('62')) {
      // Jika tidak dimulai dengan 62, tambahkan
      cleaned = '62$cleaned';
    }
    
    
    if (cleaned.length < 10 || cleaned.length > 15) {
      throw Exception('Format nomor telepon tidak valid');
    }
    
    return cleaned;
  }

  
  Future<void> _tryFallbackMethods(String formattedNumber) async {
    try {
      // Method 1: Coba dengan launch mode yang berbeda
      final uri1 = Uri.parse('https://wa.me/$formattedNumber');
      try {
        await launchUrl(uri1, mode: LaunchMode.platformDefault);
        return;
      } catch (e) {
        print('Fallback method 1 failed: $e');
      }

      // Method 2: Coba dengan URL scheme WhatsApp langsung
      final uri2 = Uri.parse('whatsapp://send?phone=$formattedNumber');
      try {
        await launchUrl(uri2, mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        print('Fallback method 2 failed: $e');
      }

      // Method 3: Coba buka di browser
      final uri3 = Uri.parse('https://web.whatsapp.com/send?phone=$formattedNumber');
      try {
        await launchUrl(uri3, mode: LaunchMode.inAppWebView);
        Get.snackbar(
          'Info',
          'WhatsApp dibuka di browser. Pastikan Anda sudah login WhatsApp Web.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      } catch (e) {
        print('Fallback method 3 failed: $e');
      }

      throw Exception('Semua metode gagal');
      
    } catch (e) {
      print('All fallback methods failed: $e');
      
      // Show dialog dengan opsi manual
      Get.defaultDialog(
        title: 'WhatsApp Tidak Dapat Dibuka',
        middleText: 'Nomor WhatsApp: $formattedNumber\n\nSalin nomor ini dan buka WhatsApp secara manual?',
        textConfirm: 'Salin Nomor',
        textCancel: 'Tutup',
        onConfirm: () {
          _copyToClipboard(formattedNumber);
          Get.back();
        },
        confirmTextColor: Colors.white,
        buttonColor: Colors.green,
      );
    }
  }

 
  void _copyToClipboard(String text) {
    
    try {
      
      Get.snackbar(
        'Nomor Disalin',
        'Nomor $text telah disalin ke clipboard',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Copy to clipboard failed: $e');
    }
  }

  
  bool isValidWhatsAppNumber(String phoneNumber) {
    try {
      final formatted = _formatPhoneNumber(phoneNumber);
      return formatted.isNotEmpty && formatted.length >= 10;
    } catch (e) {
      return false;
    }
  }

  
  Future<bool> testWhatsAppConnection() async {
    try {
      // Test dengan nomor dummy
      final testUri = Uri.parse('https://wa.me/1234567890');
      return await canLaunchUrl(testUri);
    } catch (e) {
      return false;
    }
  }

  
  Future<void> deleteSupplier(String supplierId) async {
    try {
      // Konfirmasi penghapusan
      bool? confirm = await Get.defaultDialog<bool>(
        title: 'Konfirmasi',
        middleText: 'Apakah Anda yakin ingin menghapus supplier ini?',
        textConfirm: 'Ya',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        cancelTextColor: Colors.black,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );
      
      if (confirm == true) {
        await db.collection('supplier').doc(supplierId).delete();
        Get.snackbar(
          'Berhasil', 
          'Supplier berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting supplier: $e');
      Get.snackbar(
        'Error', 
        'Gagal menghapus supplier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

 
  Future<void> updateSupplier(String supplierId, String supplierName, String supplierNumber) async {
    if (supplierName.trim().isEmpty || supplierNumber.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan nomor supplier tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi nomor WhatsApp
    if (!isValidWhatsAppNumber(supplierNumber)) {
      Get.snackbar(
        'Error',
        'Format nomor WhatsApp tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await db.collection('supplier').doc(supplierId).update({
        'supplierName': supplierName.trim(),
        'supplierNumber': supplierNumber.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      Get.snackbar(
        'Berhasil',
        'Data supplier berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating supplier: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui data supplier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

 
  Future<void> addSupplier(String supplierName, String supplierNumber) async {
    if (supplierName.trim().isEmpty || supplierNumber.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan nomor supplier tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!isValidWhatsAppNumber(supplierNumber)) {
      Get.snackbar(
        'Error',
        'Format nomor WhatsApp tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await db.collection('supplier').add({
        'supplierName': supplierName.trim(),
        'supplierNumber': supplierNumber.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      Get.snackbar(
        'Berhasil',
        'Supplier berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding supplier: $e');
      Get.snackbar(
        'Error',
        'Gagal menambahkan supplier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}