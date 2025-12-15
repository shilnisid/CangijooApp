import 'package:get/get.dart';


import '../controllers/produk_detail_controller.dart';
import '../service/stock_service.dart';

class ProdukDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProdukDetailController>(
      () => ProdukDetailController());
    Get.lazyPut<StockService>(() => StockService());

  }
}
