import 'package:get/get.dart';

import '../controllers/edit_bahan_baku_controller.dart';

class EditBahanBakuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditBahanBakuController>(
      () => EditBahanBakuController(),
    );
  }
}
