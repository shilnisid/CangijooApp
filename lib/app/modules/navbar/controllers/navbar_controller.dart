import 'package:cangijoo/app/modules/bahan_baku/views/bahan_baku_view.dart';
import 'package:cangijoo/app/modules/home/views/home_view.dart';
import 'package:cangijoo/app/modules/profile/views/profile_view.dart';
import 'package:cangijoo/app/modules/supplier/views/supplier_view.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

class NavbarController extends GetxController {
  //TODO: Implement NavbarController
  var currentPageIndex = 0;

  final List<Widget> menuBar = [
    const HomeView(),
    const BahanBakuView(),
    const SupplierView(),
    ProfileView()
  ];

  void currentPage(int index) async {
    currentPageIndex = index;
    update();
  }
}
