import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditBahanBakuController extends GetxController {
  //TODO: Implement EditBahanBakuController
  FirebaseFirestore db = FirebaseFirestore.instance;
  late TextEditingController jenisC;
  late TextEditingController hargaC;
  late TextEditingController jumlahC;
  NumberFormat mataUang = NumberFormat.decimalPattern('id_ID');
  final diupdate = DateFormat.jm().add_yMMMd().format(DateTime.now().toLocal());
  late final expired = DateFormat.jm()
      .add_yMMMd()
      .format(DateTime.now().add(Duration(days: 30)).toLocal());

  Future<DocumentSnapshot> getData(String docID) async {
    DocumentReference docRef = db.collection('bahanBaku').doc(docID);
    return await docRef.get();
  }

  void editBahanBaku(String namaBahan, int harga, int jumlah, diubah, exp,
      String docID) async {
    DocumentReference docData = db.collection('bahanBaku').doc(docID);

    try {
      await docData.update({
        'namaBahan': namaBahan,
        'jumlah': jumlah,
        'harga': harga,
        'diubah': diupdate,
        'exp': expired
      });
      Get.defaultDialog<Object>(
        title: 'Berhasil',
        middleText: 'Berhasil mengubah bahan baku',
        onConfirm: () {
          jenisC.clear();
          hargaC.clear();
          jumlahC.clear();
          Get.back();
          Get.back();
        },
        textConfirm: 'Okay',
      );
    } catch (e) {
      Get.defaultDialog<Object>(
        title: 'Terjadi Kesalahan',
        middleText: 'Gagal mengubah bahan baku',
      );
    }
  }

  void deleteBahanbaku(String docID) {
    DocumentReference docData = db.collection('bahanBaku').doc(docID);
    try {
      Get.defaultDialog(
        title: 'Terhapus',
        middleText: 'Berhasil menghapus bahan baku',
        onConfirm: () {
          docData.delete();
          Get.back();
          Get.back();
        },
        textConfirm: 'Hapus',
        textCancel: 'Batal',
      );
    } catch (e) {
      Get.defaultDialog<Object>(
        title: 'Terjadi Kesalahan',
        middleText: 'Gagal menghapus bahan baku',
      );
    }
  }
  @override
  void onInit() {
    jenisC = TextEditingController();
    hargaC = TextEditingController();
    jumlahC = TextEditingController();
    super.onInit();
  }



  @override
  void onClose() {
    jenisC.dispose();
    hargaC.dispose();
    jumlahC.dispose();
    super.onClose();
  }

}
