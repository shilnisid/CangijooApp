import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_supplier_controller.dart';

class EditSupplierView extends GetView<EditSupplierController> {
  const EditSupplierView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Supplier'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Object?>>(
        future: controller.getData(Get.arguments.toString()), // Mengambil data supplier
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.data() != null) {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              // Mengisi TextEditingController dengan data supplier
              controller.newName.text = data["supplierName"].toString();
              controller.newNumber.text = data["supplierNumber"].toString();

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: controller.newName,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kontak',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: controller.newNumber,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Kontak',
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (controller.newName.text.isNotEmpty &&
                            controller.newNumber.text.isNotEmpty) {
                          // Simpan perubahan
                          controller.editSupplier(
                            Get.arguments.toString(),
                            controller.newName.text,
                            controller.newNumber.text,
                          );
                        } else {
                          // Tampilkan pesan jika ada field yang kosong
                          Get.snackbar(
                            'Error',
                            'Semua field harus diisi',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                    ),
                  ],
                ),
              );
            } else {
              // Jika data tidak ditemukan
              return const Center(
                child: Text('Data tidak ditemukan'),
              );
            }
          }
          // Tampilkan loading saat menunggu data dari Firestore
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
