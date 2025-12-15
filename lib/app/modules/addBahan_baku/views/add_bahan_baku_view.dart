import 'package:cangijoo/app/modules/editBahan_baku/views/thousand_separator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/add_bahan_baku_controller.dart';

class AddBahanBakuView extends GetView<AddBahanBakuController> {
  const AddBahanBakuView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Bahan Baku'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller.jenisc,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nama Bahan Baku',
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: controller.jumlahc,
              autocorrect: false,
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
              textInputAction: TextInputAction.next,
              inputFormatters: [ThousandSeparatorInputFormatter()],
              decoration: InputDecoration(
                suffixText: 'gram',
                labelText: 'Jumlah',
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: controller.hargac,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              inputFormatters: [ThousandSeparatorInputFormatter()],
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixText: 'Rp. ',
                labelText: 'Harga',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Validasi input
                if (controller.jenisc.text.isEmpty ||
                    controller.jumlahc.text.isEmpty ||
                    controller.hargac.text.isEmpty) {
                  Get.snackbar('Error', 'Semua field harus diisi');
                  return;
                }

                try {
                  final namaBahan = controller.jenisc.text;
                  final jumlah = int.parse(controller.jumlahc.text.replaceAll('.', ''));
                  final harga = int.parse(controller.hargac.text.replaceAll('.', ''));

                  controller.addBahanBaku(
                    namaBahan,
                    harga,
                    jumlah,
                    controller.dibuat.toString(),
                    controller.expired,
                  );
                  Get.arguments.toString();
                } catch (e) {
                  Get.snackbar('Error', 'Input tidak valid');
                }
              },
              child: Text('Tambah Bahan Baku'),
            ),
          ],
        ),
      ),
    );
  }
}
