import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../controllers/bahan_baku_controller.dart';

class BahanBakuView extends GetView<BahanBakuController> {
  const BahanBakuView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fallback jika binding belum bekerja
    if (!Get.isRegistered<BahanBakuController>()) {
      Get.put(BahanBakuController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bahan Baku'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print',
            onPressed: () {
              controller.printAsPdf();
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.lightGreen[200],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat data bahan baku',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada bahan baku',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan bahan baku pertama Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final listAllDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: listAllDocs.length,
            itemBuilder: (context, index) {
              final data = listAllDocs[index].data();
              final docId = listAllDocs[index].id;
              final namaBahan = data['namaBahan'] as String? ?? 'Unknown';
              final jumlah = controller.parseNumericValue(data['jumlah']);
              final harga = controller.parseNumericValue(data['harga']);

              final formattedHarga = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(harga);

              return Slidable(
                key: ValueKey(docId),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        controller.deleteBahanBaku(docId);
                      },
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_forever,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        Get.toNamed(
                          Routes.EDIT_BAHAN_BAKU,
                          arguments: docId,
                        );
                      },
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),
                child: Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.lightGreen[100],
                      radius: 24,
                      child: Text(
                        _getInitials(namaBahan),
                        style: TextStyle(
                          color: Colors.lightGreen[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      namaBahan,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Jumlah: $jumlah Gram\nHarga: $formattedHarga',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      _showBahanBakuDetails(context, data);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen[200],
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
        onPressed: () {
          Get.toNamed(Routes.ADD_BAHAN_BAKU);
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    List<String> names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    } else {
      return (names[0][0] + names[names.length - 1][0]).toUpperCase();
    }
  }

  void _showBahanBakuDetails(
      BuildContext context, Map<String, dynamic> data) {
    final namaBahan = data['namaBahan'] as String? ?? 'Unknown';
    final jumlah = controller.parseNumericValue(data['jumlah']);
    final harga = controller.parseNumericValue(data['harga']);
    final dibuat = data['dibuat'] as String? ?? '-';
    final diubah = data['diubah'] as String? ?? '-';
    final exp = data['exp'] as String? ?? '-';

    final formattedHarga = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(harga);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Detail Bahan Baku',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.label_important, 'Nama', namaBahan),
            _buildDetailRow(Icons.format_list_numbered, 'Jumlah', '$jumlah Gram'),
            _buildDetailRow(Icons.monetization_on, 'Harga', formattedHarga),
            const Divider(height: 24),
            _buildDetailRow(Icons.calendar_today, 'Dibuat', dibuat),
            _buildDetailRow(Icons.edit_calendar, 'Diubah', diubah),
            _buildDetailRow(Icons.error, 'Kedaluwarsa', exp),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

