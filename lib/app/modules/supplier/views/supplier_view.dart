import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/supplier_controller.dart';

class SupplierView extends GetView<SupplierController> {
  const SupplierView({super.key});

  @override
  Widget build(BuildContext context) {
    
    if (!Get.isRegistered<SupplierController>()) {
      Get.put(SupplierController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[50],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.streamDataSupplier(),
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
                    'Gagal memuat data supplier',
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
                    'Belum ada supplier',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan supplier pertama Anda',
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
              final data = listAllDocs[index].data() as Map<String, dynamic>;
              final phoneNumber = data['supplierNumber'] as String? ?? '';
              final supplierName = data['supplierName'] as String? ?? 'Unknown';
              final docId = listAllDocs[index].id;

              return Slidable(
                key: ValueKey(docId),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        controller.deleteSupplier(docId);
                      },
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_forever,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        Get.toNamed(
                          Routes.EDIT_SUPPLIER,
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
                    title: Text(
                      supplierName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      phoneNumber.isNotEmpty
                          ? '+62$phoneNumber'
                          : 'No phone number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.lightGreen[200],
                      radius: 24,
                      child: Text(
                        _getInitials(supplierName),
                        style: TextStyle(
                          color: Colors.lightGreen[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.message_rounded,
                        color: Colors.lightGreen[600],
                        size: 24,
                      ),
                      onPressed: phoneNumber.isNotEmpty
                          ? () => controller.toWa(phoneNumber)
                          : null,
                      tooltip: 'Kirim WhatsApp',
                    ),
                    onTap: () {
                      
                      _showSupplierDetails(context, supplierName, phoneNumber);
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
          Get.toNamed(Routes.ADD_SUPPLIER);
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

  
  void _showSupplierDetails(BuildContext context, String name, String phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
              'Detail Supplier',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Supplier'),
                      Text(
                        name,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor Telepon'),
                      Text(
                        phone.isNotEmpty ? '+62$phone' : 'Tidak ada nomor',
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
            const SizedBox(height: 16),
            if (phone.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.toWa(phone);
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Kirim WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
