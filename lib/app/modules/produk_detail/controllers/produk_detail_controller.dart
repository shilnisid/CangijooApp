import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../service/stock_service.dart';

class ProdukDetailController extends GetxController {
  final Logger _logger = Logger('ProdukDetailController');
  late SharedPreferences _prefs;
  final firestore = FirebaseFirestore.instance;
  final StockService _stockService = StockService();

  
  final RxMap<String, RxInt> jumlahProduk = <String, RxInt>{}.obs;
  final RxList<Map<String, dynamic>> komposisiList = <Map<String, dynamic>>[].obs;
  final RxString namaProduk = ''.obs;
  final RxString createdAt = ''.obs;
  final RxString lastModified = ''.obs;

  final RxBool isInitialized = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool _isUpdating = false.obs; 

  String productId = '';
  String satuan = 'gram';

  final numberFormat = NumberFormat.decimalPattern('id_ID');
  static const lastModifiedKey = 'last_modified_';
  
  
  static const _invalidProductError = 'Data produk tidak valid';
  static const _emptyProductNameError = 'Nama produk kosong';
  static const _invalidProductIdError = 'Product ID tidak valid';
  static const _insufficientStockError = 'Stok tidak mencukupi';
  static const _timeoutError = 'Timeout saat mengambil data';
  
  
  final _bahanBakuCache = <String, Map<String, dynamic>>{};

  
  String _formatNow() =>
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(DateTime.now().toLocal());

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    if (args == null || args['namaProduk'] == null) {
      _showSnackbar('Error', _invalidProductError);
      Get.back();
      return;
    }

