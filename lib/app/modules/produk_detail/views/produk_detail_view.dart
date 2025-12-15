import 'package:cangijoo/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_detail_controller.dart';

class ProdukDetailView extends GetView<ProdukDetailController> {
  ProdukDetailView({super.key});

  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Detail'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return _buildLoadingState();
        }

        return _buildProductDetailContent();
      }),
      floatingActionButton: Obx(() {
        if (controller.isInitialized.value) {
          return FloatingActionButton(
            backgroundColor: Colors.red[400],
            child: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data produk...'),
        ],
      ),
    );
  }

  Widget _buildProductDetailContent() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: 20,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.lightGreen[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProductName(),
              const SizedBox(height: 16),
              _buildKomposisiSection(),
              const SizedBox(height: 16),
              _buildStockSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Obx(() => Text(
          controller.namaProduk.value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ));
  }

  Widget _buildKomposisiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Komposisi Section Title
        const Text(
          'Komposisi:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Komposisi List
        Obx(() {
          if (controller.komposisiList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Tidak ada komposisi',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.lightGreen[100],
                ),
              ),
            );
          }

          return SizedBox(
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.komposisiList.length,
              itemBuilder: (context, index) {
                final komposisi = controller.komposisiList[index];
                return Card(
                  color: Colors.lightGreen[100],
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    title: Text(
                      komposisi['namaBahan'] ?? 'Tidak ada nama',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${controller.numberFormat.format(komposisi['jumlah'] ?? 0)} ${komposisi['satuan'] ?? 'gr'} per produk',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStockSection() {
    return Column(
      children: [
        const Text(
          'Stok Produk:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDecrementButton(),
            const SizedBox(width: 16),
            _buildStockCounter(),
            const SizedBox(width: 16),
            _buildIncrementButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDecrementButton() {
    return Obx(() => IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            size: 36,
            color: controller.isLoading.value ? Colors.grey : null,
          ),
          highlightColor: Colors.red[200],
          hoverColor: Colors.red[100],
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (controller.productId.isNotEmpty) {
                    controller.decrementJumlahProduk();
                  } else {
                    Get.snackbar('Error', 'Produk tidak valid');
                  }
                },
        ));
  }

  Widget _buildIncrementButton() {
    return Obx(() => IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            size: 36,
            color: controller.isLoading.value ? Colors.grey : null,
          ),
          highlightColor: Colors.lightGreen[200],
          hoverColor: Colors.lightGreen[100],
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (controller.productId.isNotEmpty) {
                    controller.incrementJumlahProduk();
                  } else {
                    Get.snackbar('Error', 'Produk tidak valid');
                  }
                },
        ));
  }

  Widget _buildStockCounter() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            '${controller.jumlahProduk[controller.productId]?.value ?? 0}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: controller.isLoading.value ? Colors.grey : Colors.black,
            ),
          ),
        ));
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.defaultDialog<void>(
      title: "Konfirmasi Hapus",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Apakah Anda yakin ingin menghapus produk ini?",
      contentPadding: const EdgeInsets.all(20),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[400],
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          controller.deleteProduk();
          Get.back<void>();
        },
        child: const Text('Hapus'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back<void>(),
        child: const Text('Batal'),
      ),
    );
  }
}
