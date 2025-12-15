import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/add_produk_detail_controller.dart';

class AddProdukDetailView extends GetView<AddProdukDetailController> {
  const AddProdukDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk Jadi'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: GetX<AddProdukDetailController>(
        init: Get.find<AddProdukDetailController>(),
        builder: (controller) {
          // Show loading overlay when processing
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memproses data...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                TextField(
                  controller: controller.namaProduk,
                  focusNode: controller.namaProdukFocus,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.inventory_sharp),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 50,
                  buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) {
                    return Text(
                      '$currentLength/${maxLength ?? 50}',
                      style: TextStyle(
                        color: currentLength > (maxLength ?? 50) * 0.8
                            ? Colors.orange
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Card Tambah Komposisi
                _buildTambahKomposisiCard(controller),
                const SizedBox(height: 20),

                // Daftar Komposisi
                _buildKomposisiList(controller),
                const SizedBox(height: 30),

                // Tombol SIMPAN PRODUK
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: controller.simpanProdukFromUI,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Simpan Produk',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: controller.resetFormFromUI,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Form'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTambahKomposisiCard(AddProdukDetailController controller) {
    return Card(
      elevation: 4,
      color: Colors.lightGreen.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Tambah Komposisi Bahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nama Bahan
            TextField(
              controller: controller.komposisiNama,
              focusNode: controller.komposisiNamaFocus,
              decoration: const InputDecoration(
                labelText: 'Nama Bahan *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grain_sharp),
                hintText: 'Contoh: Kacang Merah',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 30,
            ),
            const SizedBox(height: 15),

            // Jumlah dan Satuan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: controller.komposisiJumlah,
                    focusNode: controller.komposisiJumlahFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Jumlah per Produk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                      hintText: '0',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: controller.komposisiSatuan,
                    focusNode: controller.komposisiSatuanFocus,
                    decoration: const InputDecoration(
                      labelText: 'Satuan*',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      hintText: 'etc:gr/Kg',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tombol Tambah Bahan
            Center(
              child: ElevatedButton.icon(
                onPressed: controller.tambahBahanFromUI,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Bahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKomposisiList(AddProdukDetailController controller) {
    if (controller.listKomposisi.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Belum ada komposisi',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tambahkan bahan untuk memulai',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Daftar Komposisi (${controller.listKomposisi.length} bahan):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: controller.resetKomposisiFromUI,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.listKomposisi.length,
          itemBuilder: (context, index) {
            final bahan = controller.listKomposisi[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  bahan['namaBahan'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                        'Per produk: ${controller.formatJumlahBahan(bahan['jumlah'])} ${bahan['satuan']}'),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () => controller.hapusBahanFromUI(
                      index, bahan['namaBahan'].toString()),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus bahan',
                ),
                isThreeLine: false,
              ),
            );
          },
        ),
      ],
    );
  }
}