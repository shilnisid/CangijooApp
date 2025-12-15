import 'package:get/get.dart';

import '../controllers/add_produk_detail_controller.dart';

class AddProdukDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProdukDetailController>(
      () => AddProdukDetailController(),
    );
  }
}
