import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController
  FirebaseFirestore data = FirebaseFirestore.instance;




  Stream<QuerySnapshot<Map<String, dynamic>>> streamDataProduk() {
    return data.collection('produk').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDataBahanBaku() {
    return data.collection('bahanBaku').snapshots();
  }

  Future<String> getKomposisi(String namaProduk) async {
    try {
      // Get the produk document
      final produkSnapshot = await data.collection('produk')
          .where('namaProduk', isEqualTo: namaProduk)
          .get();

      if (produkSnapshot.docs.isEmpty) {
        return 'Produk tidak ditemukan';
      }

      final produkData = produkSnapshot.docs.first.data();
      final komposisiProduk = produkData['komposisiProduk'] as Map<String, dynamic>?;

      if (komposisiProduk == null || komposisiProduk.isEmpty) {
        return 'Komposisi tidak tersedia';
      }

      // Build komposisi string
      String komposisi = 'Komposisi per produk:\n';
      komposisiProduk.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final bahanData = value;
          komposisi += '- ${bahanData['namaBahan']?.toString() ?? '-'}: ${bahanData['jumlah'] ?? 0} ${bahanData['satuan']?.toString() ?? 'gram'}\n';
        }
      });


      return komposisi;
    } catch (e) {
      return 'Error loading komposisi: ${e.toString()}';
    }

  }

  String getDocumentId(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.id;
  }

}
