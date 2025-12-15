import 'package:cloud_firestore/cloud_firestore.dart';

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Menghitung total penggunaan bahan baku berdasarkan jumlah produk dan komposisi
  Map<String, int> calculateTotalUsage(
    List<Map<String, dynamic>> komposisi,
    int jumlahProduk,
  ) {
    final usage = <String, int>{};
    for (final item in komposisi) {
      final namaBahan = item['namaBahan']?.toString() ?? '';
      if (namaBahan.isEmpty) continue;
      final jumlahPerUnit = (item['jumlah'] as num).toInt();
      usage[namaBahan] =
          (usage[namaBahan] ?? 0) + (jumlahPerUnit * jumlahProduk);
    }
    return usage;
  }

  /// Hitung selisih penggunaan antara dua set komposisi dan jumlah produk
  Map<String, int> calculateStockDelta(
    List<Map<String, dynamic>> oldKomposisi,
    int oldJumlahProduk,
    List<Map<String, dynamic>> newKomposisi,
    int newJumlahProduk,
  ) {
    final oldUsage = calculateTotalUsage(oldKomposisi, oldJumlahProduk);
    final newUsage = calculateTotalUsage(newKomposisi, newJumlahProduk);

    final delta = <String, int>{};

    // Selisih untuk bahan yang ada di lama
    for (final bahan in oldUsage.keys) {
      final oldAmount = oldUsage[bahan]!;
      final newAmount = newUsage[bahan] ?? 0;
      delta[bahan] = oldAmount - newAmount; // Jika positif: kembalikan stok
    }

    // Tambahkan bahan baru yang tidak ada di lama
    for (final bahan in newUsage.keys) {
      if (!delta.containsKey(bahan)) {
        final newAmount = newUsage[bahan]!;
        delta[bahan] = -newAmount; // Negatif = butuh kurangi stok
      }
    }

    return delta;
  }

  /// Update stok bahan baku berdasarkan delta (selisih)
  Future<void> updateStockByDelta(
    Map<String, int> delta,
  ) async {
    final batch = _firestore.batch();

    for (final entry in delta.entries) {
      final namaBahan = entry.key;
      final change = entry.value;

      if (change == 0) continue;

      final querySnapshot = await _firestore
          .collection('bahanBaku')
          .where('namaBahan', isEqualTo: namaBahan)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Bahan baku "$namaBahan" tidak ditemukan');
      }

      final docRef = querySnapshot.docs.first.reference;
      final currentStock =
          (querySnapshot.docs.first.data()?['jumlah'] as num).toInt();
      final newStock = currentStock + change;

      if (newStock < 0) {
        throw Exception(
            'Stok tidak cukup untuk bahan "$namaBahan". Dibutuhkan: ${-change}, tersedia: $currentStock');
      }

      batch.update(docRef, {
        'jumlah': newStock,
        'diubah': DateTime.now().toLocal().toString(),
      });
    }

    await batch.commit();
  }

  /// Main method: Menangani semua perubahan produk (jumlah atau komposisi)
  Future<void> adjustStockForProductChange({
    required String productId,
    required int oldJumlahProduk,
    required int newJumlahProduk,
    required List<Map<String, dynamic>> oldKomposisi,
    required List<Map<String, dynamic>> newKomposisi,
  }) async {
    final delta = calculateStockDelta(
      oldKomposisi,
      oldJumlahProduk,
      newKomposisi,
      newJumlahProduk,
    );

    if (delta.isEmpty) return; // Tidak ada perubahan

    await updateStockByDelta(delta);
  }
}
