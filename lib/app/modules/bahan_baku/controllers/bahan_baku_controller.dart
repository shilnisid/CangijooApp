import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class BahanBakuController extends GetxController {
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> bahanBakuList = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final RxBool isLoading = false.obs;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamData() {
    CollectionReference<Map<String, dynamic>> bahanBaku = db.collection('bahanBaku');
    return bahanBaku.snapshots();
  }

  num parseNumericValue(dynamic value) {
    if (value is String) {
      return num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else if (value is num) {
      return value;
    }
    return 0;
  }

  Future<QuerySnapshot<Object?>> getData() async {
    CollectionReference bahanBaku = db.collection('bahanBaku');
    return bahanBaku.get();
  }

  void deleteBahanBaku(String docId) async {
    try {
      await db.collection('bahanBaku').doc(docId).delete();
      Get.snackbar(
        'Berhasil',
        'Data bahan baku berhasil dihapus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus data bahan baku: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void printAsPdf() async {
    try {
      isLoading.value = true;
      final pdf = pw.Document();
      final snapshot = await db.collection('bahanBaku').get();

      final formatJumlah = NumberFormat('#,###','id_ID');
      final formatHarga = NumberFormat('#,###','id_ID');
      final timestamp = DateFormat.jm().add_yMMMd().format(DateTime.now().toLocal());

      // Prepare table data
      final tableData = <List<String>>[
        ['Nama Bahan', 'Jumlah', 'Harga', 'Dibuat', 'Diubah', 'Exp'],
        ...snapshot.docs.map((doc) {
          final jumlah = parseNumericValue(doc.get('jumlah'));
          final harga = parseNumericValue(doc.get('harga'));
          return [
            doc.get('namaBahan')?.toString() ?? '-',
            '${formatJumlah.format(jumlah)} gram',
            'Rp ${formatHarga.format(harga)}',
            (doc.data().containsKey('dibuat') ? doc.get('dibuat')?.toString() : '-') ?? '-',
            (doc.data().containsKey('diubah') ? doc.get('diubah')?.toString() : '-') ?? '-',
            (doc.data().containsKey('exp') ? doc.get('exp')?.toString() : '-') ?? '-',
          ];
        })
      ];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'Daftar Bahan Baku',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 26, width: 15),
            pw.TableHelper.fromTextArray(
              data: tableData,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.center,
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2.5),
                3: pw.FlexColumnWidth(3),
                4: pw.FlexColumnWidth(3),
                5: pw.FlexColumnWidth(2.5),
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text('Printed on: $timestamp'),
          ],
        ),
      );

      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'bahan_baku_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencetak PDF: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _streamSubscription;
  @override
  void onInit() {
    _streamSubscription = streamData().listen((event) {
      isLoading.value = true;
      bahanBakuList.value = event.docs;
      isLoading.value = false;
    });
    super.onInit();
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    bahanBakuList.clear();
    super.onClose();
  }
}
