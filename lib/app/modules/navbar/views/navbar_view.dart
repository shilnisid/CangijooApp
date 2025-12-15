import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../controllers/navbar_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';



class NavbarView extends GetView<NavbarController> {
  const NavbarView({super.key});
  void sharedPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.getString('email');
    prefs.getString('google');
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavbarController>(
      builder: (controller) {
        return Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) async {
              controller.currentPage(index);
            },
            indicatorColor: Colors.lightGreen[200],
            selectedIndex: controller.currentPageIndex,
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.apps),
                icon: Icon(Icons.apps_outlined),
                label: 'Produk',
              ),
              NavigationDestination(
                icon: SvgPicture.asset('assets/icon/grocery_28dp.svg',
                  width: 28,
                  height: 28,),
                selectedIcon: SvgPicture.asset('assets/icon/grocery_28dp.svg',
                  width: 28,
                  height: 28,),
                label: 'Bahan Baku',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.call),
                icon: Icon(Icons.call_outlined),
                label: 'Supplier',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.account_circle_sharp),
                icon: Icon(Icons.account_circle_outlined),
                label: 'Profile',
              ),
            ],
          ),
          body: controller.menuBar[controller.currentPageIndex],
        );
      },
    );
  }
}
