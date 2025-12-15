import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddBahanBakuController extends GetxController {
  //TODO: Implement AddBahanBakuController
  FirebaseFirestore db = FirebaseFirestore.instance;

  late TextEditingController jenisc;
  late TextEditingController hargac;
  late TextEditingController jumlahc;

  NumberFormat numberFormat = NumberFormat.decimalPattern('id_ID');
  final dibuat = DateFormat.jm().add_yMMMd().format(DateTime.now().toLocal());
  late final expired = DateFormat.jm()
      .add_yMMMd()
      .format(DateTime.now().add(Duration(days: 30)).toLocal());

  void addBahanBaku(
      String namaBahan, int harga, int jumlah, String dibuat, exp) async {
    CollectionReference bahanBaku = db.collection('bahanBaku');

    print(numberFormat.format(jumlah));
    print(jumlah);

    try {
      await bahanBaku.add({
        'namaBahan': namaBahan,
        'jumlah': jumlah,
        'harga': harga,
        'dibuat': dibuat,
        'exp': expired
      });
      Get.defaultDialog(
        title: 'Berhasil',
        middleText: 'Berhasil menambahkan bahan baku',
        onConfirm: () {
          jenisc.clear();
          hargac.clear();
          jumlahc.clear();
          Get.back();
          Get.back();
        },
        textConfirm: 'Okay',
      );
    } catch (e) {
      Get.defaultDialog(
        title: 'Terjadi Kesalahan',
        middleText: 'Gagal menambahkan bahan baku',
      );
    }
  }

  @override
  void onInit() {
    jenisc = TextEditingController();
    hargac = TextEditingController();
    jumlahc = TextEditingController();

    super.onInit();
  }

  @override
  void onClose() {

    jenisc.dispose();
    hargac.dispose();
    jumlahc.dispose();
    super.onClose();
  }


}