    Future.microtask(() async {
      try {
        _prefs = await SharedPreferences.getInstance();
        await initializeDateFormatting('id_ID');
        await initializeController(args);
      } catch (e) {
        _logger.severe('Init error: $e', e);
        _showSnackbar('Error', 'Gagal inisialisasi: ${_getErrorMessage(e)}');
        Get.back();
      }
    });
  }

  Future<void> initializeController(Map<String, dynamic> args) async {
    try {
      namaProduk.value = args['namaProduk']?.toString() ?? '';
      productId = args['productId']?.toString() ?? '';
      satuan = args['satuan']?.toString() ?? 'gram';

      if (namaProduk.isEmpty) throw Exception(_emptyProductNameError);
      if (productId.isEmpty) throw Exception(_invalidProductIdError);

      // PERBAIKAN: Load komposisi langsung dari database, bukan dari arguments
      await loadKomposisiFromDatabase();

      await loadJumlahProduk();

      if (!jumlahProduk.containsKey(productId)) {
        jumlahProduk[productId] = RxInt(args['jumlah'] as int? ?? 0);
      }

      
      final doc = await firestore.collection('produk').doc(productId).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        createdAt.value = data['dibuat']?.toString() ?? _formatNow();
        lastModified.value = data['diubah']?.toString() ?? _formatNow();
      }

      isInitialized.value = true;
      _logger.info('Controller siap untuk ${namaProduk.value}');
    } catch (e) {
      _logger.severe('Initialization error: $e', e);
      _showSnackbar('Error', 'Gagal inisialisasi: ${_getErrorMessage(e)}');
      rethrow;
    }
  }

  // PERBAIKAN: Method baru untuk load komposisi dari database
  Future<void> loadKomposisiFromDatabase() async {
    try {
      _logger.info('Loading komposisi from database for productId: $productId');
      
      final doc = await firestore.collection('produk').doc(productId).get();
      
      if (!doc.exists) {
        throw Exception('Produk tidak ditemukan di database');
      }

      final data = doc.data() ?? {};
      final rawKomposisi = data['komposisiProduk'] as Map<String, dynamic>? ?? {};
      
      _logger.info('Raw komposisi dari database: $rawKomposisi');
      
      final bahanBakuList = <Map<String, dynamic>>[];

      // Process komposisi dengan validasi
      for (final entry in rawKomposisi.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          final namaBahan = value['namaBahan']?.toString() ?? '';
          final jumlah = value['jumlah'] ?? 0;
          final satuanBahan = value['satuan']?.toString() ?? satuan;
          
          if (namaBahan.isNotEmpty && jumlah > 0) {
            // Validasi bahwa bahan baku ada di database
            try {
              await getBahanBakuData(namaBahan);
              bahanBakuList.add({
                'namaBahan': namaBahan,
                'jumlah': jumlah,
                'satuan': satuanBahan,
              });
              _logger.info('Added bahan: $namaBahan, jumlah: $jumlah, satuan: $satuanBahan');
            } catch (e) {
              _logger.warning('Bahan baku $namaBahan tidak ditemukan di database: $e');
              // Lanjutkan proses, tapi beri peringatan
              _showSnackbar('Warning', 'Bahan baku $namaBahan tidak ditemukan di database bahan baku');
            }
          }
        }
      }

      komposisiList
        ..clear()
        ..addAll(bahanBakuList);
        
      _logger.info('Komposisi loaded: ${komposisiList.length} items');
      _logger.info('Komposisi detail: ${komposisiList.toList()}');
      
      if (komposisiList.isEmpty) {
        _logger.warning('Komposisi kosong setelah loading dari database');
        _showSnackbar('Warning', 'Komposisi produk kosong atau tidak valid');
      }
      
    } catch (e) {
      _logger.severe('Error loading komposisi from database: $e', e);
      _showSnackbar('Error', 'Gagal memuat komposisi: ${_getErrorMessage(e)}');
      rethrow;
    }
  }

  // PERBAIKAN: Method untuk reload komposisi jika diperlukan
  Future<void> refreshKomposisi() async {
    try {
      isLoading.value = true;
      await loadKomposisiFromDatabase();
      _showSnackbar('Berhasil', 'Komposisi berhasil dimuat ulang', isError: false);
    } catch (e) {
      _logger.severe('Error refreshing komposisi: $e', e);
      _showSnackbar('Error', 'Gagal memuat ulang komposisi: ${_getErrorMessage(e)}');
    } finally {
      isLoading.value = false;
    }
  }
  
  
  
  Future<void> incrementJumlahProduk() async {
    if (_isUpdating.value) {
      _logger.info('Update already in progress, skipping increment');
      return;
    }
    await _updateJumlahProduk(isIncrement: true);
  }

  Future<void> decrementJumlahProduk() async {
    if (_isUpdating.value) {
      _logger.info('Update already in progress, skipping decrement');
      return;
    }
    await _updateJumlahProduk(isIncrement: false);
  }

  
  
  
  Future<void> _updateJumlahProduk({required bool isIncrement}) async {
    if (productId.isEmpty) {
      _showSnackbar('Error', _invalidProductIdError);
      return;
    }

    
    if (_isUpdating.value) {
      _logger.info('Update already in progress, skipping');
      return;
    }

    final produkRx = jumlahProduk[productId] ??= 0.obs;

    if (!isIncrement && produkRx.value <= 0) {
      _showSnackbar('Error', 'Jumlah produk tidak boleh kurang dari 0');
      return;
    }

    // PERBAIKAN: Cek komposisi dan refresh jika kosong
    if (komposisiList.isEmpty) {
      _logger.warning('Komposisi kosong, mencoba reload dari database');
      try {
        await loadKomposisiFromDatabase();
        if (komposisiList.isEmpty) {
          _showSnackbar('Error', 'Komposisi produk kosong dan tidak dapat dimuat');
          return;
        }
      } catch (e) {
        _showSnackbar('Error', 'Gagal memuat komposisi produk');
        return;
      }
    }

    _isUpdating.value = true;
    isLoading.value = true;
    final oldJumlah = produkRx.value;
    final newJumlah = isIncrement ? oldJumlah + 1 : oldJumlah - 1;

    try {
      
      if (isIncrement && komposisiList.isNotEmpty) {
        final ok = await _validateBahanBakuStockForQuantity(1);
        if (!ok) {
          isLoading.value = false;
          _isUpdating.value = false;
          return;
        }
      }

      
      final produkRef = firestore.collection('produk').doc(productId);
      final now = _formatNow();

      await produkRef.update({'jumlah': newJumlah, 'diubah': now});
      await _prefs.setString(lastModifiedKey + productId, now);
      lastModified.value = now;

      
      
      
      try {
        await _updateBahanBakuBatch(
            isProdukDitambah: isIncrement, quantityMultiplier: 1);
      } catch (e) {
        
        _logger.warning('Stock update failed, rolling back product update: $e', e);
        try {
          final rollbackNow = _formatNow();
          await produkRef.update({'jumlah': oldJumlah, 'diubah': rollbackNow});
          await _prefs.setString(lastModifiedKey + productId, rollbackNow);
          lastModified.value = rollbackNow;
        } catch (rollbackErr) {
          _logger.severe('Rollback failed: $rollbackErr', rollbackErr);
        }
        rethrow;
      }

      
      produkRx.value = newJumlah;
      await saveJumlahProduk();

      _showSnackbar(
        'Berhasil',
        isIncrement
            ? 'Jumlah produk berhasil ditambah, stok bahan baku diperbarui'
            : 'Jumlah produk berhasil dikurangi, stok bahan baku dikembalikan',
        isError: false,
      );
    } catch (e) {
      _logger.severe('Update jumlah gagal: $e', e);
      
      jumlahProduk[productId]!.value = oldJumlah;
      _showSnackbar('Error', 'Gagal update produk: ${_getErrorMessage(e)}');
    } finally {
      isLoading.value = false;
      _isUpdating.value = false;
    }
  }

  
  
  
  
  
  
  
  Future<void> _updateBahanBakuBatch({
    required bool isProdukDitambah,
    required int quantityMultiplier,
  }) async {
    try {
      
      final usage = _stockService.calculateTotalUsage(
        komposisiList.toList(),
        quantityMultiplier,
      );

      
      
      final delta = <String, int>{};
      for (final entry in usage.entries) {
        delta[entry.key] = isProdukDitambah ? -entry.value : entry.value;
      }

      await _stockService.updateStockByDelta(delta);
      
      
      await _updateBahanBakuCache();
    } on TimeoutException {
      throw Exception('$_timeoutError bahan baku');
    } catch (e) {
      rethrow;
    }
  }

  
  
  
  
  Future<bool> _validateBahanBakuStockForQuantity(int quantity) async {
    if (komposisiList.isEmpty) return true;

    try {
      
      final usage = _stockService.calculateTotalUsage(
        komposisiList.toList(),
        quantity,
      );

      final lacking = <String>[];
      
      for (final entry in usage.entries) {
        final namaBahan = entry.key;
        final needed = entry.value;

        try {
          final bahanData = await getBahanBakuData(namaBahan);
          final currentStock = (bahanData['jumlah'] as num?)?.toInt() ?? 0;

          if (currentStock < needed) {
            lacking.add('$namaBahan (Stok: ${numberFormat.format(currentStock)}, Butuh: ${numberFormat.format(needed)})');
          }
        } catch (e) {
          lacking.add('$namaBahan (tidak ditemukan)');
        }
      }

      if (lacking.isNotEmpty) {
        final msg = '$_insufficientStockError:\n${lacking.join('\n')}';
        _showSnackbar('Stok Tidak Cukup', msg);
        return false;
      }

      return true;
    } catch (e) {
      _logger.warning('Validation error: $e', e);
      _showSnackbar('Error', 'Gagal validasi stok: ${_getErrorMessage(e)}');
      return false;
    }
  }

  
  
  
  Future<Map<String, dynamic>> getBahanBakuData(String namaBahan) async {
    
    if (_bahanBakuCache.containsKey(namaBahan)) {
      return _bahanBakuCache[namaBahan]!;
    }

    final snap = await firestore
        .collection('bahanBaku')
        .where('namaBahan', isEqualTo: namaBahan)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));

    if (snap.docs.isEmpty) throw Exception("Bahan $namaBahan tidak ditemukan");
    
    final data = snap.docs.first.data();
    _bahanBakuCache[namaBahan] = data; 
    return data;
  }

  
  
  
  
  Future<void> _updateBahanBakuCache() async {
    final bahanBakuNames = <String>[];
    for (final item in komposisiList) {
      final nama = item['namaBahan']?.toString() ?? '';
      if (nama.isNotEmpty) {
        bahanBakuNames.add(nama);
      }
    }

    if (bahanBakuNames.isEmpty) return;

    try {
      final querySnapshot = await firestore
          .collection('bahanBaku')
          .where('namaBahan', whereIn: bahanBakuNames)
          .get()
          .timeout(const Duration(seconds: 10));

      for (final doc in querySnapshot.docs) {
        final nama = doc.data()?['namaBahan']?.toString() ?? '';
        if (nama.isNotEmpty) {
          _bahanBakuCache[nama] = doc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      _logger.warning('Failed to update cache: $e', e);
    }
  }

  
  
  
  Future<void> loadJumlahProduk() async {
    try {
      if (productId.isEmpty) return;

      final prefs = _prefs;
      final doc = await firestore.collection('produk').doc(productId).get();

      final local = prefs.getInt('jumlahProduk_$productId');
      final remote = (doc.data()?['jumlah'] as num?)?.toInt() ?? 0;
      jumlahProduk[productId] = RxInt(local ?? remote);
      _logger.info('Loaded jumlah produk: ${jumlahProduk[productId]?.value}');
    } catch (e) {
      _logger.severe('Error loading jumlah produk: $e', e);
      Get.snackbar('Error', 'Gagal memuat data produk: ${_getErrorMessage(e)}');
    }
  }

  Future<void> saveJumlahProduk() async {
    try {
      if (productId.isEmpty) return;
      final val = jumlahProduk[productId]?.value ?? 0;
      await _prefs.setInt('jumlahProduk_$productId', val);
      _logger.info('Saved jumlah produk: $val');
    } catch (e) {
      _logger.severe('Error saving jumlah produk: $e', e);
      Get.snackbar('Error', 'Gagal menyimpan data produk: ${_getErrorMessage(e)}');
    }
  }

  
  
  
  Future<void> deleteProduk() async {
    _logger.info('=== DELETE PRODUK ===');

    if (productId.isEmpty) {
      _showSnackbar('Error', _invalidProductIdError);
      return;
    }

    
    if (_isUpdating.value) {
      _logger.info('Update already in progress, skipping delete');
      return;
    }

    _isUpdating.value = true;
    isLoading.value = true;
    try {
      final currentJumlahProduk = jumlahProduk[productId]?.value ?? 0;
      
      // PERBAIKAN: Pastikan komposisi loaded sebelum delete
      if (komposisiList.isEmpty) {
        await loadKomposisiFromDatabase();
      }
      
      final komposisiSaatIni = komposisiList.toList();

      if (currentJumlahProduk > 0 && komposisiSaatIni.isNotEmpty) {
        
        await _updateBahanBakuBatch(
            isProdukDitambah: false, quantityMultiplier: currentJumlahProduk);
      }

      
      await firestore.collection('produk').doc(productId).delete();

      
      jumlahProduk.remove(productId);
      await _prefs.remove('jumlahProduk_$productId');
      await _prefs.remove(lastModifiedKey + productId);

      _showSnackbar('Berhasil', 'Produk ${namaProduk.value} dihapus', isError: false);
      Get.back();
    } catch (e) {
      _logger.severe('Hapus produk gagal: $e', e);
      _showSnackbar('Error', 'Gagal hapus produk: ${_getErrorMessage(e)}');
    } finally {
      isLoading.value = false;
      _isUpdating.value = false;
    }
  }

  
  
  
  void _showSnackbar(String title, String message, {bool isError = true}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red[100] : Colors.lightGreen[100],
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  @override
  void onClose() {
    jumlahProduk.clear();
    komposisiList.clear();
    _bahanBakuCache.clear();
    isInitialized.value = false;
    _isUpdating.value = false;
    super.onClose();
  }
}