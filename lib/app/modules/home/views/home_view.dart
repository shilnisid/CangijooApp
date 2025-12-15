import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cangijoo/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Produk'),
            backgroundColor: Colors.lightGreen[50],
            elevation: 0,
            centerTitle: true,
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: controller.streamDataProduk(),
            builder: (context, snapshot) {
              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightGreen[200],
                  ),
                );
              }

              // No data state
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text('No data available'),
                );
              }

              final products = snapshot.data!.docs;

              if (products.isEmpty) {
                return const Center(
                  child: Text('No products found'),
                );
              }

              // List produk
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final doc = products[index];
                  final docId = controller.getDocumentId(doc);
                  final data = doc.data();
                  final namaProduk = (data['namaProduk'] ?? '').toString();
                  final jumlahBahan = data['jumlahBahan'] ?? 0;

                  return Card(
                    elevation: 2,
                    color: Colors.lightGreen[100],
                    margin: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      title: Text(
                        namaProduk,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: FutureBuilder<String>(
                        future: controller.getKomposisi(namaProduk),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading...');
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          return Text(
                            snapshot.data ?? 'No composition data',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightGreen[200],
                        child: Text(
                          namaProduk.isNotEmpty
                              ? namaProduk[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.lightGreen[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: () async {
                          final deskripsi =
                              await controller.getKomposisi(namaProduk);

                          Get.toNamed(
                            Routes.PRODUK_DETAIL,
                            arguments: {
                              'productId': docId,
                              'namaProduk': namaProduk,
                              'deskripsiProduk':
                                  deskripsi.isNotEmpty ? deskripsi : '',
                              'jumlahBahan': jumlahBahan,
                            },
                          );
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
            child: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.ADD_PRODUK_DETAIL),
          ),
        );
      },
    );
  }
}
