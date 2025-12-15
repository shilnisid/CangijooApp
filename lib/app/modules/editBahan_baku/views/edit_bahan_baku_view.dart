import 'package:cangijoo/app/modules/editBahan_baku/views/thousand_separator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/edit_bahan_baku_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class EditBahanBakuView extends GetView<EditBahanBakuController> {
  const EditBahanBakuView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bahan baku '),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Object?>>(
          future: controller.getData(Get.arguments.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              controller.jenisC.text = data["namaBahan"].toString();
              controller.hargaC.text = ThousandSeparatorInputFormatter.format(data["harga"]);
              controller.jumlahC.text = data["jumlah"].toString();
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: controller.jenisC,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Bahan baku',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: controller.jumlahC,
                      autocorrect: false,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      textInputAction: TextInputAction.next,
                      inputFormatters: [ThousandSeparatorInputFormatter()],
                      decoration: const InputDecoration(
                        suffixText: 'gram',
                        labelText: 'Jumlah',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: controller.hargaC,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [ThousandSeparatorInputFormatter()],
                      decoration:const  InputDecoration(
                        prefixText: 'Rp',
                        labelText: 'Harga',
                      ),
                    ),
                    const  SizedBox(
                      height: 30,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.editBahanBaku(
                          controller.jenisC.text,
                          int.parse(controller.hargaC.text.replaceAll('.', '')).toInt(),
                          int.parse(controller.jumlahC.text.replaceAll('.', '')),
                          controller.diupdate,
                          controller.expired,
                          Get.arguments.toString()),
                      icon: const Icon(Icons.save,),
                      label: const Text('Simpan perubahan'),
                    ),
                    const SizedBox(height: 15,),
                    ElevatedButton.icon(
                      onPressed:() => controller.deleteBahanbaku(Get.arguments.toString()),
                      icon: Icon(Icons.delete, color: Colors.black54),
                      label: Text('Hapus bahan baku', style: TextStyle(color: Colors.black87),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
