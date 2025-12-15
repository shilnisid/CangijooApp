import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddProdukDetailController extends GetxController {
  FirebaseFirestore db = FirebaseFirestore.instance;

  
  static final DateFormat _dateFormat = DateFormat.jm().add_yMMMd();

  
  String get diupdate => _dateFormat.format(DateTime.now().toLocal());

  
  String get expired => _dateFormat.format(
    DateTime.now().add(const Duration(days: 30)).toLocal(),
  );

  
  late TextEditingController namaProduk;
  late TextEditingController komposisiNama;
  late TextEditingController komposisiJumlah;
  late TextEditingController komposisiSatuan;

  
  late FocusNode namaProdukFocus;
  late FocusNode komposisiNamaFocus;
  late FocusNode komposisiJumlahFocus;
  late FocusNode komposisiSatuanFocus;

  
  final RxList<Map<String, dynamic>> listKomposisi = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs; 

  @override
  void onInit() {
    
    namaProduk = TextEditingController();
    komposisiNama = TextEditingController();
    komposisiJumlah = TextEditingController();
    komposisiSatuan = TextEditingController();

    
    namaProdukFocus = FocusNode();
    komposisiNamaFocus = FocusNode();
    komposisiJumlahFocus = FocusNode();
    komposisiSatuanFocus = FocusNode();

    super.onInit();
  }

  @override
  void onClose() {
    
    namaProduk.dispose();
    komposisiNama.dispose();
    komposisiJumlah.dispose();
    komposisiSatuan.dispose();

    
    namaProdukFocus.dispose();
    komposisiNamaFocus.dispose();
    komposisiJumlahFocus.dispose();
    komposisiSatuanFocus.dispose();

    super.onClose();
  }

  
  String? validateNamaProduk(String nama) {
    final trimmedNama = nama.trim();
    if (trimmedNama.isEmpty) {
      return 'Nama produk tidak boleh kosong';
    }
    if (trimmedNama.length > 50) {
      return 'Nama produk maksimal 50 karakter';
    }
    return null;
  }

  String? validateNamaBahan(String nama) {
    final trimmedNama = nama.trim();
    if (trimmedNama.isEmpty) {
      return 'Nama bahan tidak boleh kosong';
    }
    if (trimmedNama.length > 30) {
      return 'Nama bahan maksimal 30 karakter';
    }
    return null;
  }

  String? validateJumlah(String jumlahText) {
    if (jumlahText.trim().isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    final jumlah = double.tryParse(jumlahText.trim());
    if (jumlah == null || jumlah <= 0) {
      return 'Jumlah harus berupa angka positif';
    }
    return null;
  }

  String? validateSatuan(String satuan) {
    final trimmedSatuan = satuan.trim();
    if (trimmedSatuan.isEmpty) {
      return 'Satuan tidak boleh kosong';
    }
    if (trimmedSatuan.length > 10) {
      return 'Satuan maksimal 10 karakter';
    }
    return null;
  }

  
  void tambahBahanFromUI() {
    final nama = komposisiNama.text.trim();
    final jumlahText = komposisiJumlah.text.trim();
    final satuan = komposisiSatuan.text.trim();

    
    final namaError = validateNamaBahan(nama);
    if (namaError != null) {
      showErrorSnackbar(namaError);
      komposisiNamaFocus.requestFocus();
      return;
    }

    final jumlahError = validateJumlah(jumlahText);
    if (jumlahError != null) {
      showErrorSnackbar(jumlahError);
      komposisiJumlahFocus.requestFocus();
      return;
    }

    final satuanError = validateSatuan(satuan);
    if (satuanError != null) {
      showErrorSnackbar(satuanError);
      komposisiSatuanFocus.requestFocus();
      return;
    }

    
    final jumlah = double.parse(jumlahText);
    final jumlahFinal = jumlah % 1 == 0 ? jumlah.toInt() : jumlah;

    tambahKomposisi(nama, jumlahFinal, satuan);
  }

  void simpanProdukFromUI() {
    final namaProdukInput = namaProduk.text.trim();

    final namaError = validateNamaProduk(namaProdukInput);
    if (namaError != null) {
      showErrorSnackbar(namaError);
      namaProdukFocus.requestFocus();
      return;
    }

    if (listKomposisi.isEmpty) {
      showErrorSnackbar('Komposisi tidak boleh kosong. Tambahkan minimal 1 bahan.');
      return;
    }

    
    showConfirmationDialog(
      title: "Konfirmasi Simpan",
      message: "Simpan produk '$namaProdukInput'?\nKomposisi: ${listKomposisi.length} bahan",
      onConfirm: () {
        Get.back(); 
        addProdukDetail(namaProdukInput);
      },
    );
  }

  void resetFormFromUI() {
    showConfirmationDialog(
      title: "Reset Form",
      message: "Yakin ingin menghapus semua data yang telah diisi?",
      onConfirm: () {
        resetKomposisi();
        Get.back();
      },
      buttonColor: Colors.orange,
    );
  }

  void resetKomposisiFromUI() {
    showConfirmationDialog(
      title: "Reset Komposisi",
      message: "Yakin ingin menghapus semua komposisi?",
      onConfirm: () {
        listKomposisi.clear();
        Get.back();
        showSuccessSnackbar('Komposisi berhasil direset');
      },
      buttonColor: Colors.red,
    );
  }

  void hapusBahanFromUI(int index, String namaBahan) {
    showConfirmationDialog(
      title: "Hapus Bahan",
      message: "Hapus '$namaBahan' dari komposisi?",
      onConfirm: () {
        hapusKomposisi(index);
        Get.back();
      },
      buttonColor: Colors.red,
      confirmText: "Hapus",
    );
  }

  
  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Input Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  
  void showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Ya",
    String cancelText = "Batal",
    Color buttonColor = Colors.green,
  }) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      onConfirm: onConfirm,
      onCancel: () => Get.back(),
      textConfirm: confirmText,
      textCancel: cancelText,
      confirmTextColor: Colors.white,
      buttonColor: buttonColor,
      cancelTextColor: Colors.grey.shade600,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleTextStyle: const TextStyle(fontSize: 14),
      radius: 8,
    );
  }

  
  int calculateTotalBahan(Map<String, dynamic> bahan) {
    final jumlahBahan = bahan['jumlah'] is int
        ? bahan['jumlah'] as int
        : (bahan['jumlah'] as double).round();
    return jumlahBahan; 
  }

  String formatJumlahBahan(dynamic jumlah) {
    if (jumlah is int) {
      return jumlah.toString();
    } else if (jumlah is double) {
      return jumlah % 1 == 0 ? jumlah.toInt().toString() : jumlah.toString();
    }
    return jumlah.toString();
  }

  
  void tambahKomposisi(String namaBahan, dynamic jumlah, String satuan) {
    final nama = namaBahan.trim();
    final satuanTrim = satuan.trim();

    if (nama.isEmpty) {
      Get.snackbar(
        "Input Error",
        "Nama bahan tidak boleh kosong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (jumlah <= 0) { 
      Get.snackbar(
        "Input Error",
        "Jumlah harus lebih dari 0",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (satuanTrim.isEmpty) {
      Get.snackbar(
        "Input Error",
        "Satuan tidak boleh kosong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    
    final isDuplicate = listKomposisi.any((item) =>
    item['namaBahan'].toString().toLowerCase() == nama.toLowerCase());
    if (isDuplicate) {
      Get.snackbar(
        "Duplikat",
        "Bahan '$nama' sudah ada di komposisi",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    listKomposisi.add({
      'namaBahan': nama,
      'jumlah': jumlah,
      'satuan': satuanTrim,
    });

    
    komposisiNama.clear();
    komposisiJumlah.clear();
    komposisiSatuan.clear();

    Get.snackbar(
      "Berhasil",
      "Bahan '$nama' ditambahkan ke komposisi",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void hapusKomposisi(int index) {
    if (index >= 0 && index < listKomposisi.length) {
      final nama = listKomposisi[index]['namaBahan'];
      listKomposisi.removeAt(index);
      Get.snackbar(
        "Berhasil",
        "Bahan '$nama' dihapus dari komposisi",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error",
        "Index tidak valid",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void resetKomposisi() {
    namaProduk.clear();
    listKomposisi.clear();

    
    komposisiNama.clear();
    komposisiJumlah.clear();
    komposisiSatuan.clear();

    Get.snackbar(
      "Reset",
      "Form berhasil direset",
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  
  Future<bool> checkStockAvailability(List<Map<String, dynamic>> komposisiList) async {
    try {
      for (final item in komposisiList) {
        final namaBahan = item['namaBahan'].toString();
        final jumlahButuh = (item['jumlah'] as num).toInt(); 

        final querySnapshot = await db
            .collection('bahanBaku')
            .where('namaBahan', isEqualTo: namaBahan)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 10));

        if (querySnapshot.docs.isEmpty) {
          Get.snackbar(
            "Bahan Tidak Ditemukan",
            "Bahan baku '$namaBahan' tidak ditemukan di database",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return false;
        }

        final data = querySnapshot.docs.first.data();
        final stok = (data['jumlah'] as num).toInt();

        if (stok < jumlahButuh) {
          Get.snackbar(
            "Stok Tidak Cukup",
            "Bahan: $namaBahan\nTersedia: $stok ${data['satuan'] ?? ''}\nDibutuhkan: $jumlahButuh ${item['satuan']}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          return false;
        }
      }
      return true;
    } on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Waktu habis saat mengecek stok. Periksa koneksi internet.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengecek stok: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  
  Future<void> updateBahanBaku(
      List<Map<String, dynamic>> komposisiList,
      {required bool isDecrement}
      ) async {
    final batch = db.batch();

    try {
      for (final item in komposisiList) {
        final namaBahan = item['namaBahan'].toString();
        final jumlahPakai = (item['jumlah'] as num).toInt(); 

        final querySnapshot = await db
            .collection('bahanBaku')
            .where('namaBahan', isEqualTo: namaBahan)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 10));

        if (querySnapshot.docs.isEmpty) {
          throw Exception("Bahan baku '$namaBahan' tidak ditemukan");
        }

        final docRef = querySnapshot.docs.first.reference;
        final currentData = querySnapshot.docs.first.data();
        final currentStock = (currentData['jumlah'] as num).toInt();

        
        final newStock = isDecrement
            ? currentStock - jumlahPakai
            : currentStock + jumlahPakai;

        if (newStock < 0) {
          throw Exception("Stok tidak cukup untuk bahan '$namaBahan'. Stok saat ini: $currentStock, dibutuhkan: $jumlahPakai");
        }

        batch.update(docRef, {
          'jumlah': newStock,
          'diubah': diupdate,
        });
      }

      await batch.commit(); 
    } catch (e) {
      throw Exception("Gagal memperbarui stok bahan baku: ${e.toString()}");
    }
  }

  
  Future<void> addProdukDetail(String namaProdukInput) async {
    if (isLoading.value) return; 

    final nama = namaProdukInput.trim();

    
    if (nama.isEmpty) {
      Get.snackbar(
        "Error",
        "Nama produk tidak boleh kosong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (listKomposisi.isEmpty) {
      Get.snackbar(
        "Error",
        "Komposisi produk tidak boleh kosong",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      
      final existingProduct = await db
          .collection('produk')
          .where('namaProduk', isEqualTo: nama)
          .limit(1)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        Get.snackbar(
          "Duplikat",
          "Produk dengan nama '$nama' sudah ada",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      
      if (!await checkStockAvailability(listKomposisi)) {
        return;
      }

      
      final Map<String, dynamic> komposisiMap = {};
      for (int i = 0; i < listKomposisi.length; i++) {
        final bahan = listKomposisi[i];

        komposisiMap['bahan${i + 1}'] = {
          'namaBahan': bahan['namaBahan'],
          'jumlah': bahan['jumlah'],
          'satuan': bahan['satuan'],
        };
      }

      
      await db.collection('produk').add({
        'namaProduk': nama,
        'komposisiProduk': komposisiMap,
        'jumlah': 1, 
        'satuan': 'pcs',
        'dibuat': diupdate,
        'diubah': diupdate,
        'expired': expired,
      });

      
      await updateBahanBaku(listKomposisi, isDecrement: true);

      
      resetKomposisi();

      
      Get.defaultDialog(
        title: "Berhasil",
        middleText: "Produk '$nama' berhasil ditambahkan!",
        onConfirm: () {
          Get.back(); 
          Get.back(); 
        },
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: Colors.green,
      );
    } catch (e) {
      print("Error menambahkan produk: $e");
      Get.defaultDialog(
        title: "Gagal",
        middleText: "Gagal menambahkan produk:\n${e.toString()}",
        textConfirm: "Tutup",
        onConfirm: () => Get.back(),
        buttonColor: Colors.red,
        confirmTextColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> deleteProdukDetail(String produkId) async {
    if (produkId.isEmpty) {
      Get.snackbar(
        "Error",
        "ID produk tidak valid",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final docSnapshot = await db
          .collection('produk')
          .doc(produkId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!docSnapshot.exists) {
        throw Exception("Produk tidak ditemukan");
      }

      final data = docSnapshot.data()!;
      
      final komposisiMap = data['komposisiProduk'] as Map<String, dynamic>? ?? {};

      
      final List<Map<String, dynamic>> komposisiList = komposisiMap.values
          .map((e) => {
        'namaBahan': e['namaBahan'] ?? e['nama'],
        'jumlah': (e['jumlah'] as num).toInt(), 
        'satuan': e['satuan'],
      })
          .cast<Map<String, dynamic>>()
          .toList();

      
      await updateBahanBaku(komposisiList, isDecrement: false);

      
      await db.collection('produk').doc(produkId).delete();

      Get.defaultDialog(
        title: "Berhasil",
        middleText: "Produk berhasil dihapus dan stok bahan baku telah dikembalikan.",
        onConfirm: () {
          Get.back(); 
          Get.back(); 
        },
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: Colors.green,
      );
    } catch (e) {
      print("Error menghapus produk: $e");
      Get.defaultDialog(
        title: "Gagal",
        middleText: "Gagal menghapus produk:\n${e.toString()}",
        textConfirm: "Tutup",
        onConfirm: () => Get.back(),
        buttonColor: Colors.red,
        confirmTextColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<Map<String, dynamic>> getBahanBakuData(String namaBahan) async {
    try {
      final querySnapshot = await db
          .collection('bahanBaku')
          .where('namaBahan', isEqualTo: namaBahan)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Bahan baku '$namaBahan' tidak ditemukan");
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      throw Exception("Gagal mengambil data bahan baku '$namaBahan': ${e.toString()}");
    }
  }
}