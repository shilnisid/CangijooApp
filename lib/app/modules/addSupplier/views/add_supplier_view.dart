import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/add_supplier_controller.dart';

class AddSupplierView extends GetView<AddSupplierController> {
  const AddSupplierView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Supplier'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[200],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 60,
                      color: Colors.lightGreen[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Nama Supplier Field
                  TextFormField(
                    controller: controller.namaSupplierController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Nama Supplier',
                      hintText: 'Masukkan nama supplier',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.lightGreen[600]!,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nomor Supplier Field
                  TextFormField(
                    controller: controller.nomorSupplierController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      hintText: '8123456789',
                      prefixText: '+62 ',
                      prefixStyle: TextStyle(
                        color: Colors.lightGreen[700],
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.lightGreen[600]!,
                          width: 2,
                        ),
                      ),
                      helperText: 'Masukkan nomor tanpa 0 di depan (contoh: 8123456789)',
                      helperStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            // Bottom Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.addSupplier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isLoading.value
                        ? Colors.grey[400]
                        : Colors.lightGreen[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    controller.isLoading.value
                        ? 'Menambahkan...'
                        : 'Tambah Supplier',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}